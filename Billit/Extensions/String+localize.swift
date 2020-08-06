//
//  String+localize.swift
//  Billit
//
//  Created by Fernando Rauber on 25/6/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit

extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localizedArgs(_ args: CVarArg) -> String {
        return String(format: self.localized, args)
    }
    
    var isNumeric : Bool {
        return Double(self) != nil
    }
    
    func makeBoldUnderline(boldText: String) -> NSAttributedString {
        
        let attrs: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14),
                                                     NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
        
        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
        
        let normalString = NSMutableAttributedString(string:self)
        
        normalString.append(attributedString)
        
        return normalString
        
    }
    
}
