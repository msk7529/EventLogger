//
//  LogConsoleViewController.swift
//  EventLogger
//
//  Created by on 2022/09/15.
//

import Combine
import UIKit

final public class LogConsoleViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var topContainerView: LogConsoleTopContainerView = {
        let view = LogConsoleTopContainerView()
        view.addTapHandler { [weak self] in
            self?.viewModel.viewMode.toggle()
        }
        view.translatesAutoresizingMaskIntoConstraints = false
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
        view.didTapButton = { [weak self] buttonType in
            self?.didTapBottomContainerButton(buttonType: buttonType)
        }
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var windowSize: CGSize {
        guard let window = view.window else {
            return UIScreen.main.bounds.size
        }
        return window.bounds.size
    }
    
    private var safeAreaInsets: UIEdgeInsets {
        var safeAreaInsets: UIEdgeInsets = .zero
        safeAreaInsets.top = max(20, view.superview?.safeAreaInsets.top ?? 0)
        safeAreaInsets.bottom = view.superview?.safeAreaInsets.bottom ?? 0
        safeAreaInsets.left = view.superview?.safeAreaInsets.left ?? 0
        safeAreaInsets.right = view.superview?.safeAreaInsets.right ?? 0
        return safeAreaInsets
    }
    
    public static let shared = LogConsoleViewController()
    
    @LateInit
    private(set) var viewModel: LogConsoleViewModel
    
    private var currentFrame: CGRect?
    private var topConstraint: NSLayoutConstraint?
    private var leadingConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    private var widthConstraint: NSLayoutConstraint?
    private var tableViewBottomConstraint: NSLayoutConstraint?

    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Life Cycles
    
    private init() {
        super.init(nibName: nil, bundle: nil)
        
        viewModel = LogConsoleViewModel(dataSource: LogConsoleTableViewDataSource(tableView: logTableView))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        addObservers()
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didReceivePanAction(_:))))
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.black.cgColor
    }
    
    // MARK: - UI
    
    private func initView() {
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(topContainerView)
        view.addSubview(logTableView)
        view.addSubview(bottomContainerView)

        topContainerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topContainerView.heightAnchor.constraint(equalToConstant: getViewSize(with: .mini).height).isActive = true
        
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
    
    private func bindViewModel() {
        viewModel.$miniModePos
            .dropFirst()
            .sink { [weak self] pos in
                self?.topConstraint?.constant = pos.y
                self?.leadingConstraint?.constant = pos.x
            }.store(in: &subscriptions)
        
        viewModel.$expandModePos
            .dropFirst()
            .sink { [weak self] pos in
                self?.topConstraint?.constant = pos.y
                self?.leadingConstraint?.constant = pos.x
            }.store(in: &subscriptions)
        
        viewModel.$viewMode
            .dropFirst()
            .sink { [weak self] viewMode in
                self?.adjustViewMode(to: viewMode)
            }.store(in: &subscriptions)
        
        viewModel.$logMessageUpdated
            .sink { [weak self] in
                // 메시지 업데이트시 최하단으로 강제 이동.... 개선필요 > TODO(lehends)
                self?.scrollToBottom()
            }.store(in: &subscriptions)
        
        viewModel.isBindCompleted = true
    }

    public func setConstraints(with window: UIWindow) {
        // 앱 윈도우의 rootVC가 변경될 때 마다 메서드를 수행하지 않으면 Constraints 틀어짐 발생
        [topConstraint, leadingConstraint, heightConstraint, widthConstraint].compactMap { $0 }.forEach {
            view.removeConstraint($0)
        }
        
        let viewSize = getViewSize(with: .mini)
        topConstraint = view.topAnchor.constraint(equalTo: window.topAnchor, constant: viewModel.miniModePos.y)  // 제약을 window.safeAreaLayoutGuide.topAnchor로 주면 팬제스처 시에 버벅이게 된다.
        leadingConstraint = view.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: viewModel.miniModePos.x)
        heightConstraint = view.heightAnchor.constraint(equalToConstant: viewSize.height)
        widthConstraint = view.widthAnchor.constraint(equalToConstant: viewSize.width)
        
        [topConstraint, leadingConstraint, heightConstraint, widthConstraint].forEach { $0?.isActive = true }
        
        adjustViewMode(to: viewModel.viewMode)
        
        if !viewModel.isBindCompleted {
            bindViewModel()
        }
    }
    
    private func getViewSize(with viewMode: LogConsoleViewMode) -> CGSize {
        switch viewMode {
        case .mini:
            return CGSize(width: 100, height: 44)
        case .expanded:
            return CGSize(width: windowSize.width * CGFloat(0.7), height: windowSize.height * CGFloat(0.6))
        }
    }
    
    private func calculateRightViewPosition(from pos: CGPoint) -> CGPoint {
        // 로그콘솔이 화면 밖을 벗어나지 못하도록 위치를 재조정. expand 상태에서는 편의를 위해 화면을 벗어날 수 있도록 처리
        var resultPos = pos
        let safeAreaInsets = safeAreaInsets
        let miniViewSize = getViewSize(with: .mini)

        resultPos.x = max(pos.x, safeAreaInsets.left)
        resultPos.x = min(resultPos.x, windowSize.width - miniViewSize.width - safeAreaInsets.right)
        resultPos.y = max(pos.y, safeAreaInsets.top)
        resultPos.y = min(resultPos.y, windowSize.height - miniViewSize.height - safeAreaInsets.bottom)
        return resultPos
    }
    
    private func adjustViewMode(to viewMode: LogConsoleViewMode) {
        UIView.animate(withDuration: 0.2) {
            guard let superView = self.view.superview else { return }
            
            let pos = viewMode == .mini ? self.viewModel.miniModePos : self.viewModel.expandModePos
            let viewSize = self.getViewSize(with: viewMode)
            self.leadingConstraint?.constant = pos.x
            self.topConstraint?.constant = pos.y
            self.heightConstraint?.constant = viewSize.height
            self.widthConstraint?.constant = viewSize.width
            self.tableViewBottomConstraint?.constant = viewMode == .mini ? 0 : -LogConsoleBottomContainerView.height
            self.logTableView.isHidden = viewMode == .mini ? true : false
            self.bottomContainerView.isHidden = viewMode == .mini ? true : false
            self.topContainerView.changeViewMode(to: viewMode)
            superView.layoutIfNeeded()  // 미호출시 애니메이션 적용 안 됨
        } completion: { _ in
            if viewMode == .expanded {
                self.scrollToBottom()
            }
        }
    }
    
    private func scrollToBottom() {
        guard let lastIndex = viewModel.lastLogMessageIndexPath else { return }
        logTableView.scrollToRow(at: lastIndex, at: .bottom, animated: true)
    }
    
    // MARK: - Observers
    
    private func addObservers() {
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: nil) { [weak self] _ in
            guard let self = self, self.viewModel.viewMode == .expanded else { return }
            self.viewModel.viewMode.toggle()
        }
    }
    
    // MARK: - Actions
    
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
            view.frame = destFrame
        case .ended:
            switch viewModel.viewMode {
            case .mini:
                viewModel.miniModePos = view.frame.origin
            case .expanded:
                viewModel.expandModePos = view.frame.origin
            }
        default:
            return
        }
    }
    
    private func didTapBottomContainerButton(buttonType: LogConsoleBottomContainerView.ButtonType) {
        switch buttonType {
        case .clear:
            viewModel.removeAllMessages()
        case .more:
            guard let rootVC = (view?.window as? MainWindow)?.visibleViewController else { return }
            let alertControoler = UIAlertController(title: nil, message: "More", preferredStyle: .actionSheet)
            let showLogFileAction = UIAlertAction(title: "Log Files", style: .default) { _ in
                let naviVC = UINavigationController(rootViewController: LogFilesTableViewController())
                naviVC.modalPresentationStyle = .fullScreen
                rootVC.present(naviVC, animated: true)
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            alertControoler.addAction(showLogFileAction)
            alertControoler.addAction(cancelAction)
            rootVC.present(alertControoler, animated: true)
        case .memoryTest:
            viewModel.excuteMemoryTracking()
        }
    }
}

extension LogConsoleViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let logMessage = viewModel.logMessage(at: indexPath) else {
            return LogConsoleTableViewCell.height
        }
        
        if logMessage.isExpanded {
            return viewModel.calcExpandedMessageHeight(logMessage, constrainedWidth: tableView.frame.width, constrainedHeight: tableView.frame.height)
        } else {
            return LogConsoleTableViewCell.height
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let logMessage = viewModel.logMessage(at: indexPath) else { return }
        
        logMessage.isExpanded.toggle()
                
        viewModel.refreshLogMessage(logMessage)
    }
}
