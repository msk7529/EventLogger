//
//  LogConsoleTableViewCell.swift
//  EventLogger
//

import UIKit

final class LogConsoleTableViewCell: UITableViewCell {
    
    static let identifier = "LogConsoleTableViewCell"
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var message: LogConsoleMessage? {
        didSet {
            guard let message = message else {
                return
            }
            timeLabel.text = message.message
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .orange
        
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        contentView.addSubview(timeLabel)
        
        timeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
    }
}
