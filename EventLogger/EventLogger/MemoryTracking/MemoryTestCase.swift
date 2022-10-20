//
//  MemoryTestCase.swift
//  EventLogger
//
//  Created on 2022/10/20.
//

import UIKit

final class MemoryTestCase {
    
    private static var testObjectAllocTrackingLastAllocObjects: [String: Int]?
    
    func testObjectAllocTracking() {
        let objectInfos = ObjectMonitor.shared.objectTable("AllocTracker").values
        var objectsCountDic = [String: Int]()
        objectInfos.forEach { info in
            let count = objectsCountDic[info.typeName] ?? 0
            objectsCountDic[info.typeName] = count + 1
        }

        let list = Array(objectsCountDic)
        let sortedList = list.sorted { $0.1 > $1.1 }

        var logBody = ""

        var increaseCount = 0
        var decreaseCount = 0
        var total = 0

        for (key, count) in sortedList {
            total += count

            let diff = count - (Self.testObjectAllocTrackingLastAllocObjects?[key] ?? 0)

            if diff > 0 {
                let diffLog = String(format: "%03d : %@ (+%d)\n", count, key, diff)
                logBody += diffLog
                Log.debug("+ \(diffLog)\n[ALLOC]")
                increaseCount += diff
            } else if diff == 0 {
                logBody += String(format: "%03d : %@\n", count, key)
            }
        }

        if let lastAllocObjects = Self.testObjectAllocTrackingLastAllocObjects {
            let lastList = Array(lastAllocObjects)

            for (key, lastCount) in lastList {
                let curCount = objectsCountDic[key] ?? 0
                let diff = curCount - lastCount
                if diff < 0 {
                    let diffLog = String(format: "%03d : %@ (%d)\n", curCount, key, diff)
                    logBody += diffLog
                    Log.verbose("- \(diffLog)\n[ALLOC]")
                    decreaseCount += -diff
                }
            }
        }
        Log.info("[ALLOC] 😎 Total : \(total) (+\(increaseCount)/-\(decreaseCount))\n\n\(logBody))")
        Self.testObjectAllocTrackingLastAllocObjects = objectsCountDic
    }
}
