//
//  Message+custom.swift
//  Billit
//
//  Created by Fernando Rauber on 17/5/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import Foundation
import UIKit
import Network

extension UIViewController{
    
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        //alertController.overrideUserInterfaceStyle = .dark
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
 
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
    func isNumber(string: String) -> Bool {
        if !string.isNumeric{
            alert(message: "Please insert only numbers and decimal point".localized)
            return false
        }else{
            return true
        }
    }
    
    func userCanEdit() -> Bool {
        if let bill = Singleton.shared.editBill{
            if bill[FirebaseVars.ownerId] as? String != Singleton.shared.currentUser.uid{
                alert(message: "Just owner can".localized)
                return false
            }
        }
        return true
        
    }
    
    func isUserGuest() -> Bool {
        if  Singleton.shared.currentUser == nil{
            alert(message: "You must sign in to continue".localized)
            return true
        }
        
        return false
    }
    
    func formatDecimal(amount: Double) -> Double {
        let formartted = String(format: "%.02f", amount)
       
        return Double(formartted)!
    }
    
    func dateFormatter() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: Date())
    }
    
    func timeFormatter() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
    
    func generateLogCreattion(isCreate: Bool, friends: [FriendModel], debts: [DebitPersonModel]) -> [Dictionary<String, Any>] {
        var log: [Dictionary<String, Any>] = []
        
        //log for created
        log.append([FirebaseVars.message : "\(isCreate ? "created" : "edited")",
            FirebaseVars.type : 1,
            FirebaseVars.time : timeFormatter(),
            FirebaseVars.date : dateFormatter()])
        
        //how much each one paid in the bill
        for friend in friends{
            log.append([FirebaseVars.type : 3,
                        FirebaseVars.debtorId : friend.id!,
                        FirebaseVars.debtorName : friend.name!,
                        FirebaseVars.time : timeFormatter(),
                        FirebaseVars.date : dateFormatter(),
                        FirebaseVars.amount : friend.amountPaid!])
        }
        
        //log for the images in Attached, will generate just when created, when edited, will add
        if isCreate && !Singleton.shared.attachList.isEmpty{
            log.append(generateLogAttachImage(isBillEdit: false, isDelete: false))
        }else{
            log.append(contentsOf: Singleton.shared.logs)
        }
        
        //log to show who owes who and how much
//        for debt in debts{
//            log.append(generateLogDebts(debt: debt, action: "owes"))
//        }
        
        
        return log
    }
    
    func generateLogAttachImage(isBillEdit: Bool, isDelete: Bool) -> Dictionary<String, Any> {
        if isBillEdit{
            return [FirebaseVars.count : 1,
                    FirebaseVars.isDelete : isDelete,
                    FirebaseVars.type : 2,
                    FirebaseVars.time : timeFormatter(),
                    FirebaseVars.date : dateFormatter()]
            
        }else{
            if !Singleton.shared.attachList.isEmpty{
                return [FirebaseVars.count : Singleton.shared.attachList.count,
                        FirebaseVars.isDelete : false,
                        FirebaseVars.type : 2,
                        FirebaseVars.time : timeFormatter(),
                        FirebaseVars.date : dateFormatter()]
            }else{
                return [:]
            }
        }
    }
    
    //Used to generate logs of who OWES who and who PAID who
    func generateLogDebts(debt: DebitPersonModel, action: String) -> Dictionary<String, Any> {
        return  [FirebaseVars.type : 4,
                 FirebaseVars.debtorId : debt.debtorId!,
                 FirebaseVars.debtorName : debt.debtorName!,
                 FirebaseVars.creditorId : debt.creditorId!,
                 FirebaseVars.creditorName : debt.creditorName!,
                 FirebaseVars.action : action,
                 FirebaseVars.time : timeFormatter(),
                 FirebaseVars.date : dateFormatter(),
                 FirebaseVars.amount : debt.amount!]
    }
    
    func userDefaultCurrency() -> String {
        let defaults = UserDefaults.standard
        if let currency =  defaults.string(forKey: "currency"){
            return currency
        }else{
            let currencyCode = Locale.current.currencyCode!
            
            defaults.set(currencyCode, forKey: "currency")
            
            return currencyCode
        }
    }
    
    func changeDictionaryToDebitPersonModel(_ dictionary: Dictionary<String, Any>,_ currency: String) -> DebitPersonModel{
        let debtorId = dictionary[FirebaseVars.debtorId] as! String
        let debtorName = dictionary[FirebaseVars.debtorName] as! String
        
        let creditorId = dictionary[FirebaseVars.creditorId] as! String
        let creditorName = dictionary[FirebaseVars.creditorName] as! String
        let amount = dictionary[FirebaseVars.amount] as! Double
        
        return DebitPersonModel.init(debtorId, debtorName, creditorId, creditorName, amount, currency )
    }
    
    
    func isConnectedToNetwork() -> Bool {
        if Reachability.isConnectedToNetwork() {
            return true
        }else{
            self.alert(message: "Make sure your device is connected to the internet".localized, title: "No internet connection".localized )
            return false
        }
    }
}
