//
//  DownloadCurrencyDataFromYahooFinanceAPI.swift
//  Currency
//
//  Created by 黄俊明 on 15/7/29.
//  Copyright (c) 2015年 CS193p. All rights reserved.
//

import UIKit
import Alamofire

let yahooURL = "http://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json"
let openExchange = "https://openexchangerates.org/api/latest.json?app_id=000ecc9012d54c35afd6f7c7c8ca1550"

class DataManager {
   
    class func getTopAppsDataFromFileWithSuccess(jsonDocName: String,success: ((data: NSData) -> Void)) {
        //1
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            //2
            let filePath = NSBundle.mainBundle().pathForResource(jsonDocName,ofType:"json")
            
            var readError: NSError?
            if let data = NSData(contentsOfFile:filePath!, options: NSDataReadingOptions.DataReadingUncached, error:&readError) {
                    success(data: data)
            }
        })
    }
    
    class func getCurrencyDataFromAPIURLWithSuccess(success:((yahooData: AnyObject) -> Void)) {
    
        
        Alamofire.request(.GET, openExchange).responseJSON { request, response, json, error in
            if error == nil {
                
                success(yahooData: json!)
                
            } else {
                print(error)
            }
        }
        
    }
    
    
}
