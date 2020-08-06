//
//  SearchBar.swift
//  Billit
//
//  Created by Fernando Rauber on 30/6/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import Foundation
import UIKit


extension UISearchBar {
    
    func getTextField() -> UITextField? { return value(forKey: "searchField") as? UITextField }
    
    
    func setStyle() {
        getTextField()?.setPlaceholder(textColor: .lightGray)
        getTextField()?.textColor = UIColor.white
        setSearchImage(color: .white)
    }
    
    func setSearchImage(color: UIColor) {
        guard let imageView = getTextField()?.leftView as? UIImageView else { return }
        imageView.tintColor = color
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
    }
}

private extension UITextField {
    
    private class Label: UILabel {
        private var _textColor = UIColor.lightGray
        override var textColor: UIColor! {
            set { super.textColor = _textColor }
            get { return _textColor }
        }
        
        init(label: UILabel, textColor: UIColor = .lightGray) {
            _textColor = textColor
            super.init(frame: label.frame)
            self.text = label.text
            self.font = label.font
        }
        
        required init?(coder: NSCoder) { super.init(coder: coder) }
    }
    
    
    var placeholderLabel: UILabel? { return value(forKey: "placeholderLabel") as? UILabel }
    
    func setPlaceholder(textColor: UIColor) {
        guard let placeholderLabel = placeholderLabel else { return }
        let label = Label(label: placeholderLabel, textColor: textColor)
        setValue(label, forKey: "placeholderLabel")
    }
    
}
