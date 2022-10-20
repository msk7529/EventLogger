//
//  UIResponder+Swizzle.swift
//  EventLogger
//
//  Created on 2022/10/20.
//

import UIKit

private var associatedObjectAddr = ""

extension UIResponder {
    
    private final class Deallocator {
        private let closure: () -> Void
        
        init(closure: @escaping () -> Void) {
            self.closure = closure
        }
        
        deinit {
            closure()
        }
    }
    
    static func swizzleForMemoryTracking() {
        let originSelector = NSSelectorFromString("init")
        let newSelector = #selector(swizzledInit)
        
        guard let originMethod = class_getInstanceMethod(self, originSelector),
              let newMethod = class_getInstanceMethod(self, newSelector) else {
            return
        }
        
        let didAddNewMethod = class_addMethod(self, originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))
        
        if didAddNewMethod {
            class_replaceMethod(self, newSelector, method_getImplementation(originMethod), method_getTypeEncoding(originMethod))
        } else {
            method_exchangeImplementations(originMethod, newMethod)
        }
    }
    
    @objc
    private func swizzledInit() {
        self.swizzledInit()
        AllocTracker.shared.didInitObject(self)

        let deallocator = Deallocator { [unowned(unsafe) self] in
            // objc의 unsafe_unretained와 대응됨. 이걸 안 쓰면 클로저가 실행될 때 self가 release되어 크래시 발생.
            /* unowned(unsafe)는 참조를 사용할 때 런타임 safety checker가 비활성화됩니다. 참조한 객체가 해제된 후에 사용하면 대부분 런타임 오류가 발생하지만 발생하지 않고 정상동작이나 엉뚱한 동작을 할 수 있습니다 */
            // https://eastjohntech.blogspot.com/2019/12/unowned-vs-unownedsafe-vs-unownedunsafe_71.html
            AllocTracker.shared.didDeallocObject(self)
        }
        objc_setAssociatedObject(self, &associatedObjectAddr, deallocator, .OBJC_ASSOCIATION_RETAIN)
    }
}
