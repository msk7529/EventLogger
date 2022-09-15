//
//  LogConsoleViewController.swift
//  EventLogger
//
//  Created by on 2022/09/15.
//

import UIKit

final class LogConsoleViewController: UIViewController {

    private let testLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.text = "테스트"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        
        initView()
    }

    private func initView() {
        view.addSubview(testLabel)
        
        testLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        testLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
}
