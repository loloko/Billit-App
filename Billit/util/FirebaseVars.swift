//
//  Firebase.swift
//  Billit
//
//  Created by Fernando Rauber on 29/6/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import FirebaseDatabase

class FirebaseVars {
    
    static let dbRefBill = Database.database().reference().child("bills")
    static let dbRefUser = Database.database().reference().child("users")
    
    //collections
    static let cUsers = "users"
    static let cBills = "bills"
    static let cFriends = "friends"
    static let cDebts = "debts"
    static let cLog = "activities"
    
    //Collection User
    static let id = "id"
    static let name = "name"
    static let email = "email"
    static let profile = "profile"
    static let photo = "photo"
     

    //Collection Bill
    static let title = "title"
    static let date = "date"
    static let amount = "amount"
    static let currency = "currency"
    static let ownerId = "owner_id"
    static let ownerName = "owner_name"
    static let debts = "debts"
    static let activities = "activities"
    static let images = "images"
    static let friendString = "friend_string"
    static let friends = "friends"
    static let accessCode = "access_code"
    

    //Collection payment
    static let debtorId = "debtor_id"
    static let debtorName = "debtor_name"
    static let creditorId = "creditor_id"
    static let creditorName = "creditor_name"

    
    //Collection log
     static let message = "message"
     static let type = "type"
     static let time = "time"
     static let count = "count"
     static let isDelete = "is_delete"
     static let action = "action"
     static let activity = "activity"
    

}
