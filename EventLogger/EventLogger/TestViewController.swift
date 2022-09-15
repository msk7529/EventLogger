//
//  TestViewController.swift
//  EventLogger
//
//  Created by on 2022/09/15.
//

import UIKit

final class TestViewController: UIViewController {

    private let centerLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.text = "테스트화면"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .green
        
        initView()
    }
    
    private func initView() {
        view.addSubview(centerLabel)
        
        centerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
        centerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}
