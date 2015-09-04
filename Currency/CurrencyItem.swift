//
//  CurrencyItem.swift
//  Currency
//
//  Created by 黄俊明 on 15/7/22.
//  Copyright (c) 2015年 CS193p. All rights reserved.
//

import Foundation
import CoreData

class CurrencyItem {
    
    var currencyFlatName: String
    var currencyShortName: String
    var currencyFullName: String
    var currencyPrice: Double
    var valueForTextField: Double
    
    init(shortName: String, fullName: String, price: Double){
        let index: String.Index = advance(shortName.startIndex, 2)
        self.currencyFlatName = shortName.substringToIndex(index).lowercaseString
        self.currencyShortName = shortName
        self.currencyFullName = fullName
        self.currencyPrice = price
        self.valueForTextField = 100.0
    }
    
    func getCurrencyItemFromNSManagedObject(managedObject: NSManagedObject) -> CurrencyItem {
        self.currencyShortName = managedObject.valueForKey("shortName") as! String
        self.currencyFullName = managedObject.valueForKey("fullName") as! String
        self.currencyFlatName = managedObject.valueForKey("flatName") as! String
        self.currencyPrice = managedObject.valueForKey("price") as! Double
        self.valueForTextField = managedObject.valueForKey("valueForTextField") as! Double
        
        return self
    }
    

    func checkForEquality(currencyItem: [NSManagedObject]) -> Bool {
        
        for i in 0..<currencyItem.count {
            
            if currencyItem[i].valueForKey("fullName") as! String == self.currencyFullName {
                return true
            }
        }
        
        return false
    }
    
}