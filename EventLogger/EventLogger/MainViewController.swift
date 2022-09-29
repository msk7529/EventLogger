//
//  MainViewController.swift
//  EventLogger
//
//  Created by on 2022/09/15.
//

import CocoaLumberjackSwift
import UIKit

final class MainViewController: UIViewController {

    private lazy var presentOrPushButton: UIButton = {
        let button: UIButton = .init(frame: .zero)
        button.backgroundColor = .brown.withAlphaComponent(0.3)
        button.setTitle("present or push  ", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(didTapPresentOrPushButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var presentNavButton: UIButton = {
        let button: UIButton = .init(frame: .zero)
        button.backgroundColor = .brown.withAlphaComponent(0.3)
        button.setTitle("present Nav  ", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(didTapPresentNavButton), for: .touchUpInside)
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
        setNavigationBar()
        
        /*
        DDLog.add(DDOSLogger.sharedInstance) // Uses os_log
        DDTTYLogger.sharedInstance?.colorsEnabled = true

        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)

        DDLogVerbose("Verbose 😶")
        DDLogDebug("Debug")
        DDLogInfo("Info")
        DDLogWarn("Warn")
        DDLogError("Error")
        */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func initView() {
        view.addSubview(centerLabel)
        view.addSubview(presentOrPushButton)
        view.addSubview(presentNavButton)
        
        centerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
        centerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        presentOrPushButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        presentOrPushButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        
        presentNavButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        presentNavButton.leadingAnchor.constraint(equalTo: presentOrPushButton.trailingAnchor, constant: 20).isActive = true
    }
    
    private func setNavigationBar() {
        guard navigationController != nil else { return }
        
        navigationItem.title = "NavigationBar"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapCloseButton))
    }
    
    @objc
    private func didTapPresentOrPushButton() {
        let vc = TestViewController()
        vc.modalPresentationStyle = .fullScreen
        
        if let navigationController = navigationController {
            navigationController.pushViewController(vc, animated: true)
        } else {
            present(vc, animated: true)
        }
    }
    
    @objc
    private func didTapPresentNavButton() {
        let nav = UINavigationController()
        let vc = MainViewController()
        nav.viewControllers = [vc]
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    
    @objc
    private func didTapCloseButton() {
        self.dismiss(animated: true)
    }
}

