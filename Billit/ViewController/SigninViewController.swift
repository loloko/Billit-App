//
//  SigninViewController.swift
//  Billit
//
//  Created by Fernando Rauber on 15/5/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import CryptoKit
import AuthenticationServices

class SigninViewController: UIViewController, LoginButtonDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btGoogleSignin: GIDSignInButton!
    @IBOutlet weak var lbRegister: UIButton!
    @IBOutlet weak var lbGuest: UIButton!
    
    var auth: Auth!
    let btLoginFacebook = FBLoginButton()
    let btLoginApple = ASAuthorizationAppleIDButton()
    //var handle: AuthStateDidChangeListenerHandle!
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    let loading = Indicator.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //firebase
        auth = Auth.auth()
        
        
        //localized String and buttom with attribute
        lbRegister.setAttributedTitle("Are you new here? ".localized.makeBoldUnderline(boldText: "Sign up".localized), for: UIControl.State.normal)
        lbGuest.setAttributedTitle("Continue as ".localized.makeBoldUnderline(boldText: "Guest".localized), for: UIControl.State.normal)
        
        //this listener work in all screen, so it works after the Register an user
        auth.addStateDidChangeListener { (auth, user) in
            
            if user != nil{
                Singleton.shared.currentUser = user
                self.performSegue(withIdentifier: "segueLogin", sender: nil)
            }
            
        }
        
        
        //Facebook
        btLoginFacebook.delegate = self
        btLoginFacebook.frame = .zero
        btLoginFacebook.isHidden = true
        btLoginFacebook.permissions = ["public_profile", "email"]
        
        //Google
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        
        // Observe access token changes
        // This will trigger after successfully login / logout
        NotificationCenter.default.addObserver(forName: .AccessTokenDidChange, object: nil, queue: OperationQueue.main) { (notification) in
            
            self.firebaseLoginFacebook()
        }
        
        
        //Listener to GOOGLE LOGIN on delegate, in case a error occurred
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: "errorGoogle"), object: nil, queue: OperationQueue.main) { (notification) in
            
            self.alert(message: "Error trying to log in with social".localizedArgs("Google"))
        }
    }
    
    
    //log out
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //print("log out")
    }
    
    //hide keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func btFacebookClick(_ sender: Any) {
        //check if internet is on
        if !isConnectedToNetwork(){
            return
        }
        
        btLoginFacebook.sendActions(for: .touchUpInside)
    }
    @IBAction func btGoogleClick(_ sender: Any) {
        //check if internet is on
        if !isConnectedToNetwork(){
            return
        }
        
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func firebaseLoginFacebook()  {
        guard let token = AccessToken.current else {return}
        
        loading.showIndicator()
        
        let credential = FacebookAuthProvider.credential(withAccessToken: token.tokenString)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            
            if (error != nil) {
                self.alert(message: error!.localizedDescription)
                
            }else{
                
                if let userID = authResult?.user.uid{
                    
                    
                    //check if user exist in the firebase DB
                    FirebaseVars.dbRefUser.child(userID).observeSingleEvent(of:.value, with: { (snapshot) in
                        
                        
                        //in case not exist, create one
                        if !snapshot.exists(){
                            let token = AccessToken.current?.tokenString
                            let params = ["fields": "name, email"]
                            let graphRequest = GraphRequest(graphPath: "me", parameters: params, tokenString: token, version: nil, httpMethod: .get)
                            graphRequest.start { (connection, result, error) in
                                
                                if let err = error {
                                    print("Facebook graph request error: \(err)")
                                } else {
                                    
                                    guard let json = result as? NSDictionary else { return }
                                    
                                    
                                    //save user in firebase database
                                    let user =  UserModel.init(userID, json["name"] as! String, json["email"] as! String)
                                    user.save()
                                    
                                    
                                    self.loading.hideIndicator()
                                    
                                }
                                
                            }
                        }
                    })
                    
                    
                }
                
            }
        }
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        // auth.removeStateDidChangeListener(handle)
    }
    
    override func viewDidLayoutSubviews() {
        //just apply when the view finish loading
        //textfield style
        tfEmail.addBottomBorder()
        tfPassword.addBottomBorder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func loginClick(_ sender: Any) {
        guard let email = tfEmail.text, !email.isEmpty else {
            self.alert(message: "E-mail is required".localized)
            return
        }
        guard let password = tfPassword.text, !password.isEmpty else {
            self.alert(message: "Password is required".localized)
            return
        }
        
        //check if internet is on
        if !isConnectedToNetwork(){
            return
        }
        
        loading.showIndicator()
        
        auth.signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil{
                self.alert(message: "E-mail/password invalid".localized)
            }
            
            
            self.loading.hideIndicator()
        }
    }
    
    @IBAction func unwindToSignin(_ unwindSegue: UIStoryboardSegue) {
        do {
            try auth.signOut()
            GIDSignIn.sharedInstance().signOut()
            LoginManager().logOut()
        } catch  {
            
        }
    }
    
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if ((error) != nil)
        {
            self.alert(message: "Error trying to log in with social".localizedArgs("Facebook"))
        }
        else if result!.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result!.grantedPermissions.contains("public_profile")
            {
                
            }
        }
    }
    
    
    //Apple Sign in
    
    @IBAction func btAppleLoginClick(_ sender: Any) {
        btLoginApple.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)
        btLoginApple.sendActions(for: .touchUpInside)
        
    }
    
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    
    
    @objc func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

extension SigninViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension SigninViewController : ASAuthorizationControllerDelegate{
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            
            loading.showIndicator()
            
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                
                if (error != nil) {
                    self.alert(message: "Error trying to log in with social".localizedArgs("Apple"))
                    
                }else{
                    
                    if let userID = authResult?.user.uid{
                        
                        //check if user exist in the firebase DB
                        FirebaseVars.dbRefUser.child(userID).observeSingleEvent(of:.value, with: { (snapshot) in
                            
                            
                            //in case do not exist, create one
                            if !snapshot.exists(){
                                let fullName = appleIDCredential.fullName?.givenName ?? "N/A"
                                let email = authResult?.user.email
                                
                                //save user in firebase database
                                let user =  UserModel.init(userID, fullName , email!)
                                user.save()
                                
                                
                                self.loading.hideIndicator()
                                
                            }
                        })
                        
                    }
                    
                }
                
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.alert(message: "Error trying to log in with social".localizedArgs("Apple"))
    }
    
}
