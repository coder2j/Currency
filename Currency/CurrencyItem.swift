//
//  CurrencyItem.swift
//  Currency
//
//  Created by 黄俊明 on 15/7/22.
//  Copyright (c) 2015年 CS193p. All rights reserved.
//

import Foundation

class CurrencyItem {
    
    var currencyFlatName: String
    var currencyShortName: String
    var currencyFullName: String
    var currencyPrice: Double
    var valueForTextField: Double
    var isAdded: Bool
    var isFavorited: Bool
    
    init(shortName: String, fullName: String, price: Double){
        let index: String.Index = advance(shortName.startIndex, 2)
        self.currencyFlatName = shortName.substringToIndex(index).lowercaseString
        self.currencyShortName = shortName
        self.currencyFullName = fullName
        self.currencyPrice = price
        self.valueForTextField = 100.0
        self.isAdded = false
        self.isFavorited = false
    }
    

    func checkForEquality(currencyItemList: NSArray) -> Bool {
        
        for currencyItem in currencyItemList {
            
            if (currencyItem as! CurrencyItem).currencyFullName == self.currencyFullName {
                
                return true
                
            }
        }
        
        return false
    }
    
}