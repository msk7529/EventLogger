//
//  ObjectMonitor.swift
//  EventLogger
//
//  Created on 2022/10/18.
//

import Foundation

public struct LCObjectInfo {
    public let typeName: String
    public let aliasName: String?
    private(set) weak var objectRef: AnyObject?
}

public class ObjectMonitor: NSObject {
    public typealias ObjectTable = [Int: LCObjectInfo]

    public static let shared = ObjectMonitor()

    public var groupTable = [String: ObjectTable]()

    public func objectTable(_ groupName: String) -> ObjectTable {
//        if !LogConsole.isActivated {
//            LogConsole.error("[LogConsole] LCObjectMonitor error (not activated)")
//            return [:]
//        }

        var objectTable: ObjectTable?
        //NSLock.synchronized(self) {
            objectTable = groupTable[groupName]
            if objectTable == nil {
                objectTable = [:]
                groupTable[groupName] = objectTable
            }
        //}
        return objectTable!
    }

    public func objectInfo(groupName: String, object: AnyObject) -> LCObjectInfo? {
//        if !LogConsole.isActivated {
//            LogConsole.error("[LogConsole] LCObjectMonitor error (not activated)")
//            return nil
//        }
        let objectTable = objectTable(groupName)

        return objectTable[object.hash]
    }

    public func isExist(groupName: String, object: AnyObject) -> Bool {
//        if !LogConsole.isActivated {
//            LogConsole.error("[LogConsole] LCObjectMonitor error (not activated)")
//            return false
//        }

        let objectTable = objectTable(groupName)

        return objectTable[object.hash] != nil
    }

    public func addObject(groupName: String, object: AnyObject, aliasName: String? = nil) {
        let typeName = object.classForCoder.description()

//        if !LogConsole.isActivated {
//            LogConsole.error("[LogConsole] LCObjectMonitor error (not activated)")
//            return
//        }

        //NSLock.synchronized(self) {
            if var objectTable = groupTable[groupName] {
                objectTable[object.hash] = LCObjectInfo(typeName: typeName, aliasName: aliasName, objectRef: object)
                groupTable[groupName] = objectTable
            }
        //}
    }

    public func removeObject(groupName: String, object: AnyObject) {
//        if !LogConsole.isActivated {
//            LogConsole.error("[LogConsole] LCObjectMonitor error (not activated)")
//            return
//        }

        //NSLock.synchronized(self) {
            if var objectTable = groupTable[groupName] {
                objectTable.removeValue(forKey: object.hash)
                groupTable[groupName] = objectTable
            }
        //}
    }

    public func objectCount(_ groupName: String) -> Int {
//        if !LogConsole.isActivated {
//            LogConsole.error("[LogConsole] LCObjectMonitor error (not activated)")
//            return 0
//        }

        let objectTable = self.objectTable(groupName)
        return objectTable.count
    }

    public override var debugDescription: String {
//        if !LogConsole.isActivated {
//            LogConsole.error("[LogConsole] LCObjectMonitor error (not activated)")
//            return "error"
//        }

        var description = ""

        for (groupName, objectTable) in groupTable {
            description.append("\(groupName) : \(objectTable.count)\n")
        }

        description.append("----------------------------\n")
        for (groupName, objectTable) in groupTable {
            description.append("\n")

            for key in objectTable.keys {
                description.append("\(groupName) ; \(key) ; \(objectTable[key]?.typeName ?? "-")\n")
            }
        }

        return description
    }

    public func checkOverflowObjectCount(group: String, count: Int) -> Bool {
        let table = objectTable(group)

        var dictionary: [String: Int] = [:]
        for info in table.values {
            if let count = dictionary[info.typeName] {
                dictionary[info.typeName] = count + 1
            } else {
                dictionary[info.typeName] = 1
            }
        }
        return dictionary.filter { $0.1 > count }.count > 0
    }

    public func description(group: String) -> String {
        var result = ""
        let table = objectTable(group)

        var dictionary: [String: Int] = [:]
        for info in table.values {
            if let count = dictionary[info.typeName] {
                dictionary[info.typeName] = count + 1
            } else {
                dictionary[info.typeName] = 1
            }
        }

        dictionary.sorted { $0.1 > $1.1 }.forEach {
            result += "- \($0.0) : \($0.1)\n"
        }
        return result
    }

}
