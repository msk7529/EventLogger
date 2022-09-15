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
        let logConsoleVC = LogConsoleViewController.shared  // MainWindow에 addSubview후 deinit 되지 않도록 싱글턴으로 생성
        window.addSubview(logConsoleVC.view)
        
        /*
        let topConstraint = NSLayoutConstraint(item: logConsoleVC.view as Any, attribute: .top, relatedBy: .equal, toItem: logConsoleVC.view.superview, attribute: .top, multiplier: 1, constant: 30)
        let leadingConstraint = NSLayoutConstraint(item: logConsoleVC.view as Any, attribute: .leading, relatedBy: .equal, toItem: logConsoleVC.view.superview, attribute: .leading, multiplier: 1, constant: 10)
        let widthConstarint = NSLayoutConstraint(item: logConsoleVC.view as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        let heightConstarint = NSLayoutConstraint(item: logConsoleVC.view as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100)
        window.addConstraint(leadingConstraint)
        window.addConstraint(topConstraint)

        logConsoleVC.view.addConstraint(widthConstarint)
        logConsoleVC.view.addConstraint(heightConstarint)
         */

        logConsoleVC.view.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        logConsoleVC.view.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 10).isActive = true
        logConsoleVC.view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        logConsoleVC.view.widthAnchor.constraint(equalToConstant: 50).isActive = true
        // window.bringSubviewToFront(LogConsoleVC.view)
    }
}
