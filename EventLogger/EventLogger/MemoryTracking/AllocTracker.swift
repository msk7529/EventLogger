//
//  AllocTracker.swift
//  EventLogger
//
//  Created on 2022/10/18.
//

import UIKit

final class AllocTracker {
    
    static let shared = AllocTracker()

    private let allocTrackerGroupName: String = "AllocTracker"
    let objectMonitor = ObjectMonitor()

    private init() { }

    func didInitObject(_ object: AnyObject) {
        if objectMonitor.isExist(groupName: allocTrackerGroupName, object: object) {
            return
        }

        objectMonitor.addObject(groupName: allocTrackerGroupName, object: object)

        if let viewController = object as? UIViewController,
            !(viewController is UINavigationController) {
            startMonitoringTalkViewController(object as! NSObject)
        }
    }

    func didDeallocObject(_ object: NSObject) {
        let objectKey = object.classForCoder.description()

        guard let objectInfo = objectMonitor.objectInfo(groupName: allocTrackerGroupName, object: object) else {
            //Logger.warning("[ALLOC] didDeallocObject not found \(objectKey)")
            return
        }

        let orgObjectKey = objectInfo.typeName
        if orgObjectKey != objectKey {
            //Logger.warning("[ALLOC] typeName changed \(orgObjectKey) -> \(objectKey)")
        }

        objectMonitor.removeObject(groupName: allocTrackerGroupName, object: object)

        if let viewController = object as? UIViewController,
            !(viewController is UINavigationController) {
            stopMonitoringTalkViewController(object)
        }
    }

    func startMonitoringTalkViewController(_ object: NSObject) {
        let groupName = "VC"
        let maxCount = 30
        objectMonitor.addObject(groupName: groupName, object: object)
        // updateObjectCountView(groupName: groupName, dashboardItemName: groupName, maxCount: maxCount)

        // LCDebouncer.shared("startMonitoringTalkViewController", delay: 1) {
            let count = objectMonitor.objectCount(groupName)
            if count > 30 {
                //Logger.error("[CONSOLE] 뷰컨트롤러 인스턴스 갯수가 \(maxCount)개 이상입니다. (\(count)개) 메모리 릭이 의심되면 로그콘솔 테스트 > Memory > testPrintAllViewController 를 실행하여 어떤 뷰컨트롤러가 누적되고 있는지 확인해 보세요.")
            }

            // if LogConsole.properties("Memory.testViewControllerAllocTracking") {
                if objectMonitor.checkOverflowObjectCount(group: groupName, count: 5) {
                    let string = objectMonitor.description(group: groupName)
                    //Logger.error("[CONSOLE] 특정 VC가 누적되고 있음!!!\n\n\(string)")
                    //Logger.error("[CONSOLE] 특정 VC가 누적되고 있음!!!\n\n\(string)")
                    //Logger.error("[CONSOLE] 특정 VC가 누적되고 있음!!!\n\n\(string)")
                }
            // }

        //}.call()
    }

    func stopMonitoringTalkViewController(_ object: NSObject) {
        objectMonitor.removeObject(groupName: "VC", object: object)
        // updateObjectCountView(groupName: "VC", dashboardItemName: "VC", maxCount: 30)
    }

//    static private func updateObjectCountView(groupName: String, dashboardItemName: String, maxCount: Int) {
//        let count = LCObjectMonitor.shared.objectCount(groupName)
//
//        if count > maxCount {
//            LogConsole.setNetworkSessionState(key: dashboardItemName,
//                                              state: .didConnect,
//                                              error: true,
//                                              sessionText: String(count))
//
//        } else if count == 0 {
//            LogConsole.setNetworkSessionState(key: dashboardItemName,
//                                              state: .didDisconnect,
//                                              error: false,
//                                              sessionText: "")
//
//        } else {
//            LogConsole.setNetworkSessionState(key: dashboardItemName,
//                                              state: .didConnect,
//                                              error: false,
//                                              sessionText: String(count))
//        }
//    }

//    public static func startMonitoringChattingViewController(_ object: NSObject, aliasName: String) {
//        LCObjectMonitor.shared.addObject(groupName: "CHAT", object: object, aliasName: aliasName)
//        updateObjectCountView(groupName: "CHAT", dashboardItemName: "WAS", maxCount: 1)
//    }
//
//    public static func stopMonitoringChattingViewController(_ object: NSObject) {
//        LCObjectMonitor.shared.removeObject(groupName: "CHAT", object: object)
//        updateObjectCountView(groupName: "CHAT", dashboardItemName: "WAS", maxCount: 1)
//    }

}
