//
//  mainTableViewController.swift
//  Currency
//
//  Created by 黄俊明 on 15/7/22.
//  Copyright (c) 2015年 CS193p. All rights reserved.
//

import UIKit

class mainTableViewController: UITableViewController {

    let calculatorCurrencyIdentifier = "Calculator_Currency"
    
    var currencyItemsList: NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currencyItem: CurrencyItem = CurrencyItem(flatName: "CN", shortName: "CNY", fullName: "人名币", price: 6.20)
        currencyItemsList.addObject(currencyItem)
        
        let currencyItem_USD: CurrencyItem = CurrencyItem(flatName: "US", shortName: "USD", fullName: "美元", price: 1.00)
        currencyItemsList.addObject(currencyItem_USD)
        
        let currencyItem_EUR: CurrencyItem = CurrencyItem(flatName: "EU", shortName: "EUR", fullName: "欧元", price: 1.09)
        currencyItemsList.addObject(currencyItem_EUR)
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyItemsList.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(calculatorCurrencyIdentifier, forIndexPath: indexPath) as! UITableViewCell
        var currencyForCell = currencyItemsList.objectAtIndex(indexPath.row) as! CurrencyItem
        
        
        var shortName = cell.viewWithTag(200) as! UILabel
        shortName.text = currencyForCell.currencyShortName
        
        var fullName = cell.viewWithTag(300) as! UILabel
        fullName.text = currencyForCell.currencyFullName
        
        print(fullName)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        currencyItemsList.removeObjectAtIndex(indexPath.row)
        //tableView.deleteRowsAtIndexPaths(indexPath, withRowAnimation: UITableViewRowAnimation.Automatic)
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.dequeueReusableCellWithIdentifier(calculatorCurrencyIdentifier, forIndexPath: indexPath) as! UITableViewCell
        var textField = cell.viewWithTag(400) as! UITextField
        textField.becomeFirstResponder()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85
    }
}
