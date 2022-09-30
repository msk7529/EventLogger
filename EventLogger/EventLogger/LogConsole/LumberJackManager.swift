//
//  LumberJackManager.swift
//  EventLogger
//

import CocoaLumberjackSwift
import Foundation

final class LumberJackManager {
    
    func setUpCocoaLumberJackLogger() {
        DDLog.removeAllLoggers()
        
        let osLogger = CustomDDOSLogger()
        DDLog.add(osLogger, with: .debug)
        
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
    }
}
