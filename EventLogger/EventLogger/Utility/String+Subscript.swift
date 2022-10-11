//
//  String+Subscript.swift
//  EventLogger
//
//  Created on 2022/10/12.
//

import Foundation

public extension String {
    subscript (int offset: Int) -> String {
        return String(self[index(startIndex, offsetBy: offset)])
    }
    
    subscript(_ range: Range<Int>) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: range.startIndex)
        let toIndex = self.index(self.startIndex, offsetBy: range.endIndex)
        return String(self[fromIndex..<toIndex])
    }
    
    // NSRange등의 NS계열에 length 파라미터에는 utf16 count(NSString.length)를 넘겨야 한다.
    var lengthForNS: Int {
        return (self as NSString).length
    }
    
    func from(offset: Int) -> String {
        guard self.count > offset else { return "" }
        return String(self[index(startIndex, offsetBy: offset)..<endIndex])
    }
    
    func to(offset: Int, appendingEllipsis: String? = nil) -> String {
        guard self.count > offset else { return self }
        
        let string = String(self[startIndex..<index(startIndex, offsetBy: offset)])
        if let ellipsis = appendingEllipsis {
            return "\(string)\(ellipsis)"
        }
        return string
    }
    
    func range(from offset: Int) -> Range<String.Index>? {
        guard self.count > offset else {
            return nil
        }
        return index(startIndex, offsetBy: offset)..<endIndex
    }
    
    func range(FromNSRange range: NSRange) -> Range<String.Index> {
        let start = index(startIndex, offsetBy: range.location)
        let end = index(startIndex, offsetBy: range.location + range.length)
        return start..<end
    }

    func indexes(ofFirst character: String) -> [Int] {
        precondition(character.count == 1, "Must be single character")
        
        var extraLength: Int = 0 // emoji
        var shouldInclude: Bool = true
        return self.enumerated().reduce([]) { partial, element  in
            if String(element.element) == character, shouldInclude {
                shouldInclude = false
                return partial + [element.offset + extraLength]
            } else if String(element.element) == " " {
                shouldInclude = true
            }
            
            if String(element.element).lengthForNS > 1 {
                extraLength += String(element.element).lengthForNS - 1
            }
            return partial
        }
    }

    func indexes(of character: String) -> [Int] {
        precondition(character.count == 1, "Must be single character")
        
        var extraLength: Int = 0 // emoji
        return self.enumerated().reduce([]) { partial, element  in
            if String(element.element) == character {
                return partial + [element.offset + extraLength]
            }
            if String(element.element).lengthForNS > 1 {
                extraLength += String(element.element).lengthForNS - 1
            }
            return partial
        }
    }
}

public extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        var indices: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                indices.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return indices
    }
    
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    
    func ranges(of targetString: Self, options: String.CompareOptions = [], locale: Locale? = nil) -> [Range<String.Index>] {
        let result: [Range<String.Index>] = self.indices.compactMap { startIndex in
            let targetStringEndIndex = index(startIndex, offsetBy: targetString.count, limitedBy: endIndex) ?? endIndex
            return range(of: targetString, options: options, range: startIndex..<targetStringEndIndex, locale: locale)
        }
        return result
    }
}

