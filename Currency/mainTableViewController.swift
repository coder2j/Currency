//
//  mainTableViewController.swift
//  Currency
//
//  Created by 黄俊明 on 15/7/22.
//  Copyright (c) 2015年 CS193p. All rights reserved.
//

import UIKit

class mainTableViewController: UITableViewController, UITextFieldDelegate {

    //MARK: - property
    
    let calculatorCurrencyIdentifier = "Calculator_Currency"
    var notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
    var currencyItemsList: NSMutableArray = []
    
    var selectedRow = -1
    var selectedRow_Currency: CurrencyItem!
    var baseMoneyInUSD: Float!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currencyItem: CurrencyItem = CurrencyItem(flatName: "CN", shortName: "CNY", fullName: "人名币", price: 6.20)
        currencyItemsList.addObject(currencyItem)
        
        let currencyItem_USD: CurrencyItem = CurrencyItem(flatName: "US", shortName: "USD", fullName: "美元", price: 1.00)
        currencyItemsList.addObject(currencyItem_USD)
        
        let currencyItem_EUR: CurrencyItem = CurrencyItem(flatName: "EU", shortName: "EUR", fullName: "欧元", price: 0.9)
        currencyItemsList.addObject(currencyItem_EUR)
        
    }
    
    //MARK: - tableViewDelegate
    
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
        
        var textField = cell.viewWithTag(400) as! UITextField
        
        if selectedRow > -1 && selectedRow <= currencyItemsList.count {
            textField.text = String(format: "%.2f", currencyForCell.valueForTextField)
        } else {
            textField.text = "0.0"
        }
        textField.sizeToFit()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        currencyItemsList.removeObjectAtIndex(indexPath.row)
        //tableView.deleteRowsAtIndexPaths(indexPath, withRowAnimation: UITableViewRowAnimation.Automatic)
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selectedRow = indexPath.row
        
        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        var textField = cell.viewWithTag(400) as! UITextField
        textField.placeholder = "100"
        textField.text = "\(100)"
        
        refreshTabelViewCell(textField)
        
        textField.becomeFirstResponder()
        
        notificationCenter.addObserver(self, selector: "textField_Value_Changed:", name: UITextFieldTextDidChangeNotification, object: textField)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85
    }
    
    //MARK: - custom function
    
    func refreshTabelViewCell(textField: UITextField) {
        selectedRow_Currency = currencyItemsList.objectAtIndex(selectedRow) as! CurrencyItem
        selectedRow_Currency.valueForTextField = (textField.text as NSString).floatValue
        print("textField text is \(selectedRow_Currency.valueForTextField)")
        baseMoneyInUSD = selectedRow_Currency.valueForTextField / selectedRow_Currency.currencyPrice
        
        for i in 0..<currencyItemsList.count {
            var currencyItem = currencyItemsList.objectAtIndex(i) as! CurrencyItem
            if i != selectedRow {
                currencyItem.valueForTextField = baseMoneyInUSD * currencyItem.currencyPrice
                let indexPath: NSIndexPath = NSIndexPath(forRow: i, inSection: 0)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            }
        }
    }

    func textField_Value_Changed(notification: NSNotification) {
        var textField: UITextField = notification.object as! UITextField
        refreshTabelViewCell(textField)
    }
    
}
