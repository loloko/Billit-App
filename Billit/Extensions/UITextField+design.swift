//
//  UITextField+design.swift
//  Billit
//
//  Created by Fernando Rauber on 20/6/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit


extension UITextField {
    func addBottomBorder(){
        //remove borders and apply bottom border
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 10, width: self.frame.size.width , height: 1)
        bottomLine.backgroundColor = UIColor.gray.cgColor
        borderStyle = .none
        layer.addSublayer(bottomLine)
        
        //self.tintColor = .white
        self.textColor = .white
        
        //change color of placeholder
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }

}
