//
//  UserModel.swift
//  Billit
//
//  Created by Fernando Rauber on 27/6/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserModel{
    
    var id: String!
    var name: String!
    var email: String!
    
    init(_ id: String, _ name: String, _ email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
    
    
    func save()  {
        
        if let user = Auth.auth().currentUser{
            
            let changeRequest = user.createProfileChangeRequest()
            
            changeRequest.displayName = name
            changeRequest.commitChanges(completion: nil)
            
            
            FirebaseVars.dbRefUser.child(user.uid).setValue([
                FirebaseVars.name : name,
                FirebaseVars.email : email.lowercased(),
                FirebaseVars.id : user.uid
            ])
            
        }
    }
}
