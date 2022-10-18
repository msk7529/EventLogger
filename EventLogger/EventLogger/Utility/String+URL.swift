//
//  String+URL.swift
//  EventLogger
//
//  Created on 2022/10/18.
//

import Foundation

extension String {
    
    func appending(pathComponent: String) -> String {
        if self.hasSuffix("/") || pathComponent.hasPrefix("/") {
            return "\(self)\(pathComponent)"
        } else {
            return "\(self)/\(pathComponent)"
        }
    }
}
