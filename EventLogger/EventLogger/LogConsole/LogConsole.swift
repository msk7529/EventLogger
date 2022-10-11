//
//  LogConsole.swift
//  EventLogger
//

import CocoaLumberjackSwift
import Foundation
import UIKit

final class LogConsole {
        
    static var isRunning: Bool = false
    static var logsBeforeStart: [LogConsoleMessage] = []
    
    static func start(with window: UIWindow) {
        guard !isRunning else {
            Log.error("LogConsole is already running!!")
            return
        }
        
        defer {
            isRunning = true
            LogConsoleViewController.shared.addLogs(logs: logsBeforeStart)
            logsBeforeStart.removeAll()
        }
        
        let logConsoleVC = LogConsoleViewController.shared  // MainWindow에 addSubview후 deinit 되지 않도록 싱글턴으로 생성
        window.addSubview(logConsoleVC.view)
        logConsoleVC.setConstraints(with: window)
    }
    
    static func bringToFront(window: UIWindow) {
        window.bringSubviewToFront(LogConsoleViewController.shared.view)
    }
    
    static func addLog(log: LogConsoleMessage) {
        if isRunning {
            LogConsoleViewController.shared.addLogs(logs: [log])
        } else {
            logsBeforeStart.append(log)
        }
    }
}
