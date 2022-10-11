//
//  String+Size.swift
//  EventLogger
//
//

import UIKit

public extension String {
    
    func size(font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size
    }
    
    func width(font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func height(font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func height(font: UIFont, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    func height(attributes: [NSAttributedString.Key : Any], width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return boundingBox.height
    }
    
    func textSize(with font: UIFont, forWidth: CGFloat = CGFloat.greatestFiniteMagnitude, lineBreakMode: NSLineBreakMode = .byWordWrapping, textAlignment: NSTextAlignment = .left) -> CGSize {
        return textSize(with: font, constrained: CGSize(width: forWidth, height: CGFloat.greatestFiniteMagnitude), lineBreakMode: lineBreakMode, textAlignment: textAlignment)
    }
    
    func textSize(with font: UIFont, constrained toSize: CGSize, lineBreakMode: NSLineBreakMode = .byWordWrapping, textAlignment: NSTextAlignment = .left) -> CGSize {
        let sizingText = self
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = lineBreakMode
        style.alignment = textAlignment
        let textFont: UIFont = font
        return (sizingText as NSString).boundingRect(with: toSize, options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: textFont], context: nil).size
    }
}

