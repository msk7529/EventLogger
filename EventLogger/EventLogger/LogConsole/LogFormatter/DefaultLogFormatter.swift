//
//  DefaultLogFormatter.swift
//  EventLogger
//

import CocoaLumberjackSwift

final class DefaultLogFormatter: BaseLogFormatter {
    
    var useTimeStamp = false
    
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
            logFlagString = "π₯"
        case .warning:
            logFlagString = "π§"
        case .info:
            logFlagString = "π¨"
        case .debug:
            logFlagString = "π©"
        default:
            logFlagString = "β¬οΈ"
        }
        return logFlagString
    }
    
    override func format(message logMessage: DDLogMessage) -> String? {
        // xcode, μ½μμ±μ λΈμΆλλ λ‘κ·Έ νμμ κ²°μ 
        let logLevel = logFlagString(logFlag: logMessage.flag)
        let timeStamp = useTimeStamp ? string(from: logMessage.timestamp) + " " : ""
        let isMainThread: Bool = logMessage.queueLabel.contains("main")
        
        let headerString = "\(logLevel) \(timeStamp) |\(isMainThread ? "M" : "B")|"
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
