//
//  CustomDDOSLogger.swift
//  EventLogger
//

import CocoaLumberjackSwift
import Foundation
import OSLog

@objc
final class CustomDDOSLogger: DDAbstractLogger {

    static let defaultCategory = adjustCategoryString("DEFAULT")
    static let subsystem = Bundle.main.bundleIdentifier!.replacingOccurrences(of: "com.msk7529.", with: "log.")
    static let defaultLog: OSLog = OSLog(subsystem: subsystem, category: defaultCategory)
        
    override var logFormatter: DDLogFormatter? {
        get {
            return super.logFormatter
        }
        set {
            super.logFormatter = newValue
            internalLogFormatter = newValue
        }
    }
    
    private var logDict: [String: OSLog] = [:]
    private var internalLogFormatter: DDLogFormatter?
    
    private static func adjustCategoryString(_ category: String) -> String {
        guard !category.isEmpty else {
            return ""
        }
        return category
    }

    private func fetchLog(_ category: String) -> OSLog {
        let category = Self.adjustCategoryString(category)
        guard !category.isEmpty else {
            return Self.defaultLog
        }

        if let log = logDict[category] {
            return log
        }

        let log = OSLog(subsystem: Self.subsystem, category: category)
        logDict[category] = log
        return log
    }

    override func log(message logMessage: DDLogMessage) {
        guard logMessage.fileName != "DDASLLogCapture" else { return }  // Skip captured log messages
        
        let originalMessage = logMessage.message
        let (category, message) = extractCategory(originalMessage)
        
        let targetLogMessage: DDLogMessage
        if category.isEmpty {
            targetLogMessage = logMessage
        } else {
            targetLogMessage = DDLogMessage(message: message,
                                            level: logMessage.level,
                                            flag: logMessage.flag,
                                            context: logMessage.context,
                                            file: logMessage.file,
                                            function: logMessage.function,
                                            line: logMessage.line,
                                            tag: logMessage.representedObject,
                                            options: logMessage.options,
                                            timestamp: logMessage.timestamp)
        }

        let formattedMessage = getFormattedMessage(from: targetLogMessage)
        printToConsole(log: fetchLog(category), logMessage: logMessage, formattedMessage: formattedMessage)
    }

    private func extractCategory(_ string: String) -> (String, String) {
        guard string.first == "[", let categoryEndIndex = string.firstIndex(of: "]") else {
            return ("", string)
        }
        
        let categoryRange = string.index(string.startIndex, offsetBy: 1)..<categoryEndIndex
        let bodyRange = string.index(categoryEndIndex, offsetBy: 2)..<string.endIndex
        let category = String(string[categoryRange])
        let body = String(string[bodyRange])
        
        return (category, body)
    }
    
    private func getFormattedMessage(from logMessage: DDLogMessage) -> String {
        if let formatter = internalLogFormatter, let formattedMessage = formatter.format(message: logMessage) {
            return formattedMessage
        } else {
            return logMessage.message
        }
    }
    
    private func printToConsole(log: OSLog, logMessage: DDLogMessage, formattedMessage: String) {
        guard !formattedMessage.isEmpty else { return }
        
        let logType: OSLogType
        switch logMessage.flag {
        case .error:
            logType = .fault
        case .warning, .info:
            logType = .error
        case .debug, .verbose:
            // 콘솔앱에는 노출하지 않음
            logType = .info
        default:
            logType = .fault
        }
        os_log(logType, log: log, "%{public}@", formattedMessage)
    }
}
