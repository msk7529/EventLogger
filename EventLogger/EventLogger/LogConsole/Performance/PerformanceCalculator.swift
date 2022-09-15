//
// Copyright © 2017 Gavrilov Daniil
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit
import QuartzCore

/// Memory usage tuple. Contains used and total memory in bytes.
public typealias MemoryUsage = (used: UInt64, total: UInt64)

/// Performance report tuple. Contains CPU usage in percentages, FPS and memory usage.
public typealias PerformanceReport = (cpuUsage: Double, fps: Int, memoryUsage: MemoryUsage)

/// Performance monitor delegate. Gets called on the main thread.
public protocol PerformanceMonitorDelegate: AnyObject {
    /// Reports monitoring information to the receiver.
    ///
    /// - Parameters:
    ///   - performanceReport: Performance report tuple. Contains CPU usage in percentages, FPS and memory usage.
    func performanceMonitor(didReport performanceReport: PerformanceReport)
}

/// Performance calculator. Uses CADisplayLink to count FPS. Also counts CPU and memory usage.
final class PerformanceCalculator {
    
    private struct Constants {
        static let accumulationTimeInSeconds = 1.0
    }
        
    var onReport: ((_ performanceReport: PerformanceReport) -> Void)?
        
    private var displayLink: CADisplayLink!
    private let linkedFramesList = LinkedFramesList()
    private var startTimestamp: TimeInterval?
    private var lastTimestamp: TimeInterval?
    private var accumulatedInformationIsEnough = false
        
    init() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(PerformanceCalculator.displayLinkAction(displayLink:)))
        self.displayLink.isPaused = true
        self.displayLink?.add(to: .current, forMode: .common)
    }
    
    /// Starts performance monitoring.
    func start() {
        self.startTimestamp = Date().timeIntervalSince1970
        self.lastTimestamp = startTimestamp
        self.displayLink?.isPaused = false
    }
    
    /// Pauses performance monitoring.
    func pause() {
        self.displayLink?.isPaused = true
        self.startTimestamp = nil
        self.lastTimestamp = nil
        self.accumulatedInformationIsEnough = false
    }
    
    func cpuUsagePerThread() -> [(String, Double)] {
        var totalUsageOfCPU: Double = 0.0
        var threadsList: thread_act_array_t?
        var threadsCount: mach_msg_type_number_t = 0
        defer {
            if let threadsList = threadsList {
                vm_deallocate(mach_task_self_, vm_address_t(UnsafePointer(threadsList).pointee), vm_size_t(threadsCount))
            }
        }
        let threadsResult = task_threads(mach_task_self_, &threadsList, &threadsCount)
        
        var result = [(String, Double)]()

        guard threadsResult == KERN_SUCCESS,
              let threadsList = threadsList else {
            return []
        }

        for index in 0 ..< threadsCount {
            var threadInfo = thread_basic_info()
            var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
            let thread = threadsList[Int(index)]
            var infoResult = withUnsafeMutablePointer(to: &threadInfo) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    thread_info(thread, thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
                }
            }
            guard infoResult == KERN_SUCCESS else { break }

            var identifierInfo = thread_identifier_info()
            infoResult = withUnsafeMutablePointer(to: &identifierInfo) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    thread_info(thread, thread_flavor_t(THREAD_IDENTIFIER_INFO), $0, &threadInfoCount)
                }
            }
            guard infoResult == KERN_SUCCESS else { break }

            let threadBasicInfo = threadInfo as thread_basic_info
            if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
                let usage = (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0)
                totalUsageOfCPU = (totalUsageOfCPU + usage)

                var threadName: String = "Thread \(index + 1)"

                if let name = getThreadName(thread), name.count > 0 {
                    threadName = "\(threadName) (\(name))"
                }

                result.append((threadName, usage))
            }
        }

        return result
    }
    
    private func getQueueName(_ queue: DispatchQueue?) -> String? {
        let name = __dispatch_queue_get_label(queue)
        return String(cString: name, encoding: .utf8)
    }
    
    private func getThreadName(_ thread: thread_act_t) -> String? {
        guard let pthread = pthread_from_mach_thread_np(thread) else {
            return nil
        }
        return getThreadName(pthread: pthread)
    }
    
    private func getThreadName(pthread: pthread_t) -> String {
        var chars: [Int8] = Array(repeating: 0, count: 128)

        let error = pthread_getname_np(pthread, &chars, chars.count)
        assert(error == 0, "Could not retrieve thread name")

        let characters = chars.filter { $0 != 0 }.map { UInt8($0) }.map(UnicodeScalar.init).map(Character.init)
        return String(characters)
    }
    
    // MARK: - Timer Actions
    
    @objc
    private func displayLinkAction(displayLink: CADisplayLink) {
        self.linkedFramesList.append(frameWithTimestamp: displayLink.timestamp)
        self.takePerformanceEvidence()
    }
    
    // MARK: - Monitoring
    
    func takePerformanceEvidence() {
        if self.accumulatedInformationIsEnough {
            self.accumulatedInformationIsEnough = false
            let cpuUsage = self.cpuUsage()
            let fps = self.linkedFramesList.count
            let memoryUsage = self.memoryUsage()
            self.report(cpuUsage: cpuUsage, fps: fps, memoryUsage: memoryUsage)
        } else if let last = self.lastTimestamp, Date().timeIntervalSince1970 - last >= Constants.accumulationTimeInSeconds {
            self.accumulatedInformationIsEnough = true
            self.lastTimestamp = Date().timeIntervalSince1970
        }
    }
    
    func cpuUsage() -> Double {
        var totalUsageOfCPU: Double = 0.0
        var threadsList: thread_act_array_t?
        var threadsCount: mach_msg_type_number_t = 0
        defer {
            if let threadsList = threadsList {
                vm_deallocate(mach_task_self_, vm_address_t(UnsafePointer(threadsList).pointee), vm_size_t(threadsCount))
            }
        }
        let threadsResult = task_threads(mach_task_self_, &threadsList, &threadsCount)

        guard threadsResult == KERN_SUCCESS,
              let threadsList = threadsList else {
            return 0
        }

        for index in 0..<threadsCount {
            var threadInfo = thread_basic_info()
            var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
            let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    thread_info(threadsList[Int(index)], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
                }
            }

            guard infoResult == KERN_SUCCESS else {
                break
            }

            let threadBasicInfo = threadInfo as thread_basic_info
            if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
                totalUsageOfCPU = (totalUsageOfCPU + (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0))
            }
        }

        return totalUsageOfCPU
    }

    func memoryUsage() -> MemoryUsage {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
        let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        
        var used: UInt64 = 0
        if result == KERN_SUCCESS {
            used = UInt64(taskInfo.phys_footprint)
        }
        
        let total = ProcessInfo.processInfo.physicalMemory
        return (used, total)
    }
    
    // MARK: - Support Methods
    
    func report(cpuUsage: Double, fps: Int, memoryUsage: MemoryUsage) {
        let performanceReport = (cpuUsage: cpuUsage, fps: fps, memoryUsage: memoryUsage)
        self.onReport?(performanceReport)
    }
}
