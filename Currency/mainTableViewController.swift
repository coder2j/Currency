//
//  mainTableViewController.swift
//  Currency
//
//  Created by 黄俊明 on 15/7/22.
//  Copyright (c) 2015年 CS193p. All rights reserved.
//

import UIKit


class mainTableViewController: UITableViewController, UITextFieldDelegate, AllCurrencyTableViewDelegate {

    //MARK: - property
    
    
    
    let calculatorCurrencyIdentifier = "Calculator_Currency"
    var notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
    var currencyItemsList: NSMutableArray = []
    
    var selectedRow = 0
    var selectedRow_Currency: CurrencyItem!
    var baseMoneyInUSD: Double!
    
    let heightForTableViewCell: Int = 85
    let contentInsetOnTop: Int = 20
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currencyItem: CurrencyItem = CurrencyItem(shortName: "CNY", fullName: "人民币", price: 6.20)
        currencyItemsList.addObject(currencyItem)
        baseMoneyInUSD = 100 / currencyItem.currencyPrice
        
        let currencyItem_USD: CurrencyItem = CurrencyItem(shortName: "USD", fullName: "美元", price: 1.00)
        currencyItemsList.addObject(currencyItem_USD)
        
        let currencyItem_EUR: CurrencyItem = CurrencyItem(shortName: "EUR", fullName: "欧元", price: 0.9)
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
        let currencyForRow = currencyItemsList.objectAtIndex(indexPath.row) as! CurrencyItem
        updateTableViewCellCustomViews(cell, currencyForRow: currencyForRow, indexPath: indexPath)
        
        return cell
    }
    
    func updateTableViewCellCustomViews(cell: UITableViewCell, currencyForRow: CurrencyItem, indexPath: NSIndexPath) {
        
        let shortName = cell.viewWithTag(200) as! UILabel
        shortName.text = currencyForRow.currencyShortName
        
        let flagImageView = cell.viewWithTag(100) as! UIImageView
        flagImageView.image = UIImage(named: currencyForRow.currencyFlatName)
        
        let fullName = cell.viewWithTag(300) as! UILabel
        fullName.text = currencyForRow.currencyFullName
        
        let textField = cell.viewWithTag(400) as! UITextField
        if indexPath.row != selectedRow {
            textField.userInteractionEnabled = false
        }
        currencyForRow.valueForTextField = baseMoneyInUSD * currencyForRow.currencyPrice
        
        textField.text = String(format: "%.2f", currencyForRow.valueForTextField)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        currencyItemsList.removeObjectAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        selectedRow = indexPath.row
        
        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        let textField = cell.viewWithTag(400) as! UITextField
        
        textField.userInteractionEnabled = true
        textField.placeholder = textField.text //make the origin textfield value as the placeholder
        textField.becomeFirstResponder()
        notificationCenter.addObserver(self, selector: "textField_Value_Changed:", name: UITextFieldTextDidChangeNotification, object: textField)  //listen to the keyboard, when button is tapped update the money in different currency
        
        // refresh cell incase nothing was input
        for i in 0..<currencyItemsList.count {
            let currencyItem = currencyItemsList.objectAtIndex(i) as! CurrencyItem
            if i != selectedRow {
                let indexPath: NSIndexPath = NSIndexPath(forRow: i, inSection: 0)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(heightForTableViewCell)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAllCurrency" {
            let navigation = segue.destinationViewController as! UINavigationController
            let add = navigation.topViewController as! AllCurrencyTableViewController
            add.delegate = self
        }
    }
    
    func addItemFromAllCurrencyTableViewController(controller: AllCurrencyTableViewController, currencyItem: CurrencyItem) {
        
        if currencyItem.checkForEquality(currencyItemsList) == false {
            currencyItemsList.addObject(currencyItem)
            let indexPath: NSIndexPath = NSIndexPath(forRow: currencyItemsList.count - 1, inSection: 0)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            controller.dismissViewControllerAnimated(true, completion: nil)
        } else {
            let alertView = UIAlertView(title: "警告", message: "货币已经存在", delegate: controller, cancelButtonTitle: "OK")
            controller.tableView.addSubview(alertView)
            alertView.show()
        }
        
    }
    
    func addItemFromAllCurrencyTableViewControllerDidCancel(controller: AllCurrencyTableViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - custom function
    
    func refreshTabelViewCell(textField: UITextField) {
        selectedRow_Currency = currencyItemsList.objectAtIndex(selectedRow) as! CurrencyItem
        selectedRow_Currency.valueForTextField = (textField.text as NSString).doubleValue
        
        baseMoneyInUSD = selectedRow_Currency.valueForTextField / selectedRow_Currency.currencyPrice
        
        for i in 0..<currencyItemsList.count {
            let currencyItem = currencyItemsList.objectAtIndex(i) as! CurrencyItem
            if i != selectedRow {
                currencyItem.valueForTextField = baseMoneyInUSD * currencyItem.currencyPrice
                let indexPath: NSIndexPath = NSIndexPath(forRow: i, inSection: 0)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            }
        }
    }

    func textField_Value_Changed(notification: NSNotification) {
        let textField: UITextField = notification.object as! UITextField
        textField.delegate = self
        refreshTabelViewCell(textField)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
