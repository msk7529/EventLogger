//
//  LogFileManager.swift
//  EventLogger
//
//  Created on 2022/10/13.
//

import Foundation

final class LogFileManager {
    
    static let shared = LogFileManager()
    
    /* /Users/lehends/Library/Developer/CoreSimulator/Devices/B1629A29-F3B1-41D3-A08A-B8130A478C36/data/Containers/Data/Application/12AE26AC-9A6A-4897-93CC-61E84BB0CBB4/Documents/Logs */
    static let logFileDirectory =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0].appending(pathComponent: "Logs")
    
    static var logPreviewDirectory: String? {
        guard let dirPath = ((NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)).last?.appending(pathComponent: "PreviewFiles")) else {
            return nil
        }  // 공통으로 사용하면 외부로 빼도 될 듯? LinkProperty
        
        FileUtility.directoryExists(at: dirPath, createIfNotExist: true)
        return dirPath
    }
    
    var logFilesList: [String] {
        let files = try? FileManager.default.contentsOfDirectory(atPath: Self.logFileDirectory)
        return files ?? []
    }
    
    
    private init() { }
    
    func removeOldLogFiles() {
        // 일주일이 지난 로그 파일들을 지운다.
        let weekTimeInterval: TimeInterval = 24 * 3600 * 7
        
        for fileName in LogFileManager.shared.logFilesList {
            let filePath = LogFileManager.logFileDirectory.appending(pathComponent: fileName)
            let properties = try? FileManager.default.attributesOfItem(atPath: filePath)
            let modDate = properties?[FileAttributeKey.modificationDate] as? Date
            
            if let modDate = modDate, modDate.timeIntervalSinceNow < -weekTimeInterval {
                removeFile(filePath)
            }
        }
    }
    
    private func removeFile(_ filePath: String) {
        do {
            try FileManager.default.removeItem(atPath: filePath)
            Log.verbose("Remove LumberJack Log File: \(filePath)")
        } catch {
            Log.error("Error in Remove LumberJack Log File: \(filePath)")
        }
    }
    
    static func filePreviewDirectoryPath(with path: String) -> String? {
        Self.logPreviewDirectory?.appending(pathComponent: path)
    }
}
