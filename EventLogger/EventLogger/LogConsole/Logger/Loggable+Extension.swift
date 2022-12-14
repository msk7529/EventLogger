//
//  Loggable+Extension.swift
//  EventLogger
//

import CocoaLumberjackSwift
import Foundation

extension Loggable {
    
    private static func log(type: LogType = .debug,
                            output: LogOutputMask = .all,
                            category: LogCategory? = nil,
                            _ message: @autoclosure () -> Any,
                            file: StaticString = #file,
                            function: StaticString = #function,
                            line: UInt = #line) {
        #if !DEBUG
        return
        #endif
        let messageString = preprocessMessage(category: category, message: message())
        
        if output.contains(.xcode) {
            // CustomDDOSLogger.log 호출
            // flag가 level 로깅 수준보다 높아야 콘솔에 노출된다.
            _DDLogMessage(messageString,
                          level: .verbose,
                          flag: type.lumberjackFlag,
                          context: 1,
                          file: file,
                          function: function,
                          line: line,
                          tag: nil,
                          asynchronous: false,
                          ddlog: DDLog.sharedInstance)
        }
        
        if output.contains(.logconsole) {
            let logMessage = LogConsoleMessage(message: messageString, logType: type, fileName: String(describing: file), fileLine: line, functionName: String(describing: function))
            LogConsole.addLogMessage(logMessage)
        }
    }
    
    public static func verbose(output: LogOutputMask = .all,
                               category: LogCategory? = nil,
                               _ message: @autoclosure () -> Any,
                               file: StaticString = #file,
                               function: StaticString = #function,
                               line: UInt = #line) {
        log(type: .verbose, output: output, category: category, message(), file: file, function: function, line: line)
    }
    
    public static func debug(output: LogOutputMask = .all,
                             category: LogCategory? = nil,
                             _ message: @autoclosure () -> Any,
                             file: StaticString = #file,
                             function: StaticString = #function,
                             line: UInt = #line) {
        log(type: .debug, output: output, category: category, message(), file: file, function: function, line: line)
    }
    
    public static func info(output: LogOutputMask = .all,
                            category: LogCategory? = nil,
                            _ message: @autoclosure () -> Any,
                            file: StaticString = #file,
                            function: StaticString = #function,
                            line: UInt = #line) {
        log(type: .info, output: output, category: category, message(), file: file, function: function, line: line)
    }
    
    public static func warning(output: LogOutputMask = .all,
                               category: LogCategory? = nil,
                               _ message: @autoclosure () -> Any,
                               file: StaticString = #file,
                               function: StaticString = #function,
                               line: UInt = #line) {
        log(type: .warning, output: output, category: category, message(), file: file, function: function, line: line)
    }
    
    public static func error(output: LogOutputMask = .all,
                             category: LogCategory? = nil,
                             _ message: @autoclosure () -> Any,
                             file: StaticString = #file,
                             function: StaticString = #function,
                             line: UInt = #line) {
        log(type: .error, output: output, category: category, message(), file: file, function: function, line: line)
    }
}

private extension Loggable {
    static func preprocessMessage(category: LogCategory?, message: Any) -> String {
        let messageString = String(describing: message)
        if let category = category {
            return "[\(category)] \(messageString)"
        }
        return messageString
    }
}
