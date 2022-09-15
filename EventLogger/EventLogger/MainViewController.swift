//
//  MainViewController.swift
//  EventLogger
//
//  Created by on 2022/09/15.
//

import UIKit

final class MainViewController: UIViewController {

    private let centerLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.text = "메인화면"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func initView() {
        view.addSubview(centerLabel)
        
        centerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
        centerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}

