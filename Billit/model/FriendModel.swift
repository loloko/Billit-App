//
//  Friend.swift
//  Billit
//
//  Created by Fernando Rauber on 18/5/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit


struct FriendModel{
    
    var id: String!
    var name: String!
    var amountPaid: Double!
    var hasChanged: Bool = false
    
    
    init( friend: Dictionary<String, Any> ){
        self.id = friend[FirebaseVars.id] as? String
        self.name = friend[FirebaseVars.name] as? String
        if let mAmount = friend[FirebaseVars.amount] as? Double{
            amountPaid = mAmount
            hasChanged = true
        }
        
    }
    
    func parseDictionary() -> Dictionary<String, Any> {
        return  [FirebaseVars.id : self.id!,
                 FirebaseVars.name : self.name!,
                 FirebaseVars.amount :  amountPaid!]
    }
    
}
