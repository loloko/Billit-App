//
//  SettingsViewController.swift
//  Billit
//
//  Created by Fernando Rauber on 15/5/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseUI

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var imagePicker = UIImagePickerController()
    
    var storage: Storage!
    var db: DatabaseReference!
    
    let currentUser = Singleton.shared.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //firebase
        storage = Storage.storage()
        
        imagePicker.delegate = self
        
        //recover user info
        initUI()
        
        //Listener to Currency popup
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: "currencyPopup"), object: nil, queue: OperationQueue.main) { (notification) in
            
            let currencyCode = notification.object as? Currency
            let defaults = UserDefaults.standard
            defaults.set(currencyCode?.code, forKey: "currency")
            
            self.tableView.reloadData()
        }
    }
    
    //image event
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let imageReturn = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        self.image.image = imageReturn
        
        
        if let imageUpload = imageReturn.jpegData(compressionQuality: 0.4){
            
            
            let imageref = storage.reference().child(FirebaseVars.images).child(currentUser!.uid).child(FirebaseVars.profile).child("\(currentUser!.uid).jpg")
            
            imageref.putData(imageUpload, metadata: nil) { (metaData, error) in
                
                
                if error == nil{
                    
                    imageref.downloadURL { (url, error) in
                        if let urlImage = url?.absoluteString{
                            
                            self.db.updateChildValues([FirebaseVars.photo : urlImage])
                            
                        }
                    }
                    
                }else{
                    self.alert(message: "Error to upload photo".localized)
                }
                
            }
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    
    func initUI(){
        tableView.tableFooterView = UIView()
        
        //check if internet is on
        if !isConnectedToNetwork(){
            self.lbName.text = ""
            self.lbEmail.text = ""
            return
        }
        
        if currentUser != nil{
            db = FirebaseVars.dbRefUser.child(currentUser!.uid)
            db.observeSingleEvent(of:.value, with: { (snapshot) in
                
                let dados = snapshot.value as? NSDictionary
                
                self.lbName.text = dados?[FirebaseVars.name] as? String
                self.lbEmail.text = dados?[FirebaseVars.email] as? String
                
                if let imageUrl = dados?[FirebaseVars.photo] as? String{
                    self.image.sd_setImage(with: URL(string: imageUrl ), completed: nil)
                }
                
                
            }) { (error) in
                 
            }
            
        }else{
            self.lbName.text = "Guest".localized
            self.lbEmail.text = "No e-mail".localized
        }
        
    }
    
}


extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 2
        default: return 0}
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(named: "colorBlue")
        
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 17)
        title.textColor = .white
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        
        
        
        switch section {
        case 0:     title.text  = "Social".localized
            
        case 1:    title.text = "Preferences".localized
        default: break}
        
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = SettingsCell()
        
        switch indexPath.section {
        case 0:
            //MARK: - Social section
            cell = tableView.dequeueReusableCell(withIdentifier: "settingTextCell") as! SettingsCell
            
            
            switch indexPath.row {
                
            case 0:
                cell.lbTitle.text  = "Change Picture".localized
                
            case 1:
                if currentUser != nil{
                    cell.lbTitle.text  = "Sign out".localized
                    cell.lbTitle.textColor = UIColor(named: "colorRed")
                }else{
                    cell.lbTitle.text  = "Sign in".localized
                    cell.lbTitle.textColor = UIColor(named: "colorBlue")
                }
            default: break}
            
        case 1:
            //MARK: - Preferences section
            cell = tableView.dequeueReusableCell(withIdentifier: "settingValueCell") as! SettingsCell
            
            switch indexPath.row {
                
            case 0:
                //ver sobre isso, se deixo  ou tiro, ou deixo e coloco mensgem parar abrir o app configuracao
                cell.lbTitle.text  = "Change language".localized
                cell.lbValue.text  = Locale.current.languageCode?.uppercased()
                
            case 1:
                cell.lbTitle.text  = "Default Currency".localized
                cell.lbValue.text  = self.userDefaultCurrency()
                
            default: break}
            
            
        default: break}
        
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
            
        case 0:
            //MARK: - Social section
            switch indexPath.row {
                
            case 0:
                //change picture
                
                //check if internet is on
                if !isConnectedToNetwork(){
                    return
                }
                
                //Guest can't change picture
                if !isUserGuest(){
                    imagePicker.sourceType = .photoLibrary
                    present(imagePicker, animated: true, completion: nil)
                }
                
            case 1:
                //Sign out
                performSegue(withIdentifier: "unwindToLoginSegue", sender: nil)
                
            default: break}
                        
        case 1:
            //MARK: - Preferences section
            switch indexPath.row {
                
            case 0:
                //language
                if let url = URL(string:UIApplication.openSettingsURLString){
                   UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                
            case 1:
                //currency
                performSegue(withIdentifier: "toCurrencyPopupFromSettingsSegue", sender: nil)
                
                
            default: break}
            
            
        default: break}
        
    }
}
