//
//  AllocTracker.swift
//  EventLogger
//
//  Created on 2022/10/18.
//

import UIKit

public class AllocTracker: NSObject {
    public static let sharedInstance = AllocTracker()

    private let allocTrackerGroupName: String = "AllocTracker"

    private lazy var prefixFilterList: [String] = {
        return ["UI", "_UI", "NS", "TalkSharedBase.LC"]
    }()

    private lazy var targetList: [AnyClass] = {
        return [UIViewController.self, UIView.self]
    }()

    private override init() {
        super.init()
    }

    public func isTarget(byType classType: AnyClass) -> Bool {
        for targetType in targetList {
            if classType.isSubclass(of: targetType) {
                return true
            }
        }

        return false
    }

    public func isTarget(byClassName className: String) -> Bool {
        for filter in prefixFilterList {
            if className.hasPrefix(filter) {
                return false
            }
        }

        return true
    }

    public func didInitObject(_ object: AnyObject) {
        #if DEBUG
        if ObjectMonitor.shared.isExist(groupName: allocTrackerGroupName, object: object) {
            return
        }

        ObjectMonitor.shared.addObject(groupName: allocTrackerGroupName, object: object)

        if let viewController = object as? UIViewController,
            !(viewController is UINavigationController) {
            Self.startMonitoringTalkViewController(object as! NSObject)
        }
        #endif
    }

    public func didDeallocObject(_ object: NSObject) {
        let objectKey = object.classForCoder.description()

        #if DEBUG
        guard let objectInfo = ObjectMonitor.shared.objectInfo(groupName: allocTrackerGroupName, object: object) else {
            //Logger.warning("[ALLOC] didDeallocObject not found \(objectKey)")
            return
        }

        let orgObjectKey = objectInfo.typeName
        if orgObjectKey != objectKey {
            //Logger.warning("[ALLOC] typeName changed \(orgObjectKey) -> \(objectKey)")
        }

        ObjectMonitor.shared.removeObject(groupName: allocTrackerGroupName, object: object)

        if let viewController = object as? UIViewController,
            !(viewController is UINavigationController) {
            Self.stopMonitoringTalkViewController(object)
        }

        #endif
    }

    static func startMonitoringTalkViewController(_ object: NSObject) {
        let groupName = "VC"
        let maxCount = 30
        ObjectMonitor.shared.addObject(groupName: groupName, object: object)
        // updateObjectCountView(groupName: groupName, dashboardItemName: groupName, maxCount: maxCount)

        // LCDebouncer.shared("startMonitoringTalkViewController", delay: 1) {
            let count = ObjectMonitor.shared.objectCount(groupName)
            if count > 30 {
                //Logger.error("[CONSOLE] 뷰컨트롤러 인스턴스 갯수가 \(maxCount)개 이상입니다. (\(count)개) 메모리 릭이 의심되면 로그콘솔 테스트 > Memory > testPrintAllViewController 를 실행하여 어떤 뷰컨트롤러가 누적되고 있는지 확인해 보세요.")
            }

            // if LogConsole.properties("Memory.testViewControllerAllocTracking") {
                if ObjectMonitor.shared.checkOverflowObjectCount(group: groupName, count: 5) {
                    let string = ObjectMonitor.shared.description(group: groupName)
                    //Logger.error("[CONSOLE] 특정 VC가 누적되고 있음!!!\n\n\(string)")
                    //Logger.error("[CONSOLE] 특정 VC가 누적되고 있음!!!\n\n\(string)")
                    //Logger.error("[CONSOLE] 특정 VC가 누적되고 있음!!!\n\n\(string)")
                }
            // }

        //}.call()
    }

    static func stopMonitoringTalkViewController(_ object: NSObject) {
        ObjectMonitor.shared.removeObject(groupName: "VC", object: object)
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
