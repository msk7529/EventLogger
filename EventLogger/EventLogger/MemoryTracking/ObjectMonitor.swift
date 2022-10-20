//
//  ObjectMonitor.swift
//  EventLogger
//
//  Created on 2022/10/18.
//

import Foundation

struct ObjectInfo {
    let typeName: String
    private(set) weak var objectRef: AnyObject?
    
    init(object: AnyObject) {
        self.objectRef = object
        self.typeName = object.classForCoder?.description() ?? "nil"
    }
}

final class ObjectMonitor {
    
    typealias ObjectTable = [Int: ObjectInfo]

    private var groupTable = [String: ObjectTable]()

    func objectTable(groupName: String) -> ObjectTable {
        var objectTable = groupTable[groupName]
        if objectTable == nil {
            objectTable = [:]
            groupTable[groupName] = objectTable
        }
        return objectTable!
    }

    func objectInfo(groupName: String, object: AnyObject) -> ObjectInfo? {
        let objectTable = objectTable(groupName: groupName)
        return objectTable[object.hash]
    }

    func isExist(groupName: String, object: AnyObject) -> Bool {
        let objectTable = objectTable(groupName: groupName)
        return objectTable[object.hash] != nil
    }

    func addObject(groupName: String, object: AnyObject) {
        guard var objectTable = groupTable[groupName] else {
            return
        }
        objectTable[object.hash] = ObjectInfo(object: object)
        groupTable[groupName] = objectTable
    }

    func removeObject(groupName: String, object: AnyObject) {
        guard var objectTable = groupTable[groupName] else {
            return
        }
        objectTable.removeValue(forKey: object.hash)
        groupTable[groupName] = objectTable
    }

    func objectCount(groupName: String) -> Int {
        let objectTable = objectTable(groupName: groupName)
        return objectTable.count
    }

    func checkOverflowObjectCount(group: String, count: Int) -> Bool {
        let objectTable = objectTable(groupName: group)
        var dictionary: [String: Int] = [:]
        
        for objectInfo in objectTable.values {
            dictionary[objectInfo.typeName, default: 0] += 1
        }
        return dictionary.filter { $0.1 > count }.count > 0
    }

    func description(group: String) -> String {
        var result = ""
        var dictionary: [String: Int] = [:]
        let objectTable = objectTable(groupName: group)
        
        for objectInfo in objectTable.values {
            dictionary[objectInfo.typeName, default: 0] += 1
        }
        
        dictionary.sorted { $0.1 > $1.1 }.forEach {
            result += "- \($0.0) : \($0.1)\n"
        }
        return result
    }

}

