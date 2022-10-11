//
//  LogConsoleDateFormatterGenerator.swift
//  EventLogger
//
//

import Foundation

struct LogConsoleDateFormatterGenerator {
    
    enum FormatType {
        case short
        case long
    }
    
    static func dateFormatter(type: FormatType) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.formatterBehavior = .behavior10_4
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = type == .short ? "HH:mm:ss.SS" : "yyyy-MM-dd HH:mm:ss.SSS"
        return dateFormatter
    }
}
