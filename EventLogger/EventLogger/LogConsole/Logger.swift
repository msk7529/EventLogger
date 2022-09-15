//
//  Logger.swift
//  EventLogger
//
//  Created by on 2022/09/15.
//

import Foundation
import UIKit

final class Logger {
    
    static let shared = Logger()
    
    private init() {
        
    }
    
    static func start(with window: UIWindow) {
        let logConsoleVC = LogConsoleViewController.shared  // MainWindow에 addSubview후 deinit 되지 않도록 싱글턴으로 생성
        window.addSubview(logConsoleVC.view)
        
        logConsoleVC.setConstraints(with: window)
    }
    
    static func bringToFront(window: UIWindow) {
        window.bringSubviewToFront(LogConsoleViewController.shared.view)
    }
}
