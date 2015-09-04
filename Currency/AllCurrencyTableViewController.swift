//
//  AllCurrencyTableViewController.swift
//  Currency
//
//  Created by 黄俊明 on 15/7/26.
//  Copyright (c) 2015年 CS193p. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import SWTableViewCell

class AllCurrencyTableViewController: UITableViewController {

    var delegate: AllCurrencyTableViewDelegate?
    
    let cellIdentifier: String = "AllCurrency"
    var allCurrencyItemList = [NSManagedObject]()
    var likedCurrencyItemList = [NSManagedObject]()
    
    var allCurrencyItemArray = [CurrencyItem]()
    
    
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        perpareData()
    
    }
    
    func fetchDataFromDatabase() -> Bool {
        
        var fetchRequest = NSFetchRequest(entityName: "AllCurrencyItem")
        var sortDescirptor = NSSortDescriptor(key: "shortName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescirptor]

        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        if fetchedResults?.count > 0 {
            allCurrencyItemList = fetchedResults!
            
            //likedCurrencyItemList
            fetchRequest = NSFetchRequest(entityName: "LikedCurrencyItem")
            let fetchedLikedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
            
            if fetchedLikedResults?.count > 0 {
                likedCurrencyItemList = fetchedLikedResults!
            } else {
                for i in 0..<allCurrencyItemList.count {
                    var shortName = ""
                    shortName = allCurrencyItemList[i].valueForKey("shortName") as! String
                    if shortName == "CNY" || shortName == "USD" || shortName == "EUR" || shortName == "JPY" {
                        likedCurrencyItemList.append(allCurrencyItemList[i])
                    }
                }
            }
            
            self.tableView.reloadData()
            return true
        } else {
            //print("Could not fetch \(error), \(error!.userInfo)")
            return false
        }
        
    }
    
    func perpareData() {
        
        if fetchDataFromDatabase() == false {
            DataManager.getTopAppsDataFromFileWithSuccess("currencies"){(data) -> Void in
                
                let dictionay: Dictionary = JSON(data:data).dictionary!
                
                for (shortName, fullName) in dictionay {
                    
                    var currency = CurrencyItem(shortName: shortName, fullName: fullName.string!, price: 1)
                    self.allCurrencyItemArray.append(currency)
                    
                }
                print("currencies success!")
            }
            
            DataManager.getTopAppsDataFromFileWithSuccess("latest") { (data) -> Void in
                let jsonData = JSON(data: data)
                if let currencyDict = jsonData["rates"].dictionary {
                    for (shortName, price) in currencyDict {
                        for currencyItem in self.allCurrencyItemArray {
                            if currencyItem.currencyShortName == shortName {
                                currencyItem.currencyPrice = price.doubleValue
                                
                                if shortName == "CNY" || shortName == "USD" || shortName == "EUR" || shortName == "JPY" {
                                    self.insertCurrencyItem(currencyItem, entityName: "LikedCurrencyItem")
                                }
                                self.insertCurrencyItem(currencyItem, entityName: "AllCurrencyItem")
                            }
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                }
            }
        }
        
    }
    
    func insertCurrencyItem(item: CurrencyItem, entityName: String) {
        
        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedContext)
        let currencyItem = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        currencyItem.setValue(item.currencyFlatName, forKey: "flatName")
        currencyItem.setValue(item.currencyFullName, forKey: "fullName")
        currencyItem.setValue(item.currencyPrice, forKey: "price")
        currencyItem.setValue(item.currencyShortName, forKey: "shortName")
        currencyItem.setValue(item.valueForTextField, forKey: "valueForTextField")
        
        saveCurrencyData()
        if entityName == "AllCurrencyItem" {
            allCurrencyItemList.append(currencyItem)
        } else {
            likedCurrencyItemList.append(currencyItem)
        }
        
    }
    
    func saveCurrencyData() {
        var error: NSError?
        if !managedContext.save(&error) {
            print("Could not save \(error), \(error?.userInfo)")
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
        var label: UILabel = UILabel()
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
        
        var error: NSError?
        
        switch indexPath.section {
        case 0:
            var currencyItem = CurrencyItem(shortName: "CNY", fullName: "", price: 1.0)
            currencyItem.getCurrencyItemFromNSManagedObject(likedCurrencyItemList[indexPath.row])
            delegate?.addItemFromAllCurrencyTableViewController(self, currencyItem: currencyItem)
            break
        case 1:
            var currencyItem = CurrencyItem(shortName: "CNY", fullName: "", price: 1.0)
            currencyItem.getCurrencyItemFromNSManagedObject(allCurrencyItemList[indexPath.row])
            delegate?.addItemFromAllCurrencyTableViewController(self, currencyItem: currencyItem)
            break
        default:
            break
        }
        
    }
    
//    func leftButtons() -> NSArray {
//        
//    }
//    
//    func rightButtons() -> NSArray {
//        var rightUtilityButtons = NSMutableArray()
//        rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 0.78, green: 0.78,f, blue: 0.8,f, alpha: 1.0), attributedTitle: "Delete")
//        
//        return rightUtilityButtons;
//    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! UITableViewCell
//        if cell == nil {
//            cell = SWTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
//            cell?.leftUtilityButtons = leftButtons()
//            cell?.rightUtilityButtons = rightButtons()
//            cell?.delegate = self
//        }
        
        switch indexPath.section {
        case 0:
            var currencyForRow = CurrencyItem(shortName: "CNY", fullName: "", price: 1.0)
            currencyForRow.getCurrencyItemFromNSManagedObject(likedCurrencyItemList[indexPath.row])
            updateTableViewCellCustomViews(cell, currencyForRow: currencyForRow, indexPath: indexPath)
            break
        case 1:
            var currencyForRow = CurrencyItem(shortName: "CNY", fullName: "", price: 1.0)
            currencyForRow.getCurrencyItemFromNSManagedObject(allCurrencyItemList[indexPath.row])
            updateTableViewCellCustomViews(cell, currencyForRow: currencyForRow, indexPath: indexPath)
            break
        default:
            break
        }
        
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
