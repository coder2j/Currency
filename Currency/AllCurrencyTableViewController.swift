//
//  AllCurrencyTableViewController.swift
//  Currency
//
//  Created by 黄俊明 on 15/7/26.
//  Copyright (c) 2015年 CS193p. All rights reserved.
//

import UIKit
import Alamofire

class AllCurrencyTableViewController: UITableViewController {

    var delegate: AllCurrencyTableViewDelegate?
    
    let cellIdentifier: String = "AllCurrency"
    var allCurrencyItemList: NSMutableArray = []
    var likedCurrencyItemList: NSMutableArray = []
    
    var jsonDataFromYahoo: NSDictionary = NSDictionary()
    var currencyNamesDict: NSDictionary = NSDictionary()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        
//        print("viewwillappear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print("view did load")
        pepareCurrencyData()
        
    
    }
    
    func pepareCurrencyData() {
        
        if allCurrencyItemList.count == 0 {
            getCurrencyDataFromAPIURL()
        }

    }
    
    func parseJsonFromYahoo() {
        let jsonDataArray: NSArray = jsonDataFromYahoo.objectForKey("list")?.objectForKey("resources") as! NSArray
        
        
        var currencyPrice: Double
        var currencyShortName: String
        
        for jsonDataResource in jsonDataArray {
            let jsonDataFieldinResource: NSDictionary = (jsonDataResource as! NSDictionary).objectForKey("resource")!.objectForKey("fields") as! NSDictionary
            
            currencyShortName = jsonDataFieldinResource.objectForKey("symbol") as! String
            let index: String.Index = advance(currencyShortName.startIndex, 3)
            currencyShortName = currencyShortName.substringToIndex(index)
            
            currencyPrice = (jsonDataFieldinResource.objectForKey("price") as! NSString).doubleValue
            let currencyItem: CurrencyItem = CurrencyItem(shortName: currencyShortName, fullName: "", price: currencyPrice)
            allCurrencyItemList.addObject(currencyItem)
        }
        
//        let sort: NSSortDescriptor = NSSortDescriptor(key: "currencyFullName", ascending: true)
//        allCurrencyItemList.sortUsingDescriptors([sort])
        
        //sort need to do
        
        //allCurrencyItemList.sortUsingSelector("localizedCaseInsensitiveCompare")
    }
    
    func parseFullnameFromOER() {
        
        var currencyFullName: String
        for key in currencyNamesDict.allKeys {
            
            
            var shortName: String = key as! String
            var fullName: String = currencyNamesDict.objectForKey(key) as! String
            
            for i in 0..<self.allCurrencyItemList.count {
                var currencyItem: CurrencyItem = self.allCurrencyItemList.objectAtIndex(i) as! CurrencyItem
                if currencyItem.currencyShortName == shortName {
                    currencyItem.currencyFullName = fullName
                }
            }
            
        }
    }
    
    func getCurrencyDataFromAPIURL() {
        
        Alamofire.request(.GET, "http://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json").responseJSON() { _, _, JSON, error in
            
            if error == nil {
                
                self.jsonDataFromYahoo = JSON as! NSDictionary
                self.parseJsonFromYahoo()
                
                
                if self.allCurrencyItemList.count > 0 {

                    self.getCurrencyFullName()
                    self.tableView.reloadData()
                }
                
            } else {
                print(error)
            }
            
        }
        
    }
    
    func getCurrencyFullName() {
       
        Alamofire.request(.GET, "http://openexchangerates.org/currencies.json").responseJSON() { _, _, JSON, error in
            
            if error == nil {
                
                self.currencyNamesDict = JSON as! NSDictionary
                self.parseFullnameFromOER()
                
                if self.allCurrencyItemList.count > 0 {
                    
                    if self.likedCurrencyItemList.count == 0 {
                        for i in 0..<self.allCurrencyItemList.count {
                            
                            var currencyItem: CurrencyItem = self.allCurrencyItemList.objectAtIndex(i) as! CurrencyItem
                            
                            if currencyItem.currencyShortName == "CNY" || currencyItem.currencyShortName == "EUR" || currencyItem.currencyShortName == "JPY" || currencyItem.currencyShortName == "USD" {
                                self.likedCurrencyItemList.addObject(currencyItem)
                                print("Currency short name is \(currencyItem.currencyShortName)")
                                //
                            }
                        }
                        
                    }
                
                    if self.likedCurrencyItemList.count > 0 {
                        self.tableView.reloadData()
                    }
                }
                
            } else {
                print(error)
            }
            
        }
    }
    
    
    @IBAction func cancel(sender: AnyObject) {
        delegate?.addItemFromAllCurrencyTableViewControllerDidCancel(self)
    }
    //MARK: - tabelViewDelegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var label: UILabel = UILabel( )
        label.textColor = UIColor.purpleColor()
        label.backgroundColor = UIColor.whiteColor()
        label.textAlignment = NSTextAlignment.Center
        switch section {
        case 0:
            label.text = "收藏"
            break
        case 1:
            label.text = "所有"
            break
        default:
            label.text = ""
            break
        }
        return label
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            
            return likedCurrencyItemList.count
            
        } else {
            return allCurrencyItemList.count
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let currencyItem = allCurrencyItemList.objectAtIndex(indexPath.row) as! CurrencyItem
        
        delegate?.addItemFromAllCurrencyTableViewController(self, currencyItem: currencyItem)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        var currencyForRow = allCurrencyItemList.objectAtIndex(indexPath.row) as! CurrencyItem
        
        updateTableViewCellCustomViews(cell, currencyForRow: currencyForRow, indexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85
    }
    
    
    
    func updateTableViewCellCustomViews(cell: UITableViewCell, currencyForRow: CurrencyItem, indexPath: NSIndexPath) {
        
        var shortName = cell.viewWithTag(200) as! UILabel
        shortName.text = currencyForRow.currencyShortName
        
        var flagImageView = cell.viewWithTag(100) as! UIImageView
        flagImageView.image = UIImage(named: currencyForRow.currencyFlatName)
        flagImageView.layer.borderColor = UIColor.blackColor().CGColor
        flagImageView.layer.borderWidth = 0.1
        flagImageView.layer.cornerRadius = 32
        flagImageView.clipsToBounds = true
        
        var fullName = cell.viewWithTag(300) as! UILabel
        fullName.text = currencyForRow.currencyFullName
        
    }
    
    
}
