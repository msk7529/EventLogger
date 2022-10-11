//
//  UIView+Gesture.swift
//  EventLogger
//
//

import UIKit

public class ClosureSleeve {
    let closure: () -> Void

    public init(attachTo: AnyObject, closure: @escaping () -> Void) {
        self.closure = closure
        objc_setAssociatedObject(attachTo, "[\(arc4random())]", self, .OBJC_ASSOCIATION_RETAIN)
    }

    @objc
    public func invoke() {
        closure()
    }
}

public class GestureClosureSleeve {
    let closure: (UIGestureRecognizer) -> Void
    
    public init(attachTo: AnyObject, closure: @escaping (UIGestureRecognizer) -> Void) {
        self.closure = closure
        objc_setAssociatedObject(attachTo, "[\(arc4random())]", self, .OBJC_ASSOCIATION_RETAIN)
    }
    
    @objc
    public func invoke(recognizer: UIGestureRecognizer) {
        closure(recognizer)
    }
}

public extension UIView {
    func addTapHandler(_ handler: @escaping () -> Void) {
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: ClosureSleeve(attachTo: self, closure: handler), action: #selector(ClosureSleeve.invoke)))
    }
    
    func addTapGesture(cancelsTouchesInView: Bool = true, handler: @escaping (UIGestureRecognizer) -> Void) {
        self.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: GestureClosureSleeve(attachTo: self, closure: handler), action: #selector(GestureClosureSleeve.invoke(recognizer:)))
        gestureRecognizer.cancelsTouchesInView = cancelsTouchesInView
        self.addGestureRecognizer(gestureRecognizer)
    }
    
    func addPanGesture(cancelsTouchesInView: Bool = true, handler: @escaping (UIGestureRecognizer) -> Void) {
        self.isUserInteractionEnabled = true
        let gestureRecognizer = UIPanGestureRecognizer(target: GestureClosureSleeve(attachTo: self, closure: handler), action: #selector(GestureClosureSleeve.invoke(recognizer:)))
        gestureRecognizer.cancelsTouchesInView = cancelsTouchesInView
        self.addGestureRecognizer(gestureRecognizer)
    }
}
