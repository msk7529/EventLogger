//
//  TestViewController.swift
//  EventLogger
//
//  Created by on 2022/09/15.
//

import UIKit

final class TestViewController: UIViewController {

    private lazy var closeButton: UIButton = {
        let button: UIButton = .init(frame: .zero)
        button.setTitle("닫기", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
        
        Log.verboseLog("verboseLog test")
    }
    
    private func initView() {
        view.addSubview(centerLabel)
        
        centerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
        centerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        if navigationController == nil {
            view.addSubview(closeButton)
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        }
    }
    
    @objc
    private func didTapCloseButton() {
        self.dismiss(animated: true)
    }
}
