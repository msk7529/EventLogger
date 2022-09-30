//
//  CustomDDOSLogger.swift
//  EventLogger
//

import CocoaLumberjackSwift
import Foundation
import OSLog

@objc
public final class CustomDDOSLogger: DDAbstractLogger {

    static let defaultCategory = adjustCategoryString("DEFAULT")
    static let subsystem = Bundle.main.bundleIdentifier!.replacingOccurrences(of: "com.msk7529.", with: "log.")
    static let defaultLog: OSLog = OSLog(subsystem: subsystem, category: defaultCategory)

    var logDict: [String: OSLog] = [:]

    private var internalLogFormatter: DDLogFormatter?
    
    public override var logFormatter: DDLogFormatter! {
        get {
            return super.logFormatter
        }
        set {
            super.logFormatter = newValue
            internalLogFormatter = newValue
        }
    }
    
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

    public override func log(message logMessage: DDLogMessage) {
        // Skip captured log messages
        if logMessage.fileName == "DDASLLogCapture" {
            return
        }

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
                                            tag: logMessage.tag,
                                            options: logMessage.options,
                                            timestamp: logMessage.timestamp)
        }

        let formattedMessage: String
        if let formatter = internalLogFormatter {
            if let message = formatter.format(message: targetLogMessage) {
                formattedMessage = message
            } else {
                return
            }
        } else {
            formattedMessage = targetLogMessage.message
        }

        let log = fetchLog(category)

        let logType: OSLogType
        switch logMessage.flag {
        case .error:
            logType = .fault
        case .warning, .info:
            logType = .error
        case .debug, .verbose:
            logType = .info
        default:
            logType = .fault
        }
        os_log(logType, log: log, "%{public}@", formattedMessage)
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
}
