//
//  LogConsoleViewModel.swift
//  EventLogger
//

import Combine
import UIKit

final class LogConsoleViewModel {

    @Published var miniModePos = CGPoint(x: 20, y: 200)
    @Published var expandModePos = CGPoint(x: 20, y: 200)
    @Published var viewMode = LogConsoleViewMode.mini
    @Published private(set) var logMessageUpdated: Void = ()
    
    var lastLogMessageIndexPath: IndexPath? {
        let totalCount = dataSource.snapshot().numberOfItems
        return totalCount == 0 ? nil : IndexPath(row: totalCount - 1, section: LogConsoleTableSection.main.rawValue)
    }
    
    private var dataSource: LogConsoleTableViewDataSource
    private let expandedMessageHeightCache = Cache<UUID, CGFloat>()
    var isBindCompleted = false
    
    private let memoryTestCase = MemoryTestCase()
    
    init(dataSource: LogConsoleTableViewDataSource) {
        self.dataSource = dataSource
        
        var snapShot = LogConsoleTableViewSnapShot()
        snapShot.appendSections([.main])
        self.dataSource.apply(snapShot)
    }
    
    func logMessage(at indexPath: IndexPath) -> LogConsoleMessage? {
        dataSource.itemIdentifier(for: indexPath)
    }
    
    func addLogMessages(_ messages: [LogConsoleMessage]) {
        DispatchQueue.main.async {
            var snapShot = self.dataSource.snapshot()
            snapShot.appendItems(messages)
            self.dataSource.apply(snapShot)
            
            self.logMessageUpdated = ()
        }
    }
    
    func removeAllMessages() {
        var snapShot = self.dataSource.snapshot()
        snapShot.deleteAllItems()
        snapShot.appendSections([.main])
        dataSource.apply(snapShot)
    }
    
    func refreshLogMessage(_ message: LogConsoleMessage) {
        var snapShot = dataSource.snapshot()
        snapShot.reloadItems([message])
        dataSource.apply(snapShot)
    }
    
    func calcExpandedMessageHeight(_ message: LogConsoleMessage, constrainedWidth: CGFloat, constrainedHeight: CGFloat) -> CGFloat {
        if let cachedHeight = expandedMessageHeightCache.value(forKey: message.uuid) {
            return cachedHeight
        } else {
            let tempLabel = LogConsoleTableViewCell.tempLabelForCalcHeight
            tempLabel.text = message.expandedMessage
            
            let labelWidthPadding = LogConsoleTableViewCell.detailLabelLeadingConstant * 2 + tempLabel.padding.left + tempLabel.padding.right
            let labelHeightPadding = tempLabel.padding.top + tempLabel.padding.bottom
            
            var height = tempLabel.textSize(forWidth: constrainedWidth - labelWidthPadding).height + labelHeightPadding
            height += LogConsoleTableViewCell.height
            height = min(height, 1000)
            height = min(height, constrainedHeight - 50)
            
            expandedMessageHeightCache.insert(height, forKey: message.uuid)
            return height
        }
    }
    
    // MARK: - Memory
    
    func excuteMemoryTracking() {
        memoryTestCase.testObjectAllocTracking()
    }
}


