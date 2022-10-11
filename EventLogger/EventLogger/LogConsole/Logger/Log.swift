//
//  Log.swift
//  EventLogger
//

import Foundation

struct Log: Loggable {
    var output: LogOutputMask
    var category: LogCategory?

    init(output: LogOutputMask = .all, category: LogCategory? = nil) {
        self.output = output
        self.category = category
    }
}
