//
//  BillDetailViewController.swift
//  Billit
//
//  Created by Fernando Rauber on 18/5/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit
import FirebaseUI

class BillDetailViewController: UIViewController , UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tfAmount: UITextField!
    @IBOutlet weak var lbAmountLeft: UILabel!
    @IBOutlet weak var tfDate: UITextField!
    @IBOutlet weak var tfCurrency: UITextField!
    @IBOutlet weak var tableViewFriend: UITableView!
    
    
    var billEdit: Dictionary<String, Any>!
    
    var friendList: [FriendModel] = []
    var amountLeft: Double = 0
    var friendCountNoAmount = 0
    var isAmountFieldEmpty = true
    
    var amountTotalFriend: Double = 0
    
    let singleton = Singleton.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        
        //event to hide keyboard when tapped on screen
        hideKeyboardWhenTappedAround()
        
        //all notifications
        notificationsCenter()
        
        //get default currency
        tfCurrency.text = userDefaultCurrency()
        
        //limit the characteres option with func
        tfTitle.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        tfTitle.delegate = self
        
        //set UI when edit a bill
        if billEdit != nil{
            
            singleton.editBill = billEdit
            
            tfTitle.text = billEdit[FirebaseVars.title] as? String
            tfDate.text = billEdit[FirebaseVars.date] as? String
            tfAmount.text = "\(billEdit[FirebaseVars.amount]!)"
            
            //friends
            let friends = billEdit[FirebaseVars.cFriends] as! [Dictionary<String, Any>]
            for friend in friends{
                friendList.append(FriendModel.init(friend: friend))
            }
            
            if let attachs = billEdit[FirebaseVars.images] as? [String]{
                singleton.attachList = attachs
            }
            
            isAmountFieldEmpty = false
        }else{
            singleton.editBill = nil
        }
        
        self.tfDate.inputView = UIView()
        self.tfDate.inputAccessoryView = UIView()
    }
    
    //just apply when the view finish loading
    override func viewDidLayoutSubviews() {
        //textfield style
        tfDate.addBottomBorder()
        tfTitle.addBottomBorder()
        tfAmount.addBottomBorder()
        tfCurrency.addBottomBorder()
    }
    
    //set the limite characteres for the textfield name
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 30
    }
    
    @IBAction func callDatePopupView(_ sender: Any) {
        performSegue(withIdentifier: "toDatePopupSegue", sender: nil)
    }
    
    @IBAction func callCurrencyPopupView(_ sender: Any) {
        performSegue(withIdentifier: "toCurrencyPopupSegue", sender: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        //just when edit a bill
        //will add log in case user just deleted an image or add a image without save the bill
        if self.isMovingFromParent {
            if billEdit != nil{
                
                if !singleton.logs.isEmpty{
                   
                    let ref = FirebaseVars.dbRefBill.child(billEdit["id"] as! String)
                    
                    //insert the logs in the bill
                    if var logsBill = billEdit[FirebaseVars.activities] as? [Dictionary<String, Any>]{
                        logsBill.append(contentsOf: singleton.logs)
                        ref.child(FirebaseVars.activities).setValue(logsBill)
                    }
                    
                    //insert "images URL" in the bill
                    if !singleton.attachList.isEmpty{
                         ref.child(FirebaseVars.images).setValue(singleton.attachList)
                    }
                    
                    singleton.logs.removeAll()
                    singleton.attachList.removeAll()
                }
            }else{
                //if user add Images but dont save the bill, delete them from firebase storage
                
                for url in singleton.attachList{
                    Storage.storage().reference(forURL: url).delete(completion: nil)
                }
                singleton.attachList.removeAll()
            }
        }
    }
    
    @IBAction func saveClick(_ sender: Any) {
        //guest can not create/edit bills
        if isUserGuest(){
            return
        }
        //just the owner can modify the bill
        if !userCanEdit(){
            return
        }
        
        //check if internet is on
        if !isConnectedToNetwork(){
            return
        }
        
        
        guard let title = tfTitle.text, !title.isEmpty else{
            alert(message: "Please insert a tittle".localized)
            return
        }
        guard let date = tfDate.text, !date.isEmpty else{
            alert(message: "Please pick a date".localized)
            return
        }
        guard let amount = tfAmount.text, !amount.isEmpty else{
            alert(message: "Amount is required".localized)
            return
        }
        if friendList.count <= 1{
            alert(message: "It's required at least 2 people".localized)
            return
        }
        
        if !lbAmountLeft.isHidden{
            alert(message: lbAmountLeft.text!)
            return
        }
        
        
        //generate suggested debts ( who will ownes who)
        let debitCalc = DebitSuggestCalc.init(friends: friendList, amountTotal: Double(amount)!)
        
        //generate the friend list to insert in firebase
        var friendsInsert: [Dictionary<String, Any>] = []
        var allFriendsString = ""
        for friend in self.friendList {
            allFriendsString = allFriendsString + ", \(friend.name!)"
            friendsInsert.append(friend.parseDictionary())
        }
        
        
        var billID = ""
        var logs: [Dictionary<String, Any>]!
        
        
        //create
        if billEdit == nil{
            billID = UUID.init().uuidString
            logs = generateLogCreattion(isCreate: true, friends: self.friendList, debts: debitCalc.debitsPerson)
            
        }else{
            //edit
            billID = billEdit[FirebaseVars.id] as! String
            logs = billEdit[FirebaseVars.cLog] as? [Dictionary<String, Any>]
            logs.append(contentsOf:generateLogCreattion(isCreate: false, friends: self.friendList, debts: debitCalc.debitsPerson))
        }
        
        let index = billID.index(billID.startIndex, offsetBy: 10)
        let accessCode = billID.prefix(upTo: index)
        
        
        FirebaseVars.dbRefBill.child(billID).setValue([ FirebaseVars.id : billID,
                                                        FirebaseVars.title : title,
                                                        FirebaseVars.date : date,
                                                        FirebaseVars.amount : amount,
                                                        FirebaseVars.currency : tfCurrency.text!,
                                                        FirebaseVars.accessCode : accessCode,
                                                        FirebaseVars.ownerId : singleton.currentUser.uid,
                                                        FirebaseVars.ownerName : singleton.currentUser.displayName!,
                                                        FirebaseVars.debts :    debitCalc.getResult(),
                                                        FirebaseVars.activities: logs!,
                                                        FirebaseVars.images : singleton.attachList,
                                                        FirebaseVars.friendString :  allFriendsString.dropFirst(),
                                                        FirebaseVars.friends : friendsInsert])
        
        
        
        singleton.logs.removeAll()
        singleton.attachList.removeAll()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //amount textfield event
    @IBAction func amountValueChanged(_ sender: Any) {
        isAmountFieldEmpty = false
        self.checkIfHaveLeftAmount()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if friendList.isEmpty{
            return 1
        }
        
        return (friendList.count + 1)
    }
    
    //MARK: - POPULATE TABLE
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //in case of no friends
        if friendList.isEmpty{
            return  tableView.dequeueReusableCell(withIdentifier: "billFriendEmptyCell", for: indexPath)
        }
        
        //last row to show the Total
        if indexPath.row == friendList.count{
            let cell =  tableView.dequeueReusableCell(withIdentifier: "billFriendTotalCell", for: indexPath) as! FriendTableViewCell
            
            calcTotalAmount()
            
            cell.tfPaid.text = "\(formatDecimal(amount: amountTotalFriend))"
            return cell
        }
        
        //normal row with friends and their info
        let cell =  tableView.dequeueReusableCell(withIdentifier: "billFriendCell", for: indexPath) as! FriendTableViewCell
        
        
        
        if !friendList[indexPath.row].hasChanged {
            friendList[indexPath.row].amountPaid = devideAmountByFriends()
        }
        
        let friend = friendList[indexPath.row]
        
        cell.lbName.text = friend.name
        
        
        cell.tfPaid.text = "\(friend.amountPaid!)"
        amountTotalFriend += friend.amountPaid!
        
        
        return cell
    }
    
    //ADD FRIEND BUTTON CLICK
    @IBAction func btAddFriendsClick(_ sender: Any) {
        if isUserGuest(){
            return
        }
        if !userCanEdit(){
            return
        }
        
        //check if internet is on
        if !isConnectedToNetwork(){
            return
        }
        
        
        self.performSegue(withIdentifier: "toFriendSegue", sender: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //just divide the rest of amount with the rest of friends
    func devideAmountByFriends() -> Double {
        if amountLeft > 0{
            return formatDecimal(amount: Double(amountLeft / Double(friendCountNoAmount)))
        }
        return 0
    }
    
    func calcTotalAmount()  {
        if let amount = tfAmount.text, !amount.isEmpty{
            let result = formatDecimal(amount: ( Double(amount)! - amountTotalFriend))
            
            print(result)
            
            if result.isLess(than: 0) {
                lbAmountLeft.isHidden = false
                lbAmountLeft.textColor = .red
                
                lbAmountLeft.text = "Amount exceeded: amount".localizedArgs(result)
            }else if result > 0{
                lbAmountLeft.isHidden = false
                lbAmountLeft.textColor = .green
                lbAmountLeft.text = "Amount left of: amount".localizedArgs(result)
            }else{
                lbAmountLeft.isHidden = true
            }
        }else{
            lbAmountLeft.isHidden = true
        }
    }
    
    
    //check to see how many friends havent set the amount to be paid
    //calculate the amount that has been set
    func checkIfHaveLeftAmount() {
        friendCountNoAmount = 0
        
        if !isAmountFieldEmpty{
            
            if let amountLef = tfAmount.text, !amountLef.isEmpty{
                
                //check if its a real number
                if !isNumber(string: amountLef){
                    return
                }
                
                amountLeft = (amountLef as NSString).doubleValue
                
                for item in friendList{
                    if item.hasChanged{
                        amountLeft -= item.amountPaid
                    }else{
                        friendCountNoAmount += 1
                    }
                }
            }else{
                amountLeft = 0
            }
        }else{
            //enter if user insert amount by the friend instead of input amount total
            var sum: Double = 0
            for item in friendList{
                if item.hasChanged{
                    sum += item.amountPaid
                }
            }
            tfAmount.text = "\(sum)"
        }
        
        
        amountTotalFriend = 0
        tableViewFriend.reloadData()
    }
    
    //MARK: - SELECT ITEM TABLE
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableViewFriend.deselectRow(at: indexPath, animated: true)
        
        if friendList.count > 0{
            self.tableViewFriend.deselectRow(at: indexPath, animated: true)
            self.performSegue(withIdentifier: "toPaymentSegue", sender: friendList[indexPath.row])
        }
    }
    
    //MARK: - SEGUES
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toPaymentSegue"{
            let popup = segue.destination as! PaymentPopupViewController
            
            popup.friend = sender as? FriendModel
            popup.amountLeft = amountLeft
            popup.isAmountEmpty = isAmountFieldEmpty
            
            if let total = Double(tfAmount.text!){
                popup.amountTotal = total
            }
        }
        
        if segue.identifier == "toFriendSegue"{
            let seg = segue.destination as! FriendViewController
            
            seg.selectFriendsToBill = friendList
        }
        
    }
    
    //MARK: - Notification Center
    func notificationsCenter()  {
        //Listener to Payment popup
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: "paymentFriend"), object: nil, queue: OperationQueue.main) { (notification) in
            let data = notification.object as! FriendModel
            
            var position = 0
            for f in self.friendList{
                if f.id == data.id{
                    self.friendList[position] = data
                }
                position += 1
            }
            self.checkIfHaveLeftAmount()
        }
        
        //Listener to Date popup
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: "datePopup"), object: nil, queue: OperationQueue.main) { (notification) in
            
            self.tfDate.text =  notification.object as? String
        }
        
        //Listener to selected friends
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: "selectFriend"), object: nil, queue: OperationQueue.main) { (notification) in
            
            self.friendList =  notification.object as! [FriendModel]
            
            
            if let amountLef = self.tfAmount.text, !amountLef.isEmpty{
                self.isAmountFieldEmpty = false
                self.checkIfHaveLeftAmount()
            }else{
                self.tableViewFriend.reloadData()
            }
            
        }
        
        //Listener to Currency popup
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: "currencyPopup"), object: nil, queue: OperationQueue.main) { (notification) in
            
            let cur = notification.object as? Currency
            self.tfCurrency.text = cur?.code
        }
    }
    
}
