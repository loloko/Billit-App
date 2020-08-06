//
//  Singleton.swift
//  Billit
//
//  Created by Fernando Rauber on 23/5/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import UIKit
import FirebaseAuth

class Singleton{
    
    var attachList: [String] = []
    var bills: [BillCell] = []
    var editBill: Dictionary<String, Any>!
    var logs: [Dictionary<String, Any>] = []
    
    var currentUser: User!
    
    static let shared = Singleton()
    
    init(){
        
        
    }
}
