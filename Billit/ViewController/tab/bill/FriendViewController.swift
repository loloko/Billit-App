//
//  FriendViewController.swift
//  Billit
//
//  Created by Fernando Rauber on 16/5/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseUI

class FriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableViewFriend: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var db: DatabaseReference!
    
    var friendsList: [Dictionary<String, Any>] = []
    var backupList: [Dictionary<String, Any>] = []
    
    var selectFriendsToBill: [FriendModel] = []
    
    let loading = Indicator.sharedInstance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        searchBar.setStyle()
        
        if let user = Singleton.shared.currentUser{
            db = FirebaseVars.dbRefUser.child(user.uid).child(FirebaseVars.cFriends)
        }
        
        //Listener to add friend popup
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: "addFriendPopup"), object: nil, queue: OperationQueue.main) { (notification) in
            
            self.friendsList.append(notification.object as! Dictionary<String, Any>)
            self.backupList = self.friendsList
            self.tableViewFriend.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            friendsList = backupList
        }else{
            friendsList.removeAll()
            
            for item in backupList{
                if let name = item[FirebaseVars.name] as? String{
                    if name.lowercased().contains(searchText.lowercased()){
                        friendsList.append(item)
                    }
                }
            }
            
        }
        tableViewFriend.reloadData()
    }
    
    //hide keyboard when tap SEARCH
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if friendsList.isEmpty{
            return 1
        }
        
        return self.friendsList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if friendsList.isEmpty{
            return  tableView.dequeueReusableCell(withIdentifier: "friendEmptyCell", for: indexPath)
        }
        
        let cell =  tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell
        
        let friend = friendsList[indexPath.row]
        
        if containsInList(friend: friend){
            cell.contentView.backgroundColor = UIColor(named: "colorBlue")
            tableViewFriend.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        
        cell.lbName.text = friend[FirebaseVars.name] as? String
        
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //check if internet is on
        if !isConnectedToNetwork(){
            return
        }
        
        listAllFriends()
    }
    
    //MARK: - EDIT AND DELETE OPTIONS
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let edit = UIContextualAction(style: .normal, title: "Edit".localized) {  (contextualAction, view, boolValue) in
            
            self.performSegue(withIdentifier: "editFriendSegue", sender: self.friendsList[indexPath.row])
            self.friendsList.remove(at: indexPath.row)
        }
        
        let delete = UIContextualAction(style: .destructive, title: "Delete".localized) {  (contextualAction, view, boolValue) in
            
            self.alertForDelete(index: indexPath.row)
        }
        
        edit.backgroundColor = UIColor(named: "colorBlue")
        delete.backgroundColor = UIColor(named: "colorRed")
        
        return UISwipeActionsConfiguration(actions: [edit, delete])
    }
    
    
    //MARK: - SELECT ITEM TABLE
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if friendsList.count > 0{
            let cell = tableView.cellForRow(at: indexPath) as! FriendTableViewCell
            cell.contentView.backgroundColor = UIColor(named: "colorBlue")
            
            selectFriendsToBill.append(FriendModel.init(friend: friendsList[indexPath.row]))
        }
    }
    
    //MARK: - DESELECT ITEM TABLE
    //remove Friend from the table when deselected
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let friendDeselected = friendsList[indexPath.row]
        
        let cell = tableView.cellForRow(at: indexPath) as! FriendTableViewCell
        cell.contentView.backgroundColor = .clear
        
        for (index, select) in selectFriendsToBill.enumerated() {
            if select.id == friendDeselected[FirebaseVars.id] as? String{
                selectFriendsToBill.remove(at: index)
            }
        }
        
    }
    // used to check in the Dictionary
    func containsInList(friend: Dictionary<String, Any>) -> Bool {
        for select in selectFriendsToBill{
            if select.id.elementsEqual(friend[FirebaseVars.id] as! String){
                return true
            }
        }
        return false
    }
    
    
    //get friends from firebase
    func listAllFriends() {
        loading.showIndicator()
        
        friendsList.removeAll()
        
        db.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if snapshot.exists(){
                
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    
                    
                    self.friendsList.append(snap.value as! Dictionary<String, Any>)
                }
                
                self.backupList = self.friendsList
                self.tableViewFriend.reloadData()
            }
            
            self.loading.hideIndicator()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    @IBAction func itemDoneClick(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "selectFriend"), object: selectFriendsToBill)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editFriendSegue"{
            let seg = segue.destination as! AddFriendPopupViewController
            
            seg.friendEdit = sender as? Dictionary
        }
        
    }
    
    //Dialog for deleting the friend
    func alertForDelete(index: Int) {
        let alert = UIAlertController(title: "Attention".localized, message: "Are you sure to delete this?".localized, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete".localized, style: .destructive, handler: { (action: UIAlertAction!) in
            
            self.db.child((self.friendsList[index][FirebaseVars.id]  as? String)!).removeValue()
            self.friendsList.remove(at: index)
            self.tableViewFriend.reloadData()
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
