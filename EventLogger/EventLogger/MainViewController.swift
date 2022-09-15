//
//  MainViewController.swift
//  EventLogger
//
//  Created by on 2022/09/15.
//

import UIKit

final class MainViewController: UIViewController {

    private lazy var presentButton: UIButton = {
        let button: UIButton = .init(frame: .zero)
        button.backgroundColor = .brown.withAlphaComponent(0.3)
        button.setTitle("present", for: .normal)
        button.addTarget(self, action: #selector(didTapPresentButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
        view.addSubview(presentButton)
        
        centerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
        centerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        presentButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        presentButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
    }
    
    @objc
    private func didTapPresentButton() {
        let vc = TestViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

