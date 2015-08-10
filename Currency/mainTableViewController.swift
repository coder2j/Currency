//
//  mainTableViewController.swift
//  Currency
//
//  Created by 黄俊明 on 15/7/22.
//  Copyright (c) 2015年 CS193p. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class mainTableViewController: UITableViewController, UITextFieldDelegate, AllCurrencyTableViewDelegate, CLLocationManagerDelegate {

    //MARK: - property
    
    let calculatorCurrencyIdentifier = "Calculator_Currency"
    var notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
    var currencyItemsList = [CurrencyItem]()
    var allCurrencyItemList = [CurrencyItem]()
    
    var selectedRow = 0
    var selectedRow_Currency: CurrencyItem!
    var baseMoneyInUSD: Double!
    
    let heightForTableViewCell: Int = 85
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        pepareCurrencyData()
        
        var refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.refreshControl = refreshControl
        
    }
    
    func getCurrencyInLocation(countryCode: String) {
        for currencyItem in allCurrencyItemList {
            if currencyItem.currencyFlatName == countryCode.lowercaseString {
                
                if currencyItem.checkForEquality(currencyItemsList) == false {
                    currencyItemsList.append(currencyItem)
                    baseMoneyInUSD = currencyItem.valueForTextField / currencyItem.currencyPrice
                    self.tableView.reloadData()
                }
                
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: { (placemarks, error) -> Void in
            if error == nil {
                self.locationManager.stopUpdatingLocation()
                print("got \n")
                
                if let pm = placemarks[0] as? CLPlacemark {
                    
                    self.getCurrencyInLocation(pm.ISOcountryCode)
                }
                
                
            } else {
                print(error)
            }
        })
    }
    
    func refresh(sender: AnyObject) {
        
        var isRefreshSucceed = false
        
        DataManager.getCurrencyDataFromAPIURLWithSuccess{(yahooData) -> Void in
            
            let jsonData = JSON(yahooData)
            
            let start = NSDate()
            
            if let currencyDict = jsonData["rates"].dictionary {
                for (shortName, price) in currencyDict {
                    for currencyItem in self.currencyItemsList {
                        if currencyItem.currencyShortName == shortName {
                            currencyItem.currencyPrice = price.doubleValue
                        }
                    }
                }
                
                let end = NSDate()
                let timeTravel = end.timeIntervalSinceDate(end)
                print("refresh time is\(timeTravel)")
            }
            
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            
        }
        
    }
    
    func pepareCurrencyData() {
        
        if currencyItemsList.count == 0 {
            locationManager.startUpdatingLocation()
        }
        
        DataManager.getTopAppsDataFromFileWithSuccess{(data) -> Void in
            
            let dictionay: Dictionary = JSON(data:data).dictionary!
            
            for (shortName, fullName) in dictionay {
                
                var currency = CurrencyItem(shortName: shortName, fullName: fullName.string!, price: 1)
                self.allCurrencyItemList.append(currency)
            }
            self.allCurrencyItemList = self.allCurrencyItemList.sorted {$0.currencyShortName < $1.currencyShortName}
        }
        
        DataManager.getCurrencyDataFromAPIURLWithSuccess{(yahooData: AnyObject) -> Void in
            let jsonData = JSON(yahooData)
        
            if let currencyDict = jsonData["rates"].dictionary {
                for (shortName, price) in currencyDict {
                    for currencyItem in self.allCurrencyItemList {
                        if currencyItem.currencyShortName == shortName {
                            currencyItem.currencyPrice = price.doubleValue
                            if currencyItem.currencyShortName == "CNY" {
                                self.currencyItemsList.append(currencyItem)
                                self.baseMoneyInUSD = currencyItem.valueForTextField / currencyItem.currencyPrice
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
            
        }
        
    }
    
    
    func updateCurrencyPriceInArray(currencyItem: CurrencyItem, allCurrencyItemList: NSArray) {
        
        for i in 0..<allCurrencyItemList.count {
            let itemInCurrencyList: CurrencyItem = allCurrencyItemList[i] as! CurrencyItem
            
            if currencyItem.currencyShortName == itemInCurrencyList.currencyShortName {
                currencyItem.currencyPrice = itemInCurrencyList.currencyPrice
            }
        }

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
        let currencyForRow = currencyItemsList[indexPath.row]
        updateTableViewCellCustomViews(cell, currencyForRow: currencyForRow, indexPath: indexPath)
        
        return cell
    }
    
    func updateTableViewCellCustomViews(cell: UITableViewCell, currencyForRow: CurrencyItem, indexPath: NSIndexPath) {
        
        if indexPath.row == 0 {
            let imageView = cell.viewWithTag(10) as! UIImageView
            imageView.image = UIImage(named: "location")
        }
        
        let shortName = cell.viewWithTag(200) as! UILabel
        shortName.text = currencyForRow.currencyShortName
        
        let flagImageView = cell.viewWithTag(100) as! UIImageView
        flagImageView.image = UIImage(named: currencyForRow.currencyFlatName)
        flagImageView.layer.borderColor = UIColor.blackColor().CGColor
        flagImageView.layer.borderWidth = 0.1
        flagImageView.layer.cornerRadius = 32
        flagImageView.clipsToBounds = true
        
        let fullName = cell.viewWithTag(300) as! UILabel
        fullName.text = currencyForRow.currencyFullName
        
        let textField = cell.viewWithTag(400) as! UITextField
        if indexPath.row != selectedRow {
            textField.userInteractionEnabled = false
        }
        currencyForRow.valueForTextField = baseMoneyInUSD * currencyForRow.currencyPrice
        
        textField.text = String(format: "%.2f", currencyForRow.valueForTextField)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        currencyItemsList.removeAtIndex(indexPath.row)
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
            let currencyItem = currencyItemsList[i]
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
            updateCurrencyPriceInArray(currencyItem, allCurrencyItemList: allCurrencyItemList)
            currencyItemsList.append(currencyItem)
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
        selectedRow_Currency = currencyItemsList[selectedRow]
        selectedRow_Currency.valueForTextField = (textField.text as NSString).doubleValue
        
        baseMoneyInUSD = selectedRow_Currency.valueForTextField / selectedRow_Currency.currencyPrice
        
        for i in 0..<currencyItemsList.count {
            let currencyItem = currencyItemsList[i]
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
