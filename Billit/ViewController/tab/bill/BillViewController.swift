//
//  BillViewController.swift
//  Billit
//
//  Created by Fernando Rauber on 21/5/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

struct BillCell {
    var opened = Bool()
    var header: Dictionary<String, Any>!
    var debts: [DebitPersonModel] = []
    var isAccessCode: Bool!
    
    init(_ header: Dictionary<String, Any>!, isAccessCode: Bool ) {
        self.header = header
        self.opened = false
        self.isAccessCode = isAccessCode
    }
}


import UIKit
import FirebaseDatabase
import FirebaseUI
import FirebaseStorage

class BillViewController: UIViewController , UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet weak var tableViewBill: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var billList: [BillCell] = []
    
    let loading = Indicator.sharedInstance
    let singleton = Singleton.shared
    
    var accessCodeArray: [String]! // from user defaults
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //user defaults
        accessCodeArray = userDefault.stringArray(forKey: "accessCodeArray") ?? [String]()
        
        searchBar.setStyle()
        
        //event to hide keyboard when tapped on screen
        hideKeyboardWhenTappedAround()
        
        tableViewBill.tableFooterView = UIView()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            billList = singleton.bills
        }else{
            billList.removeAll()
            
            for item in singleton.bills{
                if let search = item.header["search"] as? String{
                    if search.lowercased().contains(searchText.lowercased()){
                        billList.append(item)
                    }
                }
            }
        }
        tableViewBill.reloadData()
    }
    
    //hide keyboard when tap SEARCH
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if billList.isEmpty{
            return 1
        }
        
        return billList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //show one cell 'Empty cell'
        if billList.isEmpty{
            return 1
        }
        
        if billList[section].opened == true{
            return billList[section].debts.count + 1
        }else{
            return 1
        }
    }
    
    //MARK: - SELECT ITEM TABLE
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableViewBill.deselectRow(at: indexPath, animated: true)
        
        if billList.isEmpty{
            return
        }
        
        var bill = billList[indexPath.section]
        
        //expand the row
        if indexPath.row == 0 {
            //No expand if doesnt have debts
            if bill.debts.isEmpty{
                return
            }
            
            //expand and close Rows
            if bill.opened == true{
                billList[indexPath.section].opened = false
            }else{
                billList[indexPath.section].opened = true
            }
            
            let sections = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(sections, with: .none)
            
        }else{
            //just onwer can do it
            if bill.isAccessCode{
                alert(message: "Just owner can".localized)
                return
            }
            
            //Pay the Friends Debts
            bill.header["row"] = indexPath.row - 1
            self.performSegue(withIdentifier: "payDebtSegue", sender: bill.header)
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        
        //check if internet is on
        if !isConnectedToNetwork(){
            return
        }
        
        if singleton.currentUser != nil{
            fetchAllBills()
        }else{
            //if is guest, just search the access code bills
            billList.removeAll()
            singleton.bills.removeAll()
            
            for code in accessCodeArray{
                fetchBillAccessCode(code: code, isNewCode: false)
            }
        }
        
    }
    
    //MARK: - POPULATE TABLE
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //show empty message to the user
        if billList.isEmpty{
            let cell =  tableView.dequeueReusableCell(withIdentifier: "billEmptyCell", for: indexPath)
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            
            return cell
        }
        
        
        let bill = billList[indexPath.section]
        
        //HEADER
        if indexPath.row == 0{
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "billCell")  as? BillTableViewCell else { return UITableViewCell()}
            
            
            
            cell.lbTitle.text = bill.header[FirebaseVars.title] as? String
            cell.lbDate.text =  "\(bill.header[FirebaseVars.date]!)"
            cell.lbAmount.text = "\(bill.header[FirebaseVars.currency]!): \(bill.header[FirebaseVars.amount]!)"
            cell.lbAccessCode.text = "Shared code".localized + ": \(bill.header[FirebaseVars.accessCode]!)"
            
            //show OWNER just when the bill isnt yours
            if bill.isAccessCode{
                cell.lbOwnerName.text = "Owner: name".localizedArgs(bill.header[FirebaseVars.ownerName] as! String)
                cell.lbOwnerName.isHidden = false
            }else{
                cell.lbOwnerName.isHidden = true
            }
            
            cell.lbFriends.text = "Splitted with: names".localizedArgs(bill.header[FirebaseVars.friendString] as! String)
            
            
            if bill.debts.isEmpty{
                cell.lbDebsCount.text = "number debts".localizedArgs(0)
                cell.lbDebsCount.textColor = UIColor(named: "colorBlue")
            }else{
                cell.lbDebsCount.text = "number debts".localizedArgs(bill.debts.count)
                cell.lbDebsCount.textColor = UIColor(named: "colorRed")
            }
            
            //separator - show or hide for header
            if bill.opened == true{
                cell.separatorInset = UIEdgeInsets(top: 0, left:  cell.bounds.size.width, bottom: 0, right: 0);
            }else{
                cell.separatorInset = .zero
            }
            
            return cell
            
        }else{
            //DEBTS row
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "debtCell")  as? DebtTableViewCell else { return UITableViewCell()}
            
            let debt =  bill.debts[indexPath.row - 1]
            
            cell.lbDebitorName.text = debt.debtorName
            cell.lbCreditorName.text = debt.creditorName
            cell.lbAmount.text = "\(debt.amount!) \(debt.currency!)"
            
            
            //separator - show or hide for debts
            //when open the header, add a separator in the last debts cell
            if indexPath.row == bill.debts.count{
                cell.separatorInset = .zero
            }else{
                cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20);
            }
            
            return cell
        }
        
    }
    //MARK: - EDIT and DELETE options
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.row == 0{
            
            //Edit option
            let edit = UIContextualAction(style: .normal, title: "Edit".localized) {  (contextualAction, view, boolValue) in
                
                self.performSegue(withIdentifier: "toBillDetailsSegue", sender: self.billList[indexPath.section].header)
            }
            
            //Delete option
            let delete = UIContextualAction(style: .destructive, title: "Delete".localized) {  (contextualAction, view, boolValue) in
                
                self.alertForDelete(indexSection: indexPath.section)
                
            }
            
            edit.backgroundColor = UIColor(named: "colorBlue")
            delete.backgroundColor = UIColor(named: "colorRed")
            
            return UISwipeActionsConfiguration(actions: [edit, delete])
        }else{
            return nil
        }
        
    }
    
    func fetchAllBills() {
        loading.showIndicator()
        
        FirebaseVars.dbRefBill.queryOrdered(byChild: FirebaseVars.ownerId).queryEqual(toValue: singleton.currentUser.uid ).observe( .value, with: { (snapshot) in
            
            self.billList.removeAll()
            self.singleton.bills.removeAll()
            
            if (snapshot.exists() ) {
                
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    
                    
                    self.convertAndInsert(snap: snap, isAccessCode: false)
                }
                
            }
            
            self.tableViewBill.reloadData()
            self.loading.hideIndicator()
            
            for code in self.accessCodeArray{
                self.fetchBillAccessCode(code: code, isNewCode: false)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    //MARK: - used by fecthAll and fetchByAccessCode
    func convertAndInsert(snap: DataSnapshot, isAccessCode: Bool)  {
        
        var bill = snap.value as! Dictionary<String, Any>
        
        //used for search as unique string
        bill["search"] = "\(bill[FirebaseVars.title]!) \(bill[FirebaseVars.date]!) \(bill[FirebaseVars.amount]!) \(bill[FirebaseVars.friendString]!) "
        
        //used on the activity view Controller
        bill["is_access_code"] = isAccessCode
        
        
        //convert to BillCell so can be used to expand the row
        var billCell = BillCell.init(bill, isAccessCode: isAccessCode)
        if let debts = bill[FirebaseVars.cDebts] as? [Dictionary<String, Any>]{
            for debt in debts{
                billCell.debts.append(self.changeDictionaryToDebitPersonModel(debt, bill[FirebaseVars.currency] as! String))
            }
        }
        
        
        billList.append(billCell)
        singleton.bills.append(billCell)
    }
    
    func fetchBillAccessCode(code: String, isNewCode: Bool) {
        loading.showIndicator()
        
        FirebaseVars.dbRefBill.queryOrdered(byChild: FirebaseVars.accessCode).queryEqual(toValue: code.uppercased()).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if (snapshot.exists()) {
                
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    
                    self.convertAndInsert(snap: snap, isAccessCode: true)
                }
                
                //if exist, add the code to the user defaults
                if isNewCode{
                    self.accessCodeArray.append(code)
                    self.userDefault.set(self.accessCodeArray, forKey: "accessCodeArray")
                }
                
            }else{
                if isNewCode{
                    self.alert(message: "Access code not found".localized)
                }
            }
            
            self.tableViewBill.reloadData()
            self.loading.hideIndicator()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    //MARK: - button bar '+'  click
    @IBAction func btAddClick(_ sender: Any) {
        
        let alertMsg = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertMsg.addAction(UIAlertAction(title: "New".localized, style: .default, handler: { action in
            //new bill
            self.performSegue(withIdentifier: "toBillDetailsSegue", sender: nil)
            
        }))
        alertMsg.addAction(UIAlertAction(title: "Add access code".localized, style: .default, handler: { action in
            
            
            self.alertInsertAccessCode()
        }))
        alertMsg.addAction(UIAlertAction(title: "Cancel".localized, style: .destructive){ (alertAction) in })
        
        
        self.present(alertMsg, animated: true, completion: nil)
    }
    
    //alert show when user click to add new ACCESS CODE
    func alertInsertAccessCode() {
        let alert = UIAlertController(title: "Access Code".localized, message: nil, preferredStyle: .alert )
        
        
        let save = UIAlertAction(title: "Done".localized, style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            
            
            if textField.text != "" {
                self.fetchBillAccessCode(code: textField.text!, isNewCode: true)
            }
            
            
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Enter access code".localized
        }
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .destructive) { (alertAction) in })
        alert.addAction(save)
        
        
        self.present(alert, animated:true, completion: nil)
        
    }
    
    //MARK: - SEGUES
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toBillDetailsSegue"{
            let seg = segue.destination as! BillDetailViewController
            
            if sender != nil {
                seg.billEdit = sender as? Dictionary<String, Any>
            }
        }
        
        if segue.identifier == "payDebtSegue"{
            let seg = segue.destination as! PayDebitPopupViewController
            
            seg.bill = sender as? Dictionary
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        FirebaseVars.dbRefBill.removeAllObservers()
    }
    
    //Dialog for deleting the friend
    func alertForDelete(indexSection: Int) {
        let alert = UIAlertController(title: "Attention".localized, message: "Are you sure to delete this?".localized, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete".localized, style: .destructive, handler: { (action: UIAlertAction!) in
            
            let bill = self.billList[indexSection]
            //Delete from default access code bill
            if bill.isAccessCode{
                
                let code = bill.header[FirebaseVars.accessCode] as? String
                self.accessCodeArray.removeAll { $0 == code }
                self.userDefault.set(self.accessCodeArray, forKey: "accessCodeArray")
                
                self.billList.remove(at: indexSection)
                self.tableViewBill.reloadData()
                
            }else{
                
                //delete images from firebase
                if let images = bill.header[FirebaseVars.images] as? [String]{
                    for image in images{
                        Storage.storage().reference(forURL: image).delete(completion: nil)
                    }
                }
                
                //delete table from firebase
                FirebaseVars.dbRefBill.child(bill.header[FirebaseVars.id]  as! String).removeValue()
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
