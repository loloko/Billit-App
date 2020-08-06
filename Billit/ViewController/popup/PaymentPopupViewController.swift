//
//  SetPaymentViewController.swift
//  Billit
//
//  Created by Fernando Rauber on 20/5/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit

class PaymentPopupViewController: UIViewController {
    
    @IBOutlet weak var igPhoto: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var tfAmountPaid: UITextField!
    
    var friend: FriendModel!
    var amountLeft: Double!
    var amountTotal: Double = 0
    
    var isAmountEmpty: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbName.text = friend.name
        tfAmountPaid.becomeFirstResponder()
        
        if let amount = friend.amountPaid{
            tfAmountPaid.text = "\(String(describing: amount))"
        }
        
    }
    
    @IBAction func doneClick(_ sender: Any) {
        friend.hasChanged = true
        
        if let amount = tfAmountPaid.text, !amount.isEmpty{
            if !isNumber(string: amount){
                return
            }
            
            friend.amountPaid = formatDecimal(amount: Double(amount)!)
        }else{
            friend.amountPaid = 0
        }
        
        
        if !isAmountEmpty, friend.amountPaid > amountTotal {
            alert(message: "Amount can't exceed the total of amount".localizedArgs(amountTotal))
            return
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "paymentFriend"), object: friend)
        
        tfAmountPaid.resignFirstResponder()
        dismiss(animated: true)
    }
    
    
    @IBAction func btCloseClick(_ sender: Any) {
        tfAmountPaid.resignFirstResponder()
        dismiss(animated: true)
    }
    
}
