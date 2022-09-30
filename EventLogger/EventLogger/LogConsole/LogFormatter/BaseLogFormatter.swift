//
//  BaseLogFormatter.swift
//  EventLogger
//

import CocoaLumberjackSwift
import Foundation

class BaseLogFormatter: DDDispatchQueueLogFormatter {
    
    override func configureDateFormatter(_ dateFormatter: DateFormatter) {
        dateFormatter.formatterBehavior = .behavior10_4
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
    }

    func logFlagString(logFlag: DDLogFlag) -> String {
        var logFlagString = ""
        switch logFlag {
        case .error:
            logFlagString = "E"
        case .warning:
            logFlagString = "W"
        case .info:
            logFlagString = "I"
        case .debug:
            logFlagString = "D"
        default:
            logFlagString = "V"
        }
        return logFlagString
    }
}

extension TimeInterval {
    func stringFormattedForLogFormatter() -> String {
        let miliSec = Int(self.truncatingRemainder(dividingBy: 1) * 1000)
        let interval = Int(self)
        let sec = interval % 60
        let min = interval / 60

        return String(format: "%02d:%02d.%03d", min, sec, miliSec)
    }
}
