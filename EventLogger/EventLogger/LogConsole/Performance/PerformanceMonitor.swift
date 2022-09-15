//
//  PerformanceMonitor.swift
//  LogConsole
//


import Foundation
import UIKit

public class PerformanceMonitor {
    
    private enum States {
        case started
        case paused
        case pausedBySystem
    }
    
    static let shared = PerformanceMonitor()
    
    private let performanceCalculator = PerformanceCalculator()
    private var state = States.paused
    private var reports: [PerformanceReport] = []
    
    public weak var delegate: PerformanceMonitorDelegate?
    
    public init() {
        performanceCalculator.onReport = { [weak self] performanceReport in
            DispatchQueue.main.async {
                self?.apply(performanceReport: performanceReport)
            }
        }
        
        self.addObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Helper
    
    func start() {
        switch self.state {
        case .started:
            return
        case .paused, .pausedBySystem:
            self.state = .started
            self.performanceCalculator.start()
        }
    }
    
    func pause() {
        switch self.state {
        case .paused:
            return
        case .started, .pausedBySystem:
            self.state = .paused
            self.performanceCalculator.pause()
        }
    }
    
    func getLastReports(duration: Int) -> [PerformanceReport] {
        guard duration >= 1, reports.count >= 1 else { return [] }
        
        let first = max(0, reports.count - duration)
        let last = reports.count - 1
        
        return Array(reports[first...last])
    }
    
    func cpuUsagePerThread() -> [(String, Double)] {
        return performanceCalculator.cpuUsagePerThread()
    }
    
    func apply(performanceReport: PerformanceReport) {
        appendReport(performanceReport)
        delegate?.performanceMonitor(didReport: performanceReport)
    }
    
    private func appendReport(_ report: PerformanceReport) {
        reports.append(report)
        let limit = 5 * 60
        if reports.count > limit {
            reports.removeFirst(reports.count - limit)
        }
    }
    
    // MARK: - Notifications
    
    private func addObservers() {
        _ = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] notification in
            self?.applicationWillEnterForegroundNotification(notification: notification)
        }
        
        _ = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] notification in
            self?.applicationDidEnterBackgroundNotification(notification: notification)
        }
    }
    
    private func applicationWillEnterForegroundNotification(notification: Notification) {
        switch self.state {
        case .started, .paused:
            return
        case .pausedBySystem:
            self.state = .started
            self.performanceCalculator.start()
        }
    }
    
    private func applicationDidEnterBackgroundNotification(notification: Notification) {
        switch self.state {
        case .paused, .pausedBySystem:
            return
        case .started:
            self.state = .pausedBySystem
            self.performanceCalculator.pause()
        }
    }
}
