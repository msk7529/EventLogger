//
//  UILabel+Size.swift
//  EventLogger
//
//

import UIKit

public extension UILabel {

    func textSize(with font: UIFont? = nil, forWidth: CGFloat, lineBreakMode: NSLineBreakMode? = nil) -> CGSize {
        return textSize(with: font, constrained: CGSize(width: forWidth, height: CGFloat.greatestFiniteMagnitude), lineBreakMode: lineBreakMode)
    }

    func textSize(with font: UIFont? = nil, constrained toSize: CGSize, lineBreakMode: NSLineBreakMode? = nil, textAlignment: NSTextAlignment? = nil) -> CGSize {
        let sizingText = text ?? ""
        return sizingText.textSize(with: font ?? self.font, constrained: toSize, lineBreakMode: lineBreakMode ?? self.lineBreakMode, textAlignment: textAlignment ?? self.textAlignment)
    }
}
