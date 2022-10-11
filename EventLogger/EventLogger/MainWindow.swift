//
//  MainWindow.swift
//  EventLogger
//
//  Created by on 2022/09/15.
//

import UIKit

final class MainWindow: UIWindow {

    private weak var prevRootViewController: UIViewController?
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        
        #if DEBUG
        LogConsole.bringToFront(window: self)
        #endif
    }

    /* 앱 rootVC가 변경되는 경우에 적절하게 사용해야 할 듯 ? 이 샘플앱에선 사용하지 않음. 사용시 크래시
    override var rootViewController: UIViewController? {
        didSet {
            guard let rootViewController = rootViewController else { return }
            
            #if DEBUG
            Log.info("[APP] window rootVC didSet: \(String(describing: type(of: rootViewController)))")

            if prevRootViewController != nil {
                LogConsoleViewController.shared.view.removeFromSuperview()
            }
            prevRootViewController = rootViewController
            
            rootViewController.view.addSubview(LogConsoleViewController.shared.view)
            LogConsoleViewController.shared.setConstraints(with: self)
            #endif
        }
    }
    */
}
