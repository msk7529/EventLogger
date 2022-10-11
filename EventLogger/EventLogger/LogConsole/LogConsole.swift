//
//  LogConsole.swift
//  EventLogger
//

import UIKit

final public class LogConsole {
    
    private static var isRunning: Bool = false
    private static var logsBeforeStart: [LogConsoleMessage] = []
    
    private static let syncQueue = DispatchQueue(label: "com.openLink.logconsole")
    
    public static func start(with window: UIWindow) {
        guard !isRunning else {
            Log.error("LogConsole is already running!!")
            return
        }
        
        defer {
            isRunning = true
            LogConsoleViewController.shared.viewModel.addLogMessages(logsBeforeStart)
            logsBeforeStart.removeAll()
        }
        
        let logConsoleVC = LogConsoleViewController.shared
        window.addSubview(logConsoleVC.view)
        logConsoleVC.setConstraints(with: window)
    }
    
    public static func bringToFront(window: UIWindow) {
        // guard !isRunning else { return }
        window.bringSubviewToFront(LogConsoleViewController.shared.view)
    }
    
    static func addLogMessage(_ message: LogConsoleMessage) {
        syncQueue.sync {
            if isRunning {
                LogConsoleViewController.shared.viewModel.addLogMessages([message])
            } else {
                logsBeforeStart.append(message)
            }
        }
    }
}
