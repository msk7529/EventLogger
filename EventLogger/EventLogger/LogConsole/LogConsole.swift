//
//  LogConsole.swift
//  EventLogger
//

import CocoaLumberjackSwift
import Foundation
import UIKit

final class LogConsole {
        
    static var isRunning: Bool = false
    
    static func start(with window: UIWindow) {
        guard !isRunning else {
            Logger.errorLog("LogConsole is already running!!")
            return
        }
        
        defer { isRunning = true }
        
        let logConsoleVC = LogConsoleViewController.shared  // MainWindow에 addSubview후 deinit 되지 않도록 싱글턴으로 생성
        window.addSubview(logConsoleVC.view)
        logConsoleVC.setConstraints(with: window)
    }
    
    static func bringToFront(window: UIWindow) {
        window.bringSubviewToFront(LogConsoleViewController.shared.view)
    }
}
