//
//  LogFileManager.swift
//  EventLogger
//
//  Created on 2022/10/13.
//

import Foundation

final class LogFileManager {
    
    let shared = LogFileManager()
    
    /* /Users/lehends/Library/Developer/CoreSimulator/Devices/B1629A29-F3B1-41D3-A08A-B8130A478C36/data/Containers/Data/Application/12AE26AC-9A6A-4897-93CC-61E84BB0CBB4/Documents/Logs */
    static let logFileDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("Logs")
    
    
    private init() {
        
    }
    
    private func removeOldLogFiles() {
        
    }
}
