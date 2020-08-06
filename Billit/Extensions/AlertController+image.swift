//
//  AlertController+image.swift
//  Billit
//
//  Created by Fernando Rauber on 14/6/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit

extension UIAlertController{
    
    func addImage(image: UIImage){
        
        let imgSize = image.size
        let maxSize = CGSize(width: 240, height: 304)
        
        var ratio: CGFloat!
        if (imgSize.width > imgSize.height){
            ratio = maxSize.width / imgSize.width
        }else{
            ratio = maxSize.height / imgSize.height
        }
        
        let scaledSize = CGSize(width: imgSize.width * ratio, height: imgSize.height * ratio)
        
        var resizedImage = image.imageWithSize(scaledSize)
        
        if (imgSize.height > imgSize.width){
            let left = (maxSize.width - resizedImage.size.width) / 2
            resizedImage = resizedImage.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -left, bottom: 0, right: 0))
        }
        
        let imgAction = UIAlertAction(title: "", style: .default, handler: nil)
        imgAction.isEnabled = false
        imgAction.setValue(resizedImage.withRenderingMode(.alwaysOriginal), forKey: "image")
        self.addAction(imgAction)
    }
    
}