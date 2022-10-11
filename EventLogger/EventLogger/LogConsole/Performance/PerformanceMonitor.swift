//
//  PerformanceMonitor.swift
//  LogConsole
//


import UIKit

final class PerformanceMonitor {
    
    private enum States {
        case started
        case paused
        case pausedBySystem
    }
    
    static let shared = PerformanceMonitor()
    
    private let performanceCalculator = PerformanceCalculator()
    private var state = States.paused
    private var reports: [PerformanceReport] = []
    
    weak var delegate: PerformanceMonitorDelegate?
    
    private init() {
        performanceCalculator.onReport = { [weak self] performanceReport in
            DispatchQueue.main.async {
                self?.apply(performanceReport: performanceReport)
            }
        }
        addObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Helper
    
    func start() {
        switch state {
        case .started:
            return
        case .paused, .pausedBySystem:
            state = .started
            performanceCalculator.start()
        }
    }
    
    func pause() {
        switch state {
        case .paused:
            return
        case .started, .pausedBySystem:
            state = .paused
            performanceCalculator.pause()
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
    
    private func apply(performanceReport: PerformanceReport) {
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
        switch state {
        case .started, .paused:
            return
        case .pausedBySystem:
            state = .started
            performanceCalculator.start()
        }
    }
    
    private func applicationDidEnterBackgroundNotification(notification: Notification) {
        switch state {
        case .paused, .pausedBySystem:
            return
        case .started:
            state = .pausedBySystem
            performanceCalculator.pause()
        }
    }
}
