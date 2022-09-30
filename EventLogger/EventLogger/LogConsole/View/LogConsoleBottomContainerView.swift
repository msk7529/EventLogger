//
//  LogConsoleBottomContainerView.swift
//  EventLogger
//

import UIKit

final class LogConsoleBottomContainerView: UIView {
    
    enum ButtonType {
        case clear
    }
    
    private lazy var clearButton: UIButton = {
        let button = UIButton()
        button.setTitle("CLEAR", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapClearButton), for: .touchUpInside)
        return button
    }()
    
    var didTapButton: ((ButtonType) -> Void)?
    
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
    
    private func initView() {
        addSubview(clearButton)
        
        clearButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        clearButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
    }
    
    @objc
    private func didTapClearButton() {
        didTapButton?(.clear)
    }
}
