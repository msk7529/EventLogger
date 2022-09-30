//
//  MainWindow.swift
//  EventLogger
//
//  Created by on 2022/09/15.
//

import UIKit

final class MainWindow: UIWindow {

    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        
        print("MainWindow didAddSubview.. \(subview)")
        
        LoggerManager.bringToFront(window: self)   // MainWindow에 뷰가 attach 될 때마다 로그콘솔을 맨 앞으로 가져온다.
    }
}
