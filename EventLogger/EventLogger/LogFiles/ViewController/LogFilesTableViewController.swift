//
//  LogFilesTableViewController.swift
//  EventLogger
//
//  Created on 2022/10/18.
//

import UIKit

final class LogFilesTableViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var fileTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.delegate = self
        tableView.register(LogFilesTableViewCell.self, forCellReuseIdentifier: LogFilesTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 58
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    @LateInit
    private var viewModel: LogFilesViewModel
    
    // MARK: - Life Cycles
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        viewModel = LogFilesViewModel(dataSource: LogFilesTableViewDataSource(tableView: fileTableView))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        
        viewModel.showList()
    }
    
    // MARK: - UI
    
    private func initView() {
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(fileTableView)
        
        fileTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        fileTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        fileTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        fileTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

extension LogFilesTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

