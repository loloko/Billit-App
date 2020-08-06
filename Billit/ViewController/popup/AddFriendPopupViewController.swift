//
//  AddFriendViewController.swift
//  Billit
//
//  Created by Fernando Rauber on 16/5/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit

class AddFriendPopupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tfName: UITextField!
    var friendEdit : Dictionary<String, Any>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfName.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        tfName.delegate = self
        
        //set name if is edit friend
        if friendEdit != nil{
            tfName.text = friendEdit[FirebaseVars.name] as? String
        }
    }
    
    //set the limite characteres for the textfield name
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 25
    }
    
    override func viewDidLayoutSubviews() {
        tfName.addBottomBorder()
    }
    
    @IBAction func btCancelClick(_ sender: Any) {
        if friendEdit != nil{
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "addFriendPopup"), object: friendEdit)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btDoneClick(_ sender: Any) {
        guard let name = tfName.text, !name.isEmpty else {
            alert(message: "Name is required".localized)
            return
        }
        
        //check internet connection
        if !isConnectedToNetwork(){
            return
        }
        
        
        var friendResult = Dictionary<String, Any>()
        friendResult[FirebaseVars.name] = name
        
        //save edited friend
        if let friend = friendEdit {
            
            FirebaseVars.dbRefUser.child(Singleton.shared.currentUser.uid).child(FirebaseVars.cFriends).child(friend[FirebaseVars.id] as! String).child(FirebaseVars.name).setValue(name)
            
            friendResult[FirebaseVars.id] = friend[FirebaseVars.id] as? String
            
        }else{
            //save new friend
            let refKey =  FirebaseVars.dbRefUser.child(Singleton.shared.currentUser.uid).child(FirebaseVars.cFriends).childByAutoId()
            
            friendResult[FirebaseVars.id] = refKey.key
            
            refKey.setValue(friendResult)
        }
        
        self.view.endEditing(true)
        
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "addFriendPopup"), object: friendResult)
        
        self.dismiss(animated: true)
        
    }
    
}
