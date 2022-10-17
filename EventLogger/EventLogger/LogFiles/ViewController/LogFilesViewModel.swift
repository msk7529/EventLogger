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
}
