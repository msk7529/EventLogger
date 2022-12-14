//
//  LogConsoleBottomContainerView.swift
//  EventLogger
//

import UIKit

final class LogConsoleBottomContainerView: UIView {
    
    static let height: CGFloat = 30
    
    enum ButtonType {
        case clear
        case memoryTest
        case more
    }
    
    private lazy var clearButton: UIButton = {
        let button = UIButton()
        button.setTitle("CLEAR", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.didTapButton?(.clear)
        }), for: .touchUpInside)
        return button
    }()
    
    private lazy var memoryTestButton: UIButton = {
        let button = UIButton()
        button.setTitle("MEMTEST", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.didTapButton?(.memoryTest)
        }), for: .touchUpInside)
        return button
    }()
    
    private lazy var moreButton: UIButton = {
        let button = UIButton()
        button.setTitle("MORE", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.didTapButton?(.more)
        }), for: .touchUpInside)
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
        addSubview(memoryTestButton)
        addSubview(moreButton)
        
        clearButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        clearButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        
        memoryTestButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        memoryTestButton.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor, constant: -18).isActive = true
        
        moreButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        moreButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
    }
}

