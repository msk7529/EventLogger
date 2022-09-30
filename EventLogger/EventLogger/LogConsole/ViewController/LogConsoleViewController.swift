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
    
    private let performanceView: PerformanceView = {
        let view = PerformanceView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var logTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.delegate = self
        tableView.register(LogConsoleTableViewCell.self, forCellReuseIdentifier: LogConsoleTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
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
    
    private var currentFrame: CGRect?
    private var topConstraint: NSLayoutConstraint?
    private var leadingConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    private var widthConstraint: NSLayoutConstraint?
    
    private let miniViewWidth: CGFloat = 100
    private let miniViewHeight: CGFloat = 44
    
    private var dataSource: UITableViewDiffableDataSource<Section, LogConsoleMessage>!
    
    // MARK: - Life Cycle
    
    deinit {
        print("deinit LogConsoleViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.black.cgColor
        view.backgroundColor = .red
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
        view.addSubview(performanceView)
        view.addSubview(logTableView)
        
        performanceView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        performanceView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        performanceView.heightAnchor.constraint(equalToConstant: miniViewHeight).isActive = true
        
        logTableView.topAnchor.constraint(equalTo: performanceView.bottomAnchor).isActive = true
        logTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        logTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        logTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
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
        snapShot.appendItems([LogConsoleMessage(message: "test")])
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
        
        topConstraint = view.topAnchor.constraint(equalTo: window.topAnchor, constant: LoggerManager.miniModePosition.y)     // 여기를 window.safeAreaLayoutGuide.topAnchor로 주면 팬제스처 시에 버벅이게 된다.
        leadingConstraint = view.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: LoggerManager.miniModePosition.x)
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
            
            let pos = LoggerManager.miniModePosition

            self.leadingConstraint?.constant = pos.x
            self.topConstraint?.constant = pos.y
            self.heightConstraint?.constant = self.viewSize.height
            self.widthConstraint?.constant = self.viewSize.width
            superView.layoutIfNeeded()  // 미호출시 애니메이션 적용 안 됨
        } completion: { _ in
            
        }
    }
    
    private func expand() {
        UIView.animate(withDuration: 0.2) {
            guard let superView = self.view.superview else { return }
            
            let pos = LoggerManager.expandModePosition
            
            self.leadingConstraint?.constant = pos.x
            self.topConstraint?.constant = pos.y
            self.heightConstraint?.constant = self.viewSize.height
            self.widthConstraint?.constant = self.viewSize.width
            superView.layoutIfNeeded()  // 미호출시 애니메이션 적용 안 됨
        } completion: { _ in
            
        }
    }
    
    // MARK: - Helper
    
    private func addGestureRecognizer() {
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didReceivePanAction(_:))))
        performanceView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didReceiveTapAction(_:))))
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
                LoggerManager.miniModePosition = view.frame.origin
            } else if viewMode == .expanded {
                LoggerManager.expandModePosition = view.frame.origin
            }
        default:
            return
        }
    }
    
    @objc
    private func didReceiveTapAction(_ sender: UITapGestureRecognizer) {
        if sender.view === performanceView {
            viewMode.toggle()
        }
    }
}

extension LogConsoleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
}
