//
//  PerformanceView.swift
//  EventLogger
//
//  Created by on 2022/09/16.
//

import Combine
import UIKit

final class PerformanceView: UIView, PerformanceMonitorDelegate {
    
    // MARK: - Properties
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.addArrangedSubview(cpuStackView)
        stackView.addArrangedSubview(fpsStackView)
        stackView.addArrangedSubview(memoryStackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var cpuHeaderLabel: UILabel = {
        let label = createHeaderLabel(with: "CPU")
        return label
    }()
    
    private lazy var cpuStatusLabel: UILabel = {
        let label = createStateLabel()
        return label
    }()
    
    private lazy var cpuStackView: UIStackView = {
        let stackView = createHStackView(headerLabel: cpuHeaderLabel, statusLabel: cpuStatusLabel)
        return stackView
    }()
    
    private lazy var fpsHeaderLabel: UILabel = {
        let label = createHeaderLabel(with: "FPS")
        return label
    }()
    
    private lazy var fpsStatusLabel: UILabel = {
        let label = createStateLabel()
        return label
    }()
    
    private lazy var fpsStackView: UIStackView = {
        let stackView = createHStackView(headerLabel: fpsHeaderLabel, statusLabel: fpsStatusLabel)
        return stackView
    }()
    
    private lazy var memoryHeaderLabel: UILabel = {
        let label = createHeaderLabel(with: "MEM")
        return label
    }()
    
    private lazy var memoryStatusLabel: UILabel = {
        let label = createStateLabel()
        return label
    }()
    
    private lazy var memoryStackView: UIStackView = {
        let stackView = createHStackView(headerLabel: memoryHeaderLabel, statusLabel: memoryStatusLabel)
        return stackView
    }()
    
    private var applicationVersion: String {
        var applicationVersion = "<null>"
        var applicationBuildNumber = "<null>"
        if let infoDictionary = Bundle.main.infoDictionary {
            if let versionNumber = infoDictionary["CFBundleShortVersionString"] as? String {
                applicationVersion = versionNumber
            }
            if let buildNumber = infoDictionary["CFBundleVersion"] as? String {
                applicationBuildNumber = buildNumber
            }
        }
        return "app v\(applicationVersion) (\(applicationBuildNumber))"
    }
    
    private var osVersion: String {
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        return "\(systemName) v\(systemVersion)"
    }
    
    private var performanceReportSubject: PassthroughSubject<PerformanceReport, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = .init()
    
    // MARK: - UI
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemGray2
        
        initView()
        bind()
        
        PerformanceMonitor.shared.delegate = self
        PerformanceMonitor.shared.start()   // 모니터링 시작
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.backgroundColor = UIColor.black.cgColor
        layer.borderWidth = 2
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        let reports = PerformanceMonitor.shared.getLastReports(duration: Int(frame.width))
        
        var strokeColor = UIColor.green.cgColor
        if reports.count > 20 {
            let average = Int(reports.map { min(100, $0.cpuUsage) }.reduce(0, +)) / reports.count
            if average > 90 {
                strokeColor = UIColor.red.cgColor
            } else if average > 50 {
                strokeColor = UIColor.orange.cgColor
            }
        }
        
        context.setStrokeColor(strokeColor)
        context.setLineWidth(1)

        for (index, report) in reports.enumerated() {
            context.move(to: CGPoint(x: index, y: Int(frame.height)))
            let viewHeight = frame.height
            let posY = min(Int(viewHeight - 2), Int(viewHeight - round(viewHeight * CGFloat(report.cpuUsage / 100))))
            context.addLine(to: CGPoint(x: index, y: posY))
            context.strokePath()
        }
    }
    
    private func initView() {
        addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
    }
    
    private func createHeaderLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 8.0)
        label.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 25).isActive = true
        return label
    }
    
    private func createStateLabel() -> UILabel {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 7.0)
        label.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        label.textAlignment = .center
        label.lineBreakMode = .byClipping
        let widthConstraint = label.widthAnchor.constraint(equalToConstant: 40)
        widthConstraint.priority = .defaultHigh
        widthConstraint.isActive = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createHStackView(headerLabel: UILabel, statusLabel: UILabel) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 1
        stackView.addArrangedSubview(headerLabel)
        stackView.addArrangedSubview(statusLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    // MARK: - Helper
    
    private func bind() {
        performanceReportSubject.sink { [weak self] report in
            guard let `self` = self else { return }
            self.cpuStatusLabel.text = "\(round(report.cpuUsage))%"
            self.fpsStatusLabel.text = "\(report.fps)"
            self.memoryStatusLabel.text = "\(round(Double(report.memoryUsage.used / (1024 * 1024))))MB"
        }.store(in: &subscriptions)
    }
    
    // MARK: - PerformanceMonitorDelegate
    
    func performanceMonitor(didReport performanceReport: PerformanceReport) {
        performanceReportSubject.send(performanceReport)
        
        func makeLogString(_ average: Int, _ duration: Int) -> String {
            let cpuUsageLogString: String = PerformanceMonitor.shared.cpuUsagePerThread().reduce("") {
                $0 + "\($1.0) ==> \(String(format: "%.1f%%", $1.1))\n"
            }
            let logString = "[CPU] The average CPU usage is \(average)%!!! (\(duration)sec, \(cpuUsageLogString.count))\n\n\(cpuUsageLogString)"
            return logString
        }
        
        setNeedsDisplay()   // draw 메서드를 호출하여 CPU 상태를 실시간으로 보여준다.
        
        let reports = PerformanceMonitor.shared.getLastReports(duration: 15)
        if reports.count == 15, let last = reports.last?.cpuUsage, last > 50.0 {
            
            print(String(format: "[CPU] The average CPU usage is %.1f%%!!!", last))
            // LogConsole.verbose(String(format: "[CPU] The average CPU usage is %.1f%%!!!", last))

            let average = Int(reports.map { min(100, $0.cpuUsage) }.reduce(0, +)) / 15
            
            DispatchQueue.global().async {
                if average > 90 {
                    let logString = makeLogString(average, 15)
                    print(logString)
                    // LogConsole.error(logString)
                } else if average > 70 {
                    let logString = makeLogString(average, 15)
                    print(logString)
                    // LogConsole.warning(logString)
                }
            }
        }
    }

}
