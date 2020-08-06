//
//  DatePopupViewController.swift
//  Billit
//
//  Created by Fernando Rauber on 20/5/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit

class DatePopupViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var formattedDate: String{
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: datePicker.date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.backgroundColor =  UIColor(named: "colorPrimary")
        
        datePicker.setValue(UIColor.white , forKey:"textColor")
        datePicker.setValue(false, forKey: "highlightsToday")
        
    }
    
    @IBAction func doneClick(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "datePopup"), object: formattedDate)
        
        dismiss(animated: true)
    }
    
}
