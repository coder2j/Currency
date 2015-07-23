//
//  CurrencyItem.swift
//  Currency
//
//  Created by 黄俊明 on 15/7/22.
//  Copyright (c) 2015年 CS193p. All rights reserved.
//

import Foundation

class CurrencyItem {
    
    let currencyFlatName: String
    let currencyShortName: String
    let currencyFullName: String
    let currencyPrice: Float
    
    var valueForTextField: Float
    
    init(flatName: String, shortName: String, fullName: String, price: Float){
        self.currencyFlatName = flatName
        self.currencyShortName = shortName
        self.currencyFullName = fullName
        self.currencyPrice = price
        self.valueForTextField = 100.0
    }
    
    func moneyCalculateFromBaseCurrency(baseCurrencyPrice: Float, baseCurrencyTextFieldValue: Float)->Float {
        return baseCurrencyTextFieldValue / baseCurrencyPrice * self.currencyPrice
    }

}