//
//  String+Trimmed.swift
//  EventLogger
//
//

import Foundation

public extension String {
    
    var trailingTrimmed: String {
        if let range = rangeOfCharacter(from: .whitespacesAndNewlines, options: [.anchored, .backwards]) {
            return String(self[..<range.lowerBound]).trailingTrimmed
        }
        return self
    }

    var leadingTrimmed: String {
        if let range = rangeOfCharacter(from: .whitespacesAndNewlines, options: [.anchored]) {
            return String(self[range.upperBound..<self.endIndex]).leadingTrimmed
        }
        return self
    }

    var whiteSpaceTrimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isBackspace: Bool {
        let char = self.cString(using: String.Encoding.utf8)!
        return strcmp(char, "\\b") == -92
    }

    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }

    var isBlank: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

