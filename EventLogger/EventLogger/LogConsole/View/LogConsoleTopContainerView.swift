//
//  LogConsoleTopContainerView.swift
//  EventLogger
//

import UIKit

final class LogConsoleTopContainerView: UIView {
    
    private let performanceView: PerformanceView = {
        let view = PerformanceView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
        addSubview(performanceView)
        
        performanceView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        performanceView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        performanceView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
}
