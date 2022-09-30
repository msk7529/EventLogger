//
//  LogConsoleTableViewCell.swift
//  EventLogger
//

import UIKit

final class LogConsoleTableViewCell: UITableViewCell {
    
    static let identifier = "LogConsoleTableViewCell"
    static let height: CGFloat = 15
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "Courier", size: 7)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let msgLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "Courier", size: 7)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var message: LogConsoleMessage? {
        didSet {
            guard let message = message else {
                return
            }
            timeLabel.text = dateFormatter.string(from: message.timeStamp)
            msgLabel.text = message.message
            setTextColor(with: message)
            setBackgroundColor(with: message)
        }
    }
    
    private let dateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.formatterBehavior = .behavior10_4
        dateFormatter.dateFormat = "HH:mm:ss.SS"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        return dateFormatter
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .orange
        selectionStyle = .none
        
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        contentView.addSubview(timeLabel)
        contentView.addSubview(msgLabel)
        
        timeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
        
        msgLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        msgLabel.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 5).isActive = true
    }
    
    private func setTextColor(with message: LogConsoleMessage) {
        if message.logType == .verbose {
            [timeLabel, msgLabel].forEach { $0.textColor = .lightGray }
        } else {
            [timeLabel, msgLabel].forEach { $0.textColor = .black }
        }
    }
    
    private func setBackgroundColor(with message: LogConsoleMessage) {
        switch message.logType {
        case .verbose, .debug:
            contentView.backgroundColor = .white
        case .info:
            contentView.backgroundColor = .yellow
        case .warning:
            contentView.backgroundColor = .orange
        case .error:
            contentView.backgroundColor = .red
        }
    }
}
