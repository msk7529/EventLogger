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
        let osLogFormatter = DefaultLogFormatter()
        osLogger.logFormatter = osLogFormatter
        DDLog.add(osLogger, with: .debug)
        
        let ddLogFileManager = DDLogFileManagerDefault(logsDirectory: LogFileManager.logFileDirectory)
        let fileLogger = DDFileLogger(logFileManager: ddLogFileManager)
        let fileLogFormatter = DefaultLogFormatter()
        fileLogFormatter.useTimeStamp = true
        fileLogger.rollingFrequency = 60 * 60 * 24  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 30;
        fileLogger.logFileManager.logFilesDiskQuota = 1024 * 1024 * 1024; // 1GB
        fileLogger.logFormatter = fileLogFormatter
        DDLog.add(fileLogger, with: .debug)
        
        Log.info("log directory: \(LogFileManager.logFileDirectory)")
        
        LogFileManager.shared.removeOldLogFiles()
    }
}
