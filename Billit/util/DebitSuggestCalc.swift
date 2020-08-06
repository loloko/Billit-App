//
//  DebitCalc.swift
//  Billit
//
//  Created by Fernando Rauber on 23/5/20.
//  Copyright © 2020 Fernando Rauber. All rights reserved.
//

import Foundation

class DebitSuggestCalc {
    
    var negative: [FriendModel] = []
    var positive: [FriendModel] = []
    var amountEachShoudPaid:Double!
    var debitsPerson: [DebitPersonModel] = []
    
    init(friends: [FriendModel], amountTotal: Double) {
        
        amountEachShoudPaid = amountTotal / Double(friends.count)
        
        
        for item in friends{
            
            if item.amountPaid < amountEachShoudPaid {
                negative.append(item)
            }else if item.amountPaid > amountEachShoudPaid{
                positive.append(item)
            }
        }
        
        negative = negative.sorted(by: { $0.amountPaid < $1.amountPaid })
        
        positive = positive.sorted(by: { $0.amountPaid > $1.amountPaid })
        
        
        //show the same value
        calcSameValue()
        
        
        calcAmount()
        calcAmount()
        calcAmount()
        
    }
    
    func calcAmount()  {
        var negativeIndex = 0
        var positiveIndex = 0
        
        
        for var pos in positive{
            var restPositive = pos.amountPaid - amountEachShoudPaid
            
            for var neg in negative{
                let restNegative =  amountEachShoudPaid - neg.amountPaid
                negativeIndex = 0
                
                if restNegative.isLess(than: restPositive){
                    
                    debitsPerson.append(DebitPersonModel.init( neg.id,  neg.name,  pos.id,  pos.name,  restNegative,  ""))
                    
                    
                    restPositive -= restNegative
                    pos.amountPaid =  restPositive
                    positive[positiveIndex] = pos
                    
                    negative.remove(at: negativeIndex)
                    negativeIndex -= 1
                    
                }else if restPositive.isLess(than: restNegative){
                    let left = restNegative - restPositive
                    
                    debitsPerson.append(DebitPersonModel.init( neg.id,  neg.name,  pos.id,  pos.name,  restPositive,  ""))
                    
                    
                    neg.amountPaid = left
                    negative[negativeIndex] = neg
                    
                    
                    positive.remove(at: positiveIndex)
                    positiveIndex -= 1
                    
                }else if restPositive.isEqual(to: restNegative){
                    debitsPerson.append(DebitPersonModel.init(neg.id,  neg.name,  pos.id, pos.name,  restPositive,  ""))
                    
                    
                    negative.remove(at: negativeIndex)
                    negativeIndex -= 1
                    
                    positive.remove(at: positiveIndex)
                    positiveIndex -= 1
                    
                }
                
                negativeIndex += 1
                
            }
            
            positiveIndex += 1
        }
        
        
    }
    
    func calcSameValue()  {
        var negativeCount = 0
        var positiveCount = 0
        
        
        for p in positive{
            let restPositive = p.amountPaid - amountEachShoudPaid
            
            for n in negative{
                let restNegative =  amountEachShoudPaid - n.amountPaid
                
                if restNegative == restPositive{
                    debitsPerson.append(DebitPersonModel.init( n.id, n.name,  p.id, p.name, restNegative,  "") )
                    
                    
                    negative.remove(at: negativeCount)
                    negativeCount -= 1
                    
                    positive.remove(at: positiveCount)
                    positiveCount -= 1
                }
                
                negativeCount += 1
            }
            
            positiveCount += 1
        }
        
        
    }
    
    func getResult() -> [Dictionary<String, Any>] {
        var friendsDebts: [Dictionary<String, Any>] = []
        for friend in debitsPerson{
            friendsDebts.append([
                FirebaseVars.debtorId : friend.debtorId!,
                FirebaseVars.debtorName : friend.debtorName!,
                FirebaseVars.creditorId : friend.creditorId!,
                FirebaseVars.creditorName : friend.creditorName!,
                FirebaseVars.amount : formatDecimal(amount: friend.amount!)])
        }
        
        return friendsDebts
    }
    
    func formatDecimal(amount: Double) -> Double {
        let formartted = String(format: "%.02f", amount)
        
        return Double(formartted)!
    }
    
}
