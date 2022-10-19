//
//  UIResponder+Swizzle.swift
//  EventLogger
//
//  Created on 2022/10/20.
//

import UIKit

extension UIResponder {
    
    static func swizzleForMemoryTracking() {
        for selectorDic in ["init": "swizzledInit", "dealloc": "swizzledDeinit"] {
            let originSelector = NSSelectorFromString(selectorDic.key)
            let newSelector = NSSelectorFromString(selectorDic.value)
            
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
    }
    
    @objc
    private func swizzledInit() {
        self.swizzledInit()
        Log.verbose(type(of: self))
    }
    
    @objc
    private func swizzledDeinit() {
        Log.verbose(type(of: self))
    }
}
