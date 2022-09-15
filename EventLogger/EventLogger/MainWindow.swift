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
        
        print("MainWindow: didAddSubview called. \(subview)")
    }
}
