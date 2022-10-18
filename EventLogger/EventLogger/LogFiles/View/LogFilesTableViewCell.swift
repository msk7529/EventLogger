//
//  LogFilesTableViewCell.swift
//  EventLogger
//
//  Created on 2022/10/18.
//

import UIKit

final class LogFilesTableViewCell: UITableViewCell {
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sizeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 40.0 / 255.0, green: 108.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0)
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let seperatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    static let identifier = "LogFilesTableViewCell"
    
    private var filePath: String {
        LogFileManager.logFileDirectory.appending(pathComponent: fileName)  // 이 부분 그냥 LogFileManage에서 fileName 파라미터로 받아서 리턴하도록 해도 될 듯
    }
    
    private var fileSize: String {
        FileUtility.fileSizeString(with: FileUtility.fileSize(at: filePath))
    }
    
    var fileName: String = "" {
        didSet {
            nameLabel.text = fileName
            sizeLabel.text = fileSize
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(sizeLabel)
        contentView.addSubview(seperatorLine)
        
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        
        sizeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3).isActive = true
        sizeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        sizeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        
        seperatorLine.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        seperatorLine.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        seperatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}
