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
import CoreData

class mainTableViewController: UITableViewController, UITextFieldDelegate, AllCurrencyTableViewDelegate, CLLocationManagerDelegate {

    //MARK: - property
    
    let calculatorCurrencyIdentifier = "Calculator_Currency"
    var notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
    var currencyItemsMain = [NSManagedObject]()
    var allCurrencyItems = [NSManagedObject]()

    var setting = [NSManagedObject]()
    
    let heightForTableViewCell: Int = 85
    
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.rowHeight = 85
        
        pepareCurrencyData()
        
        var refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.refreshControl = refreshControl
        
    }
    
    
    func refresh(sender: AnyObject) {
        
        Alamofire.request(.GET, openExchange).responseJSON { request, response, json, error in
            if error == nil {
                
                let jsonData = JSON(json!)
                if let currencyDict = jsonData["rates"].dictionary {
                    for (shortName, price) in currencyDict {
                        for i in 0..<self.currencyItemsMain.count {
                            if (self.currencyItemsMain[i].valueForKey("shortName") as! String) == shortName {
                                self.currencyItemsMain[i].setValue(price.doubleValue, forKey: "price")
                            }
                        }
                    }
                }
                
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
                
            } else {
                print(error)
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    func fetchDataFromDatabase() -> Bool {
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "AddedCurrencyItem")
        
        //3
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        if fetchedResults?.count > 0 {
            currencyItemsMain = fetchedResults!
            
            let fetchRequestSetting = NSFetchRequest(entityName: "Setting")
            let fetchSettingResults = managedContext.executeFetchRequest(fetchRequestSetting, error: &error) as? [NSManagedObject]
            
            if fetchSettingResults?.count == 1 {
                
                setting = fetchSettingResults!
                return true
            } else {
                return false
            }
            
        } else {
            //print("Could not fetch \(error), \(error!.userInfo)")
            return false
        }
    }
    
    func saveSetting(baseMoneyInUSD: Double, selectedRow: Int) {
        
        let entity = NSEntityDescription.entityForName("Setting", inManagedObjectContext: managedContext)
        let setting = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        setting.setValue(baseMoneyInUSD, forKey: "baseMoneyInUSD")
        setting.setValue(selectedRow, forKey: "selectedRow")
        self.setting.append(setting)
        saveCurrencyData()
    }
    
    func insertItemToAddedCurrencyItem(item: CurrencyItem) {
        
        let entity = NSEntityDescription.entityForName("AddedCurrencyItem", inManagedObjectContext: managedContext)
        let currencyItem = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        currencyItem.setValue(item.currencyFlatName, forKey: "flatName")
        currencyItem.setValue(item.currencyFullName, forKey: "fullName")
        currencyItem.setValue(item.currencyPrice, forKey: "price")
        currencyItem.setValue(item.currencyShortName, forKey: "shortName")
        currencyItem.setValue(item.valueForTextField, forKey: "valueForTextField")
        
        saveCurrencyData()
        
        currencyItemsMain.append(currencyItem)
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    func pepareCurrencyData() {
        
        if fetchDataFromDatabase() == false {
            DataManager.getTopAppsDataFromFileWithSuccess("currencies"){(data) -> Void in
                
                let dictionay: Dictionary = JSON(data:data).dictionary!
                
                for (shortName, fullName) in dictionay {
                    
                    if shortName == "USD" {
                        DataManager.getTopAppsDataFromFileWithSuccess("latest") { (data) -> Void in
                            let jsonData = JSON(data: data)
                            if let currencyDict = jsonData["rates"].dictionary {
                                for (shortNameInLatest, price) in currencyDict {
                                    if shortNameInLatest == shortName {
                                        var currencyItem = CurrencyItem(shortName: shortName, fullName: fullName.string!, price: price.doubleValue)
                                        var baseMoneyInUSD: Double = currencyItem.valueForTextField / currencyItem.currencyPrice
                                        var selectedRow = 0
                                        
                                        self.saveSetting(baseMoneyInUSD, selectedRow: selectedRow)
                                        self.insertItemToAddedCurrencyItem(currencyItem)
                                    }
                                }
                            }
                        }
                    }
                }
                
                print("currencies success!")
            }
        }
    }

    
    
    //MARK: - tableViewDelegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("cout is \(currencyItemsMain.count) \n")
        return currencyItemsMain.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(calculatorCurrencyIdentifier, forIndexPath: indexPath) as! UITableViewCell
        let currencyForRow = currencyItemsMain[indexPath.row]
        updateTableViewCellCustomViews(cell, currencyForRow: currencyForRow, indexPath: indexPath)
        
        return cell
    }
    
    func updateTableViewCellCustomViews(cell: UITableViewCell, currencyForRow: NSManagedObject, indexPath: NSIndexPath) {
        
        
        let shortName = cell.viewWithTag(200) as! UILabel
        shortName.text = currencyForRow.valueForKey("shortName") as? String
        
        let flagImageView = cell.viewWithTag(100) as! UIImageView
        flagImageView.image = UIImage(named: (currencyForRow.valueForKey("flatName") as? String)!)
        flagImageView.layer.borderColor = UIColor.blackColor().CGColor
        flagImageView.layer.borderWidth = 0.1
        flagImageView.layer.cornerRadius = 32
        flagImageView.clipsToBounds = true
        
        let fullName = cell.viewWithTag(300) as! UILabel
        fullName.text = currencyForRow.valueForKey("fullName") as? String
        
        let textField = cell.viewWithTag(400) as! UITextField
        if indexPath.row != setting[0].valueForKey("selectedRow") as! Int {
            textField.userInteractionEnabled = false
        }
        
        var valueForTextField: Double
        
        if indexPath.row == setting[0].valueForKey("selectedRow") as! Int {
            valueForTextField = currencyForRow.valueForKey("valueForTextField") as! Double
        } else {
            valueForTextField = (setting[0].valueForKey("baseMoneyInUSD") as! Double) * (currencyForRow.valueForKey("price") as! Double)
            
            currencyForRow.setValue(valueForTextField, forKey: "valueForTextField")
            saveCurrencyData()
        }
        
        textField.text = String(format: "%.2f", valueForTextField)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        managedContext.deleteObject(currencyItemsMain[indexPath.row])
        currencyItemsMain.removeAtIndex(indexPath.row)
        saveCurrencyData()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        setting[0].setValue(indexPath.row, forKey: "selectedRow")
        
        
        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        let textField = cell.viewWithTag(400) as! UITextField
        
        textField.userInteractionEnabled = true
        textField.placeholder = textField.text //make the origin textfield value as the placeholder
        textField.becomeFirstResponder()
        notificationCenter.addObserver(self, selector: "textField_Value_Changed:", name: UITextFieldTextDidChangeNotification, object: textField)  //listen to the keyboard, when button is tapped update the money in different currency
        
        // refresh cell incase nothing was input
        for i in 0..<currencyItemsMain.count {
            if i != setting[0].valueForKey("selectedRow") as! Int {
                let indexPath: NSIndexPath = NSIndexPath(forRow: i, inSection: 0)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAllCurrency" {
            let navigation = segue.destinationViewController as! UINavigationController
            let add = navigation.topViewController as! AllCurrencyTableViewController
            add.delegate = self
        }
    }
    
    func addItemFromAllCurrencyTableViewController(controller: AllCurrencyTableViewController, currencyItem: CurrencyItem) {
        
        if currencyItem.checkForEquality(currencyItemsMain) == false {
            
            insertItemToAddedCurrencyItem(currencyItem)
            
            let indexPath: NSIndexPath = NSIndexPath(forRow: currencyItemsMain.count - 1, inSection: 0)
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
        
        var selectedRow = setting[0].valueForKey("selectedRow") as! Int
        var textFieldValueForSelectedRow: Double = (textField.text as NSString).doubleValue
        var baseMoneyInUSD = textFieldValueForSelectedRow / (currencyItemsMain[selectedRow].valueForKey("price") as! Double)
        
        setting[0].setValue(baseMoneyInUSD, forKey: "baseMoneyInUSD")
        currencyItemsMain[selectedRow].setValue(textFieldValueForSelectedRow, forKey: "valueForTextField")
        
        for i in 0..<currencyItemsMain.count {

            if i != selectedRow {
                let valueForTextField = baseMoneyInUSD * (currencyItemsMain[i].valueForKey("price") as! Double)
                currencyItemsMain[i].setValue(valueForTextField, forKey: "valueForTextField")
                let indexPath: NSIndexPath = NSIndexPath(forRow: i, inSection: 0)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            }
        }
        
        saveCurrencyData()
        
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
    
    func saveCurrencyData() {
        var error: NSError?
        if !managedContext.save(&error) {
            print("Could not save \(error), \(error?.userInfo)")
        }
    }
}
