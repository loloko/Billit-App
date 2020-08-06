//
//  RegisterViewController.swift
//  Billit
//
//  Created by Fernando Rauber on 15/5/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    
    let loading = Indicator.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //event to hide keyboard when tapped on screen
        hideKeyboardWhenTappedAround()
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
        
        
    }
    //MARK: - Function for scroll the screen for the last textfield
    @objc func keyboardWillShow(sender: NSNotification) {
        guard let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else {
                // if keyboard size is not available for some reason, dont do anything
                return
        }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height , right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        
        // reset back the content inset to zero after keyboard is gone
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    
    
    override func viewDidLayoutSubviews() {
        //just apply when the view finish loading
        //textfield style
        tfName.addBottomBorder()
        tfEmail.addBottomBorder()
        tfPassword.addBottomBorder()
        tfConfirmPassword.addBottomBorder()
    }
    
    //hide keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if textField == tfName {
            tfEmail.becomeFirstResponder()
        }else if textField == tfEmail {
            tfPassword.becomeFirstResponder()
        }else if textField == tfPassword {
            tfConfirmPassword.becomeFirstResponder()
        }
        
        return true
        
    }
    
    @IBAction func registerClick(_ sender: Any) {
        
        guard let name  = tfName.text, !name.isEmpty else{
            alert(message: "Name is required".localized)
            return
        }
        guard let email  = tfEmail.text, !email.isEmpty else{
            alert(message: "E-mail is required".localized)
            return
        }
        guard let password  = tfPassword.text, !password.isEmpty else{
            alert(message: "Password is required".localized)
            return
        }
        guard let confirmPassword  = tfConfirmPassword.text, !confirmPassword.isEmpty else{
            alert(message: "Confirm Password is required".localized)
            return
        }
        
        
        if password != confirmPassword{
            alert(message: "Passwords don't match".localized)
            return
        }
        
        //check if internet is on
        if !isConnectedToNetwork(){
            return
        }
        
        loading.showIndicator()
        
        Auth.auth().createUser(withEmail: email.lowercased(), password: password) { (authResult, error) in
            
            if error == nil{
                
                let user =  UserModel.init(authResult!.user.uid, name, email)
                user.save()
                
            }else{
                
                let erroR = error! as NSError
                if let errorCod = erroR.userInfo["FIRAuthErrorUserInfoNameKey"]{
                    
                    switch errorCod as! String {
                    case "ERROR_INVALID_EMAIL":
                        self.alert(message: "Invalid e-mail".localized)
                        break
                    case "ERROR_WEAK_PASSWORD":
                        self.alert(message: "Password weak".localized)
                        break
                    case "ERROR_EMAIL_ALREADY_IN_USE":
                        self.alert(message: "E-mail already in use".localized)
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
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    

}
