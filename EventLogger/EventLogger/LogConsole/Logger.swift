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
    
    static var miniModePosition: CGPoint {
        get {
            guard let pos = UserDefaults.standard.value(forKey: "miniModePosition") as? String else {
                return CGPoint(x: 20, y: 200)
            }
            return NSCoder.cgPoint(for: pos)
        }
        set {
            UserDefaults.standard.setValue(NSCoder.string(for: newValue), forKey: "miniModePosition")
        }
    }
    
    static var expandModePosition: CGPoint {
        get {
            guard let pos = UserDefaults.standard.value(forKey: "expandModePosition") as? String else {
                return CGPoint(x: 20, y: 200)
            }
            return NSCoder.cgPoint(for: pos)
        }
        set {
            UserDefaults.standard.setValue(NSCoder.string(for: newValue), forKey: "expandModePosition")
        }
    }
    
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
