//
//  AllocTracker.swift
//  EventLogger
//
//  Created on 2022/10/18.
//

import UIKit

enum TrackingGroupName: String {
    case all = "ALL"
    case vc = "VC"
}

final class AllocTracker {
    
    static let shared = AllocTracker()
    
    let objectMonitor = ObjectMonitor()

    private init() { }

    func didInitObject(_ object: AnyObject) {
        guard !objectMonitor.isExist(groupName: TrackingGroupName.all.rawValue, object: object) else {
            return
        }

        objectMonitor.addObject(groupName: TrackingGroupName.all.rawValue, object: object)

        if let viewController = object as? UIViewController,
            !(viewController is UINavigationController) {
            startMonitoringViewController(viewController)
        }
    }

    func didDeallocObject(_ object: NSObject) {
        let objectKey = object.classForCoder.description()

        guard let objectInfo = objectMonitor.objectInfo(groupName: TrackingGroupName.all.rawValue, object: object) else {
            Log.warning("[ALLOC] didDeallocObject not found \(objectKey)")
            return
        }

        let orgObjectKey = objectInfo.typeName
        if orgObjectKey != objectKey {
            Log.warning("[ALLOC] typeName changed \(orgObjectKey) -> \(objectKey)")
        }

        objectMonitor.removeObject(groupName: TrackingGroupName.all.rawValue, object: object)

        if let viewController = object as? UIViewController,
            !(viewController is UINavigationController) {
            stopMonitoringViewController(viewController)
        }
    }

    private func startMonitoringViewController(_ object: UIViewController) {
        objectMonitor.addObject(groupName: TrackingGroupName.vc.rawValue, object: object)

        let count = objectMonitor.objectCount(groupName: TrackingGroupName.vc.rawValue)
        if count > 30 {
            Log.error("[CONSOLE] 뷰컨트롤러 인스턴스 갯수가 30개 이상입니다. (\(count)개) 메모리 릭이 발생하는지 확인해보세요.")
        }
        
        if objectMonitor.checkOverflowObjectCount(group: TrackingGroupName.vc.rawValue, count: 5) {
            let string = objectMonitor.description(group: TrackingGroupName.vc.rawValue)
            Log.error("[CONSOLE] 특정 VC가 누적되고 있음!!!\n\n\(string)")
            Log.error("[CONSOLE] 특정 VC가 누적되고 있음!!!\n\n\(string)")
            Log.error("[CONSOLE] 특정 VC가 누적되고 있음!!!\n\n\(string)")
        }
    }

    private func stopMonitoringViewController(_ object: UIViewController) {
        objectMonitor.removeObject(groupName: TrackingGroupName.vc.rawValue, object: object)
    }
}
