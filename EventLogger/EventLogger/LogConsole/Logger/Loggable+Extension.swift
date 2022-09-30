//
//  Loggable+Extension.swift
//  EventLogger
//

import CocoaLumberjackSwift
import Foundation

extension Loggable {
    
    static func log(type: LogType = .debug,
                    output: LogOutputMask = .all,
                    category: LogCategory? = nil,
                    _ message: @autoclosure () -> Any,
                    file: StaticString = #file,
                    function: StaticString = #function,
                    line: UInt = #line) {
        let messageString = preprocessMessage(category: category, message: message())

        if output.contains(.xcode) {
            // CustomDDOSLogger.log 호출
            // level이 flag 높으면 xcode 콘솔에 노출되지 않음.
            _DDLogMessage(messageString,
                          level: .verbose,
                          flag: type.lumberjackFlag,    // info 이상부터 콘솔앱에 찍힘.
                          context: 1,
                          file: file,
                          function: function,
                          line: line,
                          tag: nil,
                          asynchronous: false,
                          ddlog: DDLog.sharedInstance)
        }
        /* if output.contains(.logconsole) {
            Property.deviceHelper.consoleLog(messageString, type.logconsoleFlag, String(describing: file), String(describing: function), line)
        } */

    }
    
    func log(type: LogType = .debug,
             output: LogOutputMask? = nil,
             category: LogCategory? = nil,
             _ message: @autoclosure () -> Any,
             file: StaticString = #file,
             function: StaticString = #function,
             line: UInt = #line) {
        Self.log(type: type,
                 output: output ?? self.output,
                 category: category ?? self.category,
                 message(),
                 file: file,
                 function: function,
                 line: line)
    }
    
    
    private static func preprocessMessage(category: LogCategory?, message: Any) -> String {
        let messageString = String(describing: message)
        if let category = category {
            return "[\(category)] \(messageString)"
        }
        return messageString
    }
}
