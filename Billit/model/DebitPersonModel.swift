//
//  DebitPerson.swift
//  Billit
//
//  Created by Fernando Rauber on 23/5/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//


struct DebitPersonModel{
    
    var debtorId: String!
    var debtorName: String!
    
    var creditorId: String!
    var creditorName: String!
    
    var amount: Double!
    var currency: String!
    
    init(_ debtorId: String,_ debtorName: String,_ creditorId: String,_ creditorName: String, _ amount:Double,_ currency: String ) {
        self.debtorId = debtorId
        self.debtorName = debtorName
        
        self.creditorId = creditorId
        self.creditorName = creditorName
        self.amount = amount
        self.currency = currency
    }
    
    
} 
