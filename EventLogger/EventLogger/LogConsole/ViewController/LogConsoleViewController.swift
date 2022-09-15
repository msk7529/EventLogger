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
    
    private let testLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.text = "테스트"
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
            return CGSize(width: 68, height: 44)
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
    
    // MARK: - Life Cycle
    
    deinit {
        print("deinit LogConsoleViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        
        initView()
        addGestureRecognizer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - UI
    
    private func initView() {
        view.addSubview(testLabel)
        
        testLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        testLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
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
        
        topConstraint = view.topAnchor.constraint(equalTo: window.topAnchor, constant: Logger.miniModePosition.y)     // 여기를 window.safeAreaLayoutGuide.topAnchor로 주면 팬제스처 시에 버벅이게 된다.
        leadingConstraint = view.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: Logger.miniModePosition.x)
        heightConstraint = view.heightAnchor.constraint(equalToConstant: viewSize.height)
        widthConstraint = view.widthAnchor.constraint(equalToConstant: viewSize.width)
        
        [topConstraint, leadingConstraint, heightConstraint, widthConstraint].forEach {
            $0?.isActive = true
        }

        // window.bringSubviewToFront(LogConsoleVC.view)
    }
    
    private func calculateRightViewPosition(from pos: CGPoint) -> CGPoint {
        // 로그콘솔이 화면 밖을 벗어나지 못하도록 위치를 재조정
        var resultPos = pos
        let safeAreaInsets = safeAreaInsets

        resultPos.x = max(pos.x, safeAreaInsets.left)
        resultPos.x = min(resultPos.x, windowSize.width - viewSize.width - safeAreaInsets.right)
        resultPos.y = max(pos.y, safeAreaInsets.top)
        resultPos.y = min(resultPos.y, windowSize.height - safeAreaInsets.bottom - viewSize.height)
        return resultPos
    }
    
    private func minimize() {
        UIView.animate(withDuration: 0.2) {
            guard let superView = self.view.superview else { return }
            
            let pos = Logger.miniModePosition

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
            
            let pos = Logger.expandModePosition
            
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
        testLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didReceiveTapAction(_:))))
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
                Logger.miniModePosition = view.frame.origin
            } else if viewMode == .expanded {
                Logger.expandModePosition = view.frame.origin
            }
        default:
            return
        }
    }
    
    @objc
    private func didReceiveTapAction(_ sender: UITapGestureRecognizer) {
        if sender.view === testLabel {
            viewMode.toggle()
        }
    }
}
