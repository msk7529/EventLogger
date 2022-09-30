//
//  LogConsoleViewController.swift
//  EventLogger
//
//  Created by on 2022/09/15.
//

import UIKit

final class LogConsoleViewController: UIViewController {

    // MARK: - Properties
    
    static let shared = LogConsoleViewController()
    
    private enum Section {
        case main
    }
    
    private let topContainerView: LogConsoleTopContainerView = {
        let view = LogConsoleTopContainerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var logTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.delegate = self
        tableView.register(LogConsoleTableViewCell.self, forCellReuseIdentifier: LogConsoleTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.isHidden = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var bottomContainerView: LogConsoleBottomContainerView = {
        let view = LogConsoleBottomContainerView()
        view.isHidden = true
        view.didTapButton = { [weak self] buttonType in
            self?.didTapBottomContainerButton(buttonType: buttonType)
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var windowSize: CGSize {
        if let window = view.window {
            return window.bounds.size
        }
        return UIScreen.main.bounds.size
    }
    
    private var safeAreaInsets: UIEdgeInsets {
        var safeAreaInsets: UIEdgeInsets = .zero
        safeAreaInsets.top = max(20, self.view.superview?.safeAreaInsets.top ?? 0)
        safeAreaInsets.bottom = self.view.superview?.safeAreaInsets.bottom ?? 0
        safeAreaInsets.left = self.view.superview?.safeAreaInsets.left ?? 0
        safeAreaInsets.right = self.view.superview?.safeAreaInsets.right ?? 0
        return safeAreaInsets
    }
    
    private var viewSize: CGSize {
        if viewMode == .mini {
            return CGSize(width: miniViewWidth, height: miniViewHeight)
        } else {
            return CGSize(width: windowSize.width * CGFloat(0.7), height: windowSize.height * CGFloat(0.6))
        }
    }
    
    private var viewMode: LogConsoleViewMode = .mini {
        didSet {
            if viewMode == .mini {
                minimize()
            } else if viewMode == .expanded {
                expand()
            }
        }
    }
    
    private var miniModePosition: CGPoint {
        get {
            guard let pos = UserDefaults.standard.value(forKey: "miniModePosition") as? String else {
                return CGPoint(x: 20, y: 200)
            }
            return NSCoder.cgPoint(for: pos)
        }
        set {
            UserDefaults.standard.setValue(NSCoder.string(for: newValue), forKey: "miniModePosition")
        }
    }
    
    private var expandModePosition: CGPoint {
        get {
            guard let pos = UserDefaults.standard.value(forKey: "expandModePosition") as? String else {
                return CGPoint(x: 20, y: 200)
            }
            return NSCoder.cgPoint(for: pos)
        }
        set {
            UserDefaults.standard.setValue(NSCoder.string(for: newValue), forKey: "expandModePosition")
        }
    }
    
    private var currentFrame: CGRect?
    private var topConstraint: NSLayoutConstraint?
    private var leadingConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    private var widthConstraint: NSLayoutConstraint?
    
    private var tableViewBottomConstraint: NSLayoutConstraint?
    
    private let miniViewWidth: CGFloat = 100
    private let miniViewHeight: CGFloat = 44
    
    private var dataSource: UITableViewDiffableDataSource<Section, LogConsoleMessage>!
    
    // MARK: - Life Cycle
    
    deinit {
        print("deinit LogConsoleViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.black.cgColor
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        initView()
        initTableView()
        addGestureRecognizer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - UI
    
    private func initView() {
        view.addSubview(topContainerView)
        view.addSubview(logTableView)
        view.addSubview(bottomContainerView)
        
        topContainerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topContainerView.heightAnchor.constraint(equalToConstant: miniViewHeight).isActive = true
        
        logTableView.topAnchor.constraint(equalTo: topContainerView.bottomAnchor).isActive = true
        logTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        logTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableViewBottomConstraint = logTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        tableViewBottomConstraint?.isActive = true
        
        bottomContainerView.topAnchor.constraint(equalTo: logTableView.bottomAnchor).isActive = true
        bottomContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func initTableView() {
        dataSource = .init(tableView: logTableView, cellProvider: { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LogConsoleTableViewCell.identifier, for: indexPath) as? LogConsoleTableViewCell else {
                return UITableViewCell()
            }
            
            cell.message = itemIdentifier
            return cell
        })
        
        logTableView.dataSource = dataSource
        
        var snapShot = NSDiffableDataSourceSnapshot<Section, LogConsoleMessage>()
        snapShot.appendSections([.main])
        dataSource.apply(snapShot)
    }
    
    func setConstraints(with window: UIWindow) {
        /*
        let topConstraint = NSLayoutConstraint(item: logConsoleVC.view as Any, attribute: .top, relatedBy: .equal, toItem: logConsoleVC.view.superview, attribute: .top, multiplier: 1, constant: 30)
        let leadingConstraint = NSLayoutConstraint(item: logConsoleVC.view as Any, attribute: .leading, relatedBy: .equal, toItem: logConsoleVC.view.superview, attribute: .leading, multiplier: 1, constant: 10)
        let widthConstarint = NSLayoutConstraint(item: logConsoleVC.view as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        let heightConstarint = NSLayoutConstraint(item: logConsoleVC.view as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100)
        window.addConstraint(leadingConstraint)
        window.addConstraint(topConstraint)

        logConsoleVC.view.addConstraint(widthConstarint)
        logConsoleVC.view.addConstraint(heightConstarint)
         */
        
        topConstraint = view.topAnchor.constraint(equalTo: window.topAnchor, constant: miniModePosition.y)     // 여기를 window.safeAreaLayoutGuide.topAnchor로 주면 팬제스처 시에 버벅이게 된다.
        leadingConstraint = view.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: miniModePosition.x)
        heightConstraint = view.heightAnchor.constraint(equalToConstant: viewSize.height)
        widthConstraint = view.widthAnchor.constraint(equalToConstant: viewSize.width)
        
        [topConstraint, leadingConstraint, heightConstraint, widthConstraint].forEach {
            $0?.isActive = true
        }

        // window.bringSubviewToFront(LogConsoleVC.view)
    }
    
    private func calculateRightViewPosition(from pos: CGPoint) -> CGPoint {
        // 로그콘솔이 화면 밖을 벗어나지 못하도록 위치를 재조정. expand 상태에서는 편의를 위해 화면을 벗어날 수 있도록 처리.
        var resultPos = pos
        let safeAreaInsets = safeAreaInsets

        resultPos.x = max(pos.x, safeAreaInsets.left)
        resultPos.x = min(resultPos.x, windowSize.width - miniViewWidth - safeAreaInsets.right)
        resultPos.y = max(pos.y, safeAreaInsets.top)
        resultPos.y = min(resultPos.y, windowSize.height - safeAreaInsets.bottom - miniViewHeight)
        return resultPos
    }
    
    private func minimize() {
        UIView.animate(withDuration: 0.2) {
            guard let superView = self.view.superview else { return }
            
            let pos = self.miniModePosition

            self.leadingConstraint?.constant = pos.x
            self.topConstraint?.constant = pos.y
            self.heightConstraint?.constant = self.viewSize.height
            self.widthConstraint?.constant = self.viewSize.width
            self.tableViewBottomConstraint?.constant = 0
            self.logTableView.isHidden = true
            self.bottomContainerView.isHidden = true
            superView.layoutIfNeeded()  // 미호출시 애니메이션 적용 안 됨
        } completion: { _ in
            
        }
    }
    
    private func expand() {
        UIView.animate(withDuration: 0.2) {
            guard let superView = self.view.superview else { return }
            
            let pos = self.expandModePosition
            
            self.leadingConstraint?.constant = pos.x
            self.topConstraint?.constant = pos.y
            self.heightConstraint?.constant = self.viewSize.height
            self.widthConstraint?.constant = self.viewSize.width
            self.tableViewBottomConstraint?.constant = -self.miniViewHeight
            self.logTableView.isHidden = false
            self.bottomContainerView.isHidden = false
            superView.layoutIfNeeded()  // 미호출시 애니메이션 적용 안 됨
        } completion: { _ in
            
        }
    }
    
    // MARK: - Helper
    
    private func addGestureRecognizer() {
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didReceivePanAction(_:))))
        topContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didReceiveTapAction(_:))))
    }
    
    func addLogs(logs: [LogConsoleMessage]) {
        guard LogConsole.isRunning else {
            Logger.xcode.errorLog("LogConsole is not running!!")
            return
        }
        
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(logs)
        dataSource.apply(snapshot, animatingDifferences: true)
        
        setContentOffsetProperty()
    }
    
    private func setContentOffsetProperty() {
        if logTableView.frame.size.height <= logTableView.contentSize.height {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let currentOffset = self.logTableView.contentOffset
                self.logTableView.setContentOffset(CGPoint(x: currentOffset.x, y: currentOffset.y + LogConsoleTableViewCell.height), animated: true)
            }
        }
    }

    // MARK: - Action
    
    @objc
    private func didReceivePanAction(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            currentFrame = view.frame
        case .changed:
            guard let currentFrame = currentFrame else { return }
            
            let offset = sender.translation(in: view.superview)
            var destFrame = currentFrame.offsetBy(dx: offset.x, dy: offset.y)
            destFrame.origin = calculateRightViewPosition(from: destFrame.origin)
            topConstraint?.constant = destFrame.minY
            leadingConstraint?.constant = destFrame.minX
            view.frame = destFrame
        case .ended:
            if viewMode == .mini {
                miniModePosition = view.frame.origin
            } else if viewMode == .expanded {
                expandModePosition = view.frame.origin
            }
        default:
            return
        }
    }
    
    @objc
    private func didReceiveTapAction(_ sender: UITapGestureRecognizer) {
        if sender.view === topContainerView {
            viewMode.toggle()
        }
    }
    
    private func didTapBottomContainerButton(buttonType: LogConsoleBottomContainerView.ButtonType) {
        switch buttonType {
        case .clear:
            var snapShot = dataSource.snapshot()
            snapShot.deleteAllItems()
            snapShot.appendSections([.main])
            dataSource.apply(snapShot)
        }
    }
}

extension LogConsoleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LogConsoleTableViewCell.height
    }
}
