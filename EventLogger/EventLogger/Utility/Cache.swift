//
//  Cache.swift
//  EventLogger
//
//

import UIKit

/*
 * referenced from https://www.swiftbysundell.com/articles/caching-in-swift/
 */

public final class Cache<Key: Hashable, Value> {
    
    // MARK: - Wrapped
    
    private let wrapped = NSCache<WrappedKey, Entry>()
    
    // MARK: - Properties
    
    public var totalCostLimit: Int {
        get {
            return self.wrapped.totalCostLimit
        }
        set(totalCostLimit) {
            self.wrapped.totalCostLimit = totalCostLimit
        }
    }
    
    public var countLimit: Int {
        get {
            return self.wrapped.countLimit
        }
        set(countLimit) {
            self.wrapped.countLimit = countLimit
        }
    }
    
    public var evictsObjectsWithDiscardedContent: Bool {
        get {
            return self.wrapped.evictsObjectsWithDiscardedContent
        }
        set(evictsObjectsWithDiscardedContent) {
            self.wrapped.evictsObjectsWithDiscardedContent = evictsObjectsWithDiscardedContent
        }
    }
    
    public var ignoreMemoryWarning: Bool
    
    // MARK: - Initialzing
    
    public init() {
        self.ignoreMemoryWarning = false
        self.countLimit = 50
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Manage Cache
    
    public func insert(_ value: Value?, forKey key: Key) {
        guard let value = value else {
            self.removeValue(forKey: key)
            return
        }
        
        let entry = Entry(value: value)
        self.wrapped.setObject(entry, forKey: WrappedKey(key))
    }

    public func value(forKey key: Key) -> Value? {
        let entry = self.wrapped.object(forKey: WrappedKey(key))
        return entry?.value
    }

    public func removeValue(forKey key: Key) {
        self.wrapped.removeObject(forKey: WrappedKey(key))
    }
    
    public func removeAll() {
        self.wrapped.removeAllObjects()
    }
    
    @objc
    func didReceiveMemoryWarning() {
        if !self.ignoreMemoryWarning {
            self.removeAll()
        }
    }
}

public extension Cache {
    var allValues: [Value] {
        (self.wrapped.value(forKey: "allObjects") as? NSArray)?.compactMap { $0 as? Entry }.map { $0.value } ?? []
    }
    
    func string(forKey key: Key) -> String? {
        let value = self.value(forKey: key)
        if let stringValue = value as? String {
            return stringValue
        } else if let numberValue = value as? NSNumber {
            return numberValue.stringValue
        }
        return nil
    }

    func number(forKey key: Key) -> NSNumber? {
        let value = self.value(forKey: key)
        if let numberValue = value as? NSNumber {
            return numberValue
        } else if let stringValue = value as? String {
            if let number = Int64(stringValue) {
                return NSNumber(value: number)
            } else if let double = Double(stringValue) {
                return NSNumber(value: double)
            } else {
                return nil
            }
        }
        return nil
    }

    func array(forKey key: Key) -> [Any]? {
        return value(forKey: key) as? [Any]
    }

    func stringArray(forKey key: Key) -> [String]? {
        return value(forKey: key) as? [String]
    }

    func dictionaryArray(forKey key: Key) -> [[String: Any]]? {
        return value(forKey: key) as? [[String: Any]]
    }

    func dictionary(forKey key: Key) -> [String: Any]? {
        return value(forKey: key) as? [String: Any]
    }
}

private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }
}

private extension Cache {
    final class Entry {
        let value: Value

        init(value: Value) {
            self.value = value
        }
    }
}

