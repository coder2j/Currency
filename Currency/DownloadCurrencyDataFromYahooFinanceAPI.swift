//
//  DownloadCurrencyDataFromYahooFinanceAPI.swift
//  Currency
//
//  Created by 黄俊明 on 15/7/29.
//  Copyright (c) 2015年 CS193p. All rights reserved.
//

import UIKit
import Alamofire

class DownloadCurrencyDataFromYahooFinanceAPI {
   
    init() {
    }
    
    func getCurrencyDataFromAPIURL(currencyItemslist: NSMutableArray) {
        
        Alamofire.request(.GET, "http://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote").responseJSON { request, response, JSON, error in
            print(JSON)
                
            //need to change
            print("first error is \(error)")
            
            if error == nil {
                let jsonDataArray: NSArray = JSON?.objectForKey("list")?.objectForKey("resources") as! NSArray
                
                // print("jsonDataArray is \(jsonDataArray)")
                
                var currencyPrice: Double
                var currencyShortName: String
                
                for jsonDataResource in jsonDataArray {
                    let jsonDataFieldinResource: NSDictionary = (jsonDataResource as! NSDictionary).objectForKey("resource")!.objectForKey("fields") as! NSDictionary
                    
                    // print(jsonDataFieldinResource)
                    
                    currencyShortName = jsonDataFieldinResource.objectForKey("symbol") as! String
                    let index: String.Index = advance(currencyShortName.startIndex, 3)
                    currencyShortName = currencyShortName.substringToIndex(index)
                    
                    currencyPrice = (jsonDataFieldinResource.objectForKey("price") as! NSString).doubleValue
                    let currencyItem: CurrencyItem = CurrencyItem(shortName: currencyShortName, fullName: "", price: currencyPrice)
                    currencyItemslist.addObject(currencyItem)
                }
            }
            
        }
        
        Alamofire.request(.GET, "http://openexchangerates.org/currencies.json").responseJSON { _, _, JSON, error in
            
            print(error)
            if error == nil {
                
                let currencyNamesDict: NSDictionary = JSON as! NSDictionary
                var currencyFullName: String
                for (key, objectForKey) in currencyNamesDict {
                    var shortName: String = key as! String
                    var fullName: String = objectForKey as! String
                    
                    for i in 0..<currencyItemslist.count {
                        var currencyItem: CurrencyItem = currencyItemslist.objectAtIndex(i) as! CurrencyItem
                        if currencyItem.currencyShortName == shortName {
                            currencyItem.currencyFullName = fullName
                        }
                    }
                }
                
            }
            
        }
        
    }
    
    func updateCurrencyPriceInArray(list: NSMutableArray) {
        var currencylist: NSMutableArray = []
        getCurrencyDataFromAPIURL(currencylist)
        
        for i in 0..<list.count {
            var itemInList: CurrencyItem = list.objectAtIndex(i) as! CurrencyItem
            for j in 0..<currencylist.count {
                let itemInCurrencyList: CurrencyItem = currencylist.objectAtIndex(j) as! CurrencyItem
                
                if itemInList.currencyShortName == itemInCurrencyList.currencyShortName {
                    itemInList.currencyPrice = itemInCurrencyList.currencyPrice
                }
            }
        }
    }
    
}
