//
//  LogConsoleTopContainerView.swift
//  EventLogger
//

import UIKit

final class LogConsoleTopContainerView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
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
        backgroundColor = .gray
    }
}
