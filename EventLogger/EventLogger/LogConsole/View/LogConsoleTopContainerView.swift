//
//  LogConsoleTopContainerView.swift
//  EventLogger
//

import UIKit

final class LogConsoleTopContainerView: UIView {
    
    enum ButtonType {
        case performance
        case monitor
    }
    
    // MARK: - Properties
    
    private lazy var performanceView: PerformanceView = {
        let view = PerformanceView()
        view.addTapHandler { [weak self] in
            self?.didTapButton?(.performance)
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var monitorButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "monitor"), for: .normal)
        button.isHidden = true
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.didTapButton?(.monitor)
        }), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let monitorStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "OFF"
        label.font = .boldSystemFont(ofSize: 8)
        label.textColor = .white
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var watchDogStatus: WatchDog.Status = .off {
        didSet {
            monitorStatusLabel.text = watchDogStatus == .off ? "OFF" : "O N"
        }
    }
    
    var didTapButton: ((ButtonType) -> Void)?
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        backgroundColor = .gray
        
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.borderWidth = 2
        layer.borderColor = UIColor.black.cgColor
    }
    
    // MARK: - UI
    
    private func initView() {
        addSubview(performanceView)
        addSubview(monitorButton)
        addSubview(monitorStatusLabel)
        
        performanceView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        performanceView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        performanceView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        monitorButton.leadingAnchor.constraint(equalTo: performanceView.trailingAnchor, constant: 15).isActive = true
        monitorButton.centerYAnchor.constraint(equalTo: performanceView.centerYAnchor).isActive = true
        monitorButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        monitorButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        
        monitorStatusLabel.topAnchor.constraint(equalTo: monitorButton.topAnchor, constant: 7).isActive = true
        monitorStatusLabel.leadingAnchor.constraint(equalTo: monitorButton.leadingAnchor, constant: 5).isActive = true
    }
    
    func changeViewMode(to viewMode: LogConsoleViewMode) {
        switch viewMode {
        case .mini:
            [monitorButton, monitorStatusLabel].forEach { $0.isHidden = true }
        case .expanded:
            [monitorButton, monitorStatusLabel].forEach { $0.isHidden = false }
        }
    }
}
