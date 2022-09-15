//
//  LogConsoleViewMode.swift
//  EventLogger
//
//  Created by on 2022/09/16.
//

import Foundation

enum LogConsoleViewMode {
    case mini
    case expanded
    
    mutating func toggle() {
        if self == .mini {
            self = .expanded
        } else {
            self = .mini
        }
    }
}
