import Foundation
import UIKit

public class Indicator {

    public static let sharedInstance = Indicator()
    var blurImg = UIImageView()
    var indicator = UIActivityIndicatorView()
    
    private init()
    {
        blurImg.frame = UIScreen.main.bounds
        blurImg.backgroundColor = UIColor.black
        blurImg.isUserInteractionEnabled = true
        blurImg.alpha = 0.5
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.center = blurImg.center
        indicator.startAnimating()
        indicator.color = .white
        
    }

    func showIndicator(){
        DispatchQueue.main.async( execute: {
            let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
            
            keyWindow?.addSubview(self.blurImg)
            keyWindow?.addSubview(self.indicator)
        })
    }
    func hideIndicator(){

        DispatchQueue.main.async( execute:
            {
                self.blurImg.removeFromSuperview()
                self.indicator.removeFromSuperview()
        })
    }
}
