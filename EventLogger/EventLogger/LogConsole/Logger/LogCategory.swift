//
//  LogCategory.swift
//  EventLogger
//

import Foundation

struct LogCategory: CustomStringConvertible {
    let name: String

    init(_ name: String) {
        self.name = name
    }

    var description: String { name }
}

extension LogCategory {
    static let test = LogCategory("TEST")
}
