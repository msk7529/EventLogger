//
//  LogFilesViewModel.swift
//  EventLogger
//
//  Created on 2022/10/18.
//

import Foundation

final class LogFilesViewModel {
    
    private var logFilesList: [String] {
        LogFileManager.shared.logFilesList.sorted(by: >)
    }
    
    private var dataSource: LogFilesTableViewDataSource
    
    init(dataSource: LogFilesTableViewDataSource) {
        self.dataSource = dataSource
        
        var snapShot = LogFilesTableViewSnapShot()
        snapShot.appendSections([.main])
        self.dataSource.apply(snapShot)
    }
    
    func showList() {
        var snapShot = dataSource.snapshot()
        snapShot.appendItems(logFilesList)
        dataSource.apply(snapShot)
    }
    
    func removeAllFiles() {
        for file in logFilesList {
            let filePath = LogFileManager.logFileDirectory.appending(pathComponent: file)
            FileUtility.deleteFile(at: filePath)
        }
        
        var snapShot = dataSource.snapshot()
        snapShot.deleteAllItems()
        dataSource.apply(snapShot)
    }
    
    func createPreviewFileItem(at indexPath: IndexPath) -> PreviewFileItem? {
        guard let fileName = dataSource.itemIdentifier(for: indexPath) else { return nil }
        let filePath = URL(fileURLWithPath: LogFileManager.logFileDirectory).appendingPathComponent(fileName)
        return PreviewFileItem(fileName: fileName, filePath: filePath)
    }
}
