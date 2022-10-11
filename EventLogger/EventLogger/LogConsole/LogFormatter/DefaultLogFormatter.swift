//
//  DefaultLogFormatter.swift
//  EventLogger
//

import CocoaLumberjackSwift

final class DefaultLogFormatter: BaseLogFormatter {
    
    override func configureDateFormatter(_ dateFormatter: DateFormatter) {
        dateFormatter.formatterBehavior = .behavior10_4
        dateFormatter.dateFormat = "MM-dd HH:mm:ss.SSS"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
    }
    
    override func logFlagString(logFlag: DDLogFlag) -> String {
        var logFlagString = ""
        switch logFlag {
        case .error:
            logFlagString = "🟥"
        case .warning:
            logFlagString = "🟧"
        case .info:
            logFlagString = "🟨"
        case .debug:
            logFlagString = "🟩"
        default:
            logFlagString = "⬜️"
        }
        return logFlagString
    }
    
    override func format(message logMessage: DDLogMessage) -> String? {
        // xcode, 콘솔앱에 노출되는 로그 형식을 결정
        let logLevel = logFlagString(logFlag: logMessage.flag)
        let isMainThread: Bool = logMessage.queueLabel.contains("main")
        
        let headerString = "\(logLevel) |\(isMainThread ? "M" : "B")|"
        var bodyString = logMessage.message
        
        if logMessage.message.isEmpty {
            bodyString = "\(logMessage.function ?? "???()") .......... (\(logMessage.fileName):\(logMessage.line))"
        } else {
            bodyString = "\(logMessage.message) .......... (\(logMessage.fileName):\(logMessage.line) \(logMessage.function ?? "-"))"
            
            /* if logMessage.flag == .error || logMessage.flag == .warning {
                bodyString = "\(logMessage.message) .......... (\(logMessage.fileName):\(logMessage.line) \(logMessage.function ?? "-"))"
            } else {
                bodyString = "\(logMessage.message) .......... (\(logMessage.fileName):\(logMessage.line))" */
        }
        return headerString + " " + bodyString
    }
}
