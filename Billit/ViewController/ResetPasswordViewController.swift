//
//  ResetPasswordViewController.swift
//  Billit
//
//  Created by Fernando Rauber on 20/6/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit
import FirebaseAuth

class ResetPasswordViewController: UIViewController , UITextFieldDelegate{
    
    @IBOutlet weak var tfEmail: UITextField!
    
    let loading = Indicator.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        //just apply when the view finish loading
        //textfield style
        tfEmail.addBottomBorder()
    }
    
    //hide keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func btResetPasswordClick(_ sender: Any) {
        guard let email  = tfEmail.text, !email.isEmpty else{
            alert(message: "e-mail reset".localized)
            return
        }
        
        //check if internet is on
        if !isConnectedToNetwork(){
            return
        }
        
        loading.showIndicator()
        
        Auth.auth().sendPasswordReset(withEmail: email.trimmingCharacters(in: .whitespaces)) { (error) in
            if error == nil{
                self.view.endEditing(true)
                self.alert(message: "e-mail sent".localized)
                self.navigationController?.popViewController(animated: true)
            }else{
                let erroR = error! as NSError
                
                if let errorCod = erroR.userInfo["FIRAuthErrorUserInfoNameKey"]{
                    
                    
                    switch errorCod as! String {
                    case "ERROR_INVALID_EMAIL":
                        self.alert(message: "Invalid e-mail".localized)
                        break
                    case "ERROR_USER_NOT_FOUND":
                        self.alert(message: "E-mail not found in our database".localized)
                        break
                    default:
                        self.alert(message: "Incorrect information".localized)
                    }
                    
                }else{
                    self.alert(message: "Incorrect information".localized)
                }
                
            }
            
            self.loading.hideIndicator()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
}
