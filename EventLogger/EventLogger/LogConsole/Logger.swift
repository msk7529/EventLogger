//
//  Logger.swift
//  EventLogger
//
//  Created by kakao on 2022/09/15.
//

import Foundation
import UIKit

final class Logger {
    
    static let shared = Logger()
    
    private init() {
        
    }
    
    static func start(with window: UIWindow) {
        let LogConsoleVC = LogConsoleViewController()
        window.addSubview(LogConsoleVC.view)
        LogConsoleVC.view.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        LogConsoleVC.view.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 10).isActive = true
        LogConsoleVC.view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        LogConsoleVC.view.widthAnchor.constraint(equalToConstant: 50).isActive = true
        // window.bringSubviewToFront(LogConsoleVC.view)
    }
}
