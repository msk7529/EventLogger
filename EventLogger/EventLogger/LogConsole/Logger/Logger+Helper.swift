//
//  Logger+Helper.swift
//  EventLogger
//

import Foundation

extension Logger {
    static let xcode = Logger(output: .xcode)
    static let logconsole = Logger(output: .logconsole)
    static let test = Logger(output: .all, category: .test)
}
