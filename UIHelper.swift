//
//  UIHelper.swift
//  Weather
//
//  Created by Ondřej Veselý on 21.06.15.
//  Copyright (c) 2015 find-it.cz spol. s r. o. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hex: Int) {
        var red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        var green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        var blue = CGFloat((hex & 0xFF)) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

extension UILabel {
    
    func setAttributedString(#text: String, fontName: String, fontSize: CGFloat, fontColor: UIColor) {
        self.attributedText = UILabel.attributedString(text: text, fontName: fontName, fontSize: fontSize, fontColor: fontColor)
    }
    
    class func attributedString(#text: String, fontName: String, fontSize: CGFloat, fontColor: UIColor) -> NSAttributedString {
        // Configure an attributed string with custom font information
        let font = UIFont(name: fontName, size: fontSize)!
        
        
        var fontAttrs = [NSFontAttributeName : font, NSForegroundColorAttributeName : fontColor]
        
        return NSAttributedString(string: text, attributes: fontAttrs)
    }
}