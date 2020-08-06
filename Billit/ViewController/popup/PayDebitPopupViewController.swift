//
//  PayDebitPopupViewController.swift
//  Billit
//
//  Created by Fernando Rauber on 12/6/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PayDebitPopupViewController: UIViewController {
    
    @IBOutlet weak var lbDebtorName: UILabel!
    @IBOutlet weak var lbCreditorName: UILabel!
    @IBOutlet weak var tvAmount: UITextField!
    @IBOutlet weak var lbCurrency: UILabel!
    
    var bill: Dictionary<String, Any>!
    var row: Int!
    var debitPerson: Dictionary<String, Any>!
    var amountDebt: Double!
    
    var allDebits: [Dictionary<String, Any>]!
    
    var db: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //firebase
        db = FirebaseVars.dbRefBill.child(bill[FirebaseVars.id] as! String)
        
        
        row = (bill["row"] as! Int)
        
        tvAmount.becomeFirstResponder()
        
        if let debits = bill[FirebaseVars.cDebts] as? [Dictionary<String, Any>]{
            
            allDebits = debits
            
            debitPerson = debits[row]
            
            amountDebt = debitPerson[FirebaseVars.amount] as? Double
            
            lbDebtorName.text = debitPerson[FirebaseVars.debtorName] as? String
            lbCreditorName.text = debitPerson[FirebaseVars.creditorName] as? String
            tvAmount.text = "\(amountDebt ?? 0)"
            lbCurrency.text = bill[FirebaseVars.currency] as? String
            
        }
        
    }
    @IBAction func btCancelClick(_ sender: Any) {
        tvAmount.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btPayClick(_ sender: Any) {
        guard let auxAmount = tvAmount.text, !auxAmount.isEmpty else{
            alert(message: "Please insert the amount to be paid".localized)
            return
        }
        
        if !isNumber(string: auxAmount){
            return
        }
       
        if let amountPaid = Double(auxAmount) {
            
            if amountPaid.isLessThanOrEqualTo(0.0){
                alert(message: "Amount must be bigger than 0".localized)
                return
            }
            if amountDebt.isLess(than: amountPaid){
                alert(message: "Amount can't exceed the total of amount".localizedArgs(amountDebt ?? 0))
                return
            }
            
            
            if amountPaid.isEqual(to: amountDebt){
                
                allDebits.remove(at: row)
                
                db.child(FirebaseVars.cDebts).setValue(allDebits)
                
            }else{
                
                let leftDebit = amountDebt - amountPaid
                
                debitPerson[FirebaseVars.amount] = leftDebit
                
                db.child(FirebaseVars.cDebts).child("\(String(row))").setValue(debitPerson)
            }
            
            generateLog(amountPaid: amountPaid)
            updateFriendAmountPaid(amountPaid: amountPaid)
            
            
            tvAmount.resignFirstResponder()
            dismiss(animated: true, completion: nil)
        
        }
 
    }
    
    func updateFriendAmountPaid(amountPaid: Double) {
        
        let billList = bill[FirebaseVars.cFriends] as! [Dictionary<String, Any>]
        
        //get the friend so can update the amount paid
        for (index, friend) in billList.enumerated(){
            
            //increase the amount paid for the debitor
            if friend[FirebaseVars.id] as? String == self.debitPerson[FirebaseVars.debtorId] as? String{
                
                var friendDebit = friend[FirebaseVars.amount] as! Double
                friendDebit += amountPaid
                
                db.child(FirebaseVars.cFriends).child("\(index)").child(FirebaseVars.amount).setValue(friendDebit)
            }
            // decrease the amount paid for the creditor
            if friend[FirebaseVars.id] as! String == self.debitPerson[FirebaseVars.creditorId] as! String{
                
                var friendCredit = friend[FirebaseVars.amount] as! Double
                friendCredit -= amountPaid
                
                db.child(FirebaseVars.cFriends).child("\(index)").child(FirebaseVars.amount).setValue(friendCredit)
            }
            
        }
        
    }
    
    func generateLog(amountPaid: Double) {
        var activities = bill[FirebaseVars.cLog] as? [Dictionary<String, Any>]
        debitPerson[FirebaseVars.amount] = amountPaid
        
        let log = generateLogDebts(debt: changeDictionaryToDebitPersonModel(debitPerson, ""), action: "paid")
        activities?.append(log)
        
        db.child(FirebaseVars.cLog).setValue(activities)
    }
    
}
