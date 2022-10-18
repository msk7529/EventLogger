//
//  LogFilesTableViewController.swift
//  EventLogger
//
//  Created on 2022/10/18.
//

import UIKit

final class LogFilesTableViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var leftBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didSelectCloseButton))
        return button
    }()
    
    private lazy var rightBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "모두 삭제", style: .plain, target: self, action: #selector(didSelectDeleteButton))
        button.tintColor = .red
        return button
    }()
    
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
        //view.translatesAutoresizingMaskIntoConstraints = false  -> 주석 해제시 뷰컨이 이상하게 띄워짐

        navigationItem.setLeftBarButton(leftBarButtonItem, animated: true)
        navigationItem.setRightBarButton(rightBarButtonItem, animated: true)
        navigationItem.title = "Log Files"
        
        view.addSubview(fileTableView)
        
        fileTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
        fileTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        fileTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        fileTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    // MARK: Actions
    
    @objc
    private func didSelectDeleteButton() {
        let alertController = UIAlertController(title: "Log Files", message: "모두 삭제하시겠습니까?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let confirmAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.viewModel.removeAllFiles()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true)
    }
    
    @objc
    private func didSelectCloseButton() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate

extension LogFilesTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let previewFileItem = viewModel.createPreviewFileItem(at: indexPath) else { return }
        
        // 시뮬에서 크래시 날 수 있음
        if previewFileItem.canPreview {
            let previewController = FilePreviewController()
            previewController.previewFile = previewFileItem
            previewController.showOriginalFileName = true
            navigationController?.present(previewController, animated: true)
        } else {
            Log.error("Open Log File Failed. Path: \(previewFileItem.previewItemURL!)")
        }
    }
}

