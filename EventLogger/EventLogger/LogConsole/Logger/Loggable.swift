//
//  Loggable.swift
//  EventLogger
//

import Foundation
import CocoaLumberjackSwift

protocol Loggable {
    var output: LogOutputMask { get set }
    var category: LogCategory? { get set }
}

enum LogType {
    case verbose
    case debug
    case info
    case warning
    case error

    var lumberjackFlag: DDLogFlag {
        let map: [LogType: DDLogFlag] = [.verbose: .verbose,
                                         .debug: .debug,
                                         .info: .info,
                                         .warning: .warning,
                                         .error: .error]
        return map[self] ?? .error
    }

    var logconsoleFlag: Int {
        let map: [LogType: Int] = [.verbose: 16,
                                   .debug: 8,
                                   .info: 4,
                                   .warning: 2,
                                   .error: 1]
        return map[self] ?? 1
    }
}

struct LogOutputMask: OptionSet {
    static let xcode = LogOutputMask(rawValue: 1 << 0)       // xcode 콘솔에 출력
    static let logconsole = LogOutputMask(rawValue: 1 << 1)  // 로그콘솔에 출력
    static let all: LogOutputMask = [.xcode, .logconsole]

    let rawValue: Int

    init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

