//
//  WatchDog.swift
//  EventLogger
//
//  Created on 2022/10/23.
//

import Foundation

/// Class for logging excessive blocking on the main thread.
final class WatchDog: NSObject {
    
    enum Status: Int {
        case off = 0
        case on
        
        mutating func toggle() {
            self = Status(rawValue: (self.rawValue + 1) % 2) ?? .off
        }
    }
    
    private let pingThread: PingThread
    
    private static let defaultThreshold = 1.0
    
    /// Convenience initializer that allows you to construct a `WatchDog` object with default behavior.
    /// - parameter threshold: number of seconds that must pass to consider the main thread blocked.
    /// - parameter strictMode: boolean value that stops the execution whenever the threshold is reached.
    convenience init(threshold: Double = WatchDog.defaultThreshold, strictMode: Bool = false) {
        let message = "👮 Main thread was blocked for " + String(format: "%.2f", threshold) + "s 👮"
        
        self.init(threshold: threshold) {
            if strictMode {
                fatalError(message)
            } else {
                Log.error(message)
            }
        }
    }
    
    /// Default initializer that allows you to construct a `WatchDog` object specifying a custom callback.
    /// - parameter threshold: number of seconds that must pass to consider the main thread blocked.
    /// - parameter watchdogFiredCallback: a callback that will be called when the the threshold is reached
    init(threshold: Double = WatchDog.defaultThreshold, watchdogFiredCallback: @escaping () -> Void) {
        self.pingThread = PingThread(threshold: threshold, handler: watchdogFiredCallback)
        
        self.pingThread.start()
        super.init()
        
        Log.debug("WatchDog start!!")
    }
    
    deinit {
        Log.debug("WatchDog stop!!")

        pingThread.cancel()
    }
}

private final class PingThread: Thread {
    
    fileprivate var pingTaskIsRunning: Bool {
        get {
            objc_sync_enter(pingTaskIsRunningLock)
            let result = _pingTaskIsRunning;
            objc_sync_exit(pingTaskIsRunningLock)
            return result
        }
        set {
            objc_sync_enter(pingTaskIsRunningLock)
            _pingTaskIsRunning = newValue
            objc_sync_exit(pingTaskIsRunningLock)
        }
    }
    
    private var _pingTaskIsRunning = false
    private let pingTaskIsRunningLock = NSObject()
    private var semaphore = DispatchSemaphore(value: 0)
    private let threshold: Double
    private let handler: () -> Void
    
    init(threshold: Double, handler: @escaping () -> Void) {
        self.threshold = threshold
        self.handler = handler
        super.init()
        
        self.name = "WatchDog"
    }
    
    override func main() {
        while !isCancelled {
            pingTaskIsRunning = true
            DispatchQueue.main.async {
                self.pingTaskIsRunning = false
                self.semaphore.signal()
            }
            
            Thread.sleep(forTimeInterval: threshold)
            if pingTaskIsRunning {
                handler()
            }
            
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }
    }
}
