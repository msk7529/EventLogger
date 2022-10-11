//
//  LogConsoleTableViewCell.swift
//  EventLogger
//

import UIKit

final class LogConsoleTableViewCell: UITableViewCell {
    
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
    
    private let detailMsgLabel: PaddingLabel = {
        let label = PaddingLabel(padding: UIEdgeInsets(top: 7, left: 5, bottom: 7, right: 5))
        label.backgroundColor = .black
        label.textColor = UIColor(red: 100 / 255.0, green: 1, blue: 100 / 255.0, alpha: 1)
        label.font = UIFont(name: "Courier", size: 7)
        label.isHidden = true
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    static let tempLabelForCalcHeight: PaddingLabel = {
        let label = PaddingLabel(padding: UIEdgeInsets(top: 7, left: 5, bottom: 7, right: 5))
        label.font = UIFont(name: "Courier", size: 7)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var message: LogConsoleMessage? {
        didSet {
            guard let message = message else {
                return
            }
            
            timeLabel.text = LogConsoleDateFormatterGenerator.dateFormatter(type: .short).string(from: message.timeStamp)
            setMsgLabel(with: message)
            setDetailMsgLabel(with: message)
            setTextColor(with: message)
            setBackgroundColor(with: message)
        }
    }
    
    static let identifier = "LogConsoleTableViewCell"
    static let height: CGFloat = 15
    static let detailLabelLeadingConstant: CGFloat = 10
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        contentView.addSubview(timeLabel)
        contentView.addSubview(msgLabel)
        contentView.addSubview(detailMsgLabel)
        
        timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        timeLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        msgLabel.topAnchor.constraint(equalTo: timeLabel.topAnchor).isActive = true
        msgLabel.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 2).isActive = true
        msgLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5).isActive = true
        msgLabel.heightAnchor.constraint(equalTo: timeLabel.heightAnchor).isActive = true
        
        detailMsgLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 5).isActive = true
        detailMsgLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Self.detailLabelLeadingConstant).isActive = true
        detailMsgLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Self.detailLabelLeadingConstant).isActive = true
        detailMsgLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    private func setMsgLabel(with message: LogConsoleMessage) {
        let messageString = message.message
        if messageString.isEmpty {
            msgLabel.text = "    "      //  그냥 ""로 넣어주면 레이아웃 틀어짐 발생
        } else {
            msgLabel.text = messageString
        }
    }
    
    private func setDetailMsgLabel(with message: LogConsoleMessage) {
        detailMsgLabel.isHidden = !message.isExpanded
        
        if message.isExpanded {
            detailMsgLabel.text = message.expandedMessage
        } else {
            detailMsgLabel.text = " "   // 메시지가 긴 경우 레이아웃 성능이슈가 발생하여, 펼쳐진 상태가 아닐땐 labelText를 세팅하지 않음
        }
    }
    
    private func setTextColor(with message: LogConsoleMessage) {
        if message.logType == .verbose {
            [timeLabel, msgLabel].forEach {
                $0.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
            }
        } else {
            [timeLabel, msgLabel].forEach { $0.textColor = .black }
        }
    }
    
    private func setBackgroundColor(with message: LogConsoleMessage) {
        switch message.logType {
        case .verbose, .debug:
            contentView.backgroundColor = .white
        case .info:
            contentView.backgroundColor = UIColor(red: 1, green: 0.95, blue: 0.6, alpha: 1)
        case .warning:
            contentView.backgroundColor = UIColor(red: 1, green: 0.69, blue: 0.5, alpha: 1)
        case .error:
            contentView.backgroundColor = UIColor(red: 0.98, green: 0.45, blue: 0.38, alpha: 1)
        }
    }
}
