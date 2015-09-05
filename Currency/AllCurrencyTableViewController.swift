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
import MGSwipeTableCell

class AllCurrencyTableViewController: UITableViewController, MGSwipeTableCellDelegate {

    var delegate: AllCurrencyTableViewDelegate?
    
    let cellIdentifier: String = "AllCurrency"
    var allCurrencyItemList = [NSManagedObject]()
    var likedCurrencyItemList = [NSManagedObject]()
    
    var allCurrencyItemArray = [CurrencyItem]()
    
    
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.separatorInset = UIEdgeInsetsZero
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
                                } else {
                                    self.insertCurrencyItem(currencyItem, entityName: "AllCurrencyItem")
                                }
                            }
                        }
                    }
                    
                    self.fetchDataFromDatabase()
                    
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
        label.textColor = UIColor(red: 0.1137, green: 0.3451, blue: 0.8118, alpha: 1.0)
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: AllCurrencyTableCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? AllCurrencyTableCell

        if cell == nil {
            cell = AllCurrencyTableCell(style: UITableViewCellStyle.Default , reuseIdentifier: cellIdentifier)
        }
        
        cell?.delegate = self
        
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
    
    
    func updateTableViewCellCustomViews(cell: AllCurrencyTableCell!, currencyForRow: CurrencyItem, indexPath: NSIndexPath) {
        
        cell.shortNameLabel.text = currencyForRow.currencyShortName
        cell.fullNameLabel.text = currencyForRow.currencyFullName
        cell.flagImageView.image = UIImage(named: currencyForRow.currencyShortName.lowercaseString)
        cell.flagImageView.layer.borderColor = UIColor.blackColor().CGColor
        cell.flagImageView.layer.borderWidth = 0.1
        cell.flagImageView.layer.cornerRadius = 32
        cell.flagImageView.clipsToBounds = true
        
        cell.layoutMargins = UIEdgeInsetsZero
        
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
    }
    
    //MARK: - Swipe Delegate
    func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [AnyObject]! {
        swipeSettings.transition = MGSwipeTransition.ClipCenter
        swipeSettings.keepButtonsSwiped = true
        expansionSettings.buttonIndex = 0
        expansionSettings.threshold = 1
        expansionSettings.expansionLayout = MGSwipeExpansionLayout.Border
        expansionSettings.fillOnTrigger = true
        
        let indexPath: NSIndexPath = self.tableView.indexPathForCell(cell)!
        let font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
        if indexPath.section == 0 {
            let color = UIColor(red: 255.0/255.0, green: 30.0/255.0, blue: 29.0/255.0, alpha: 1.0)
            expansionSettings.expansionColor = color
            if direction == MGSwipeDirection.RightToLeft {
                var deleteButton = MGSwipeButton(title: "DELETE", backgroundColor: color, padding: 15, callback: { (sender: MGSwipeTableCell!) -> Bool in
                    
                    let item = CurrencyItem(shortName: (self.likedCurrencyItemList[indexPath.row].valueForKey("shortName") as! String), fullName:(self.likedCurrencyItemList[indexPath.row].valueForKey("fullName") as! String), price: self.likedCurrencyItemList[indexPath.row].valueForKey("price") as! Double)
                    self.insertCurrencyItem(item, entityName: "AllCurrencyItem")
                    
                    let indexPaths = NSIndexPath(forRow: self.allCurrencyItemList.count - 1, inSection: 1)
                    self.tableView.insertRowsAtIndexPaths([indexPaths], withRowAnimation: UITableViewRowAnimation.None)
                    
                    
                    self.managedContext.deleteObject(self.likedCurrencyItemList[indexPath.row])
                    self.likedCurrencyItemList.removeAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    
                    self.saveCurrencyData()
                    return false
                })
                deleteButton.titleLabel?.font = font;
                return [deleteButton]
            }
            
        } else {
            let color = UIColor(red:33/255.0, green:175/255.0, blue:67/255.0, alpha:1.0)
            expansionSettings.expansionColor = color
            if direction == MGSwipeDirection.LeftToRight {
                var likedButton = MGSwipeButton(title: "LIKED", backgroundColor: color, padding: 20, callback: { (sender: MGSwipeTableCell!) -> Bool in
                    
                    let item = CurrencyItem(shortName: (self.allCurrencyItemList[indexPath.row].valueForKey("shortName") as! String), fullName:(self.allCurrencyItemList[indexPath.row].valueForKey("fullName") as! String), price: self.allCurrencyItemList[indexPath.row].valueForKey("price") as! Double)
                    self.insertCurrencyItem(item, entityName: "LikedCurrencyItem")
                    let indexPaths = NSIndexPath(forRow: self.likedCurrencyItemList.count - 1, inSection: 0)
                    
                    self.tableView.insertRowsAtIndexPaths([indexPaths], withRowAnimation: UITableViewRowAnimation.Left)
                    
                    self.managedContext.deleteObject(self.allCurrencyItemList[indexPath.row])
                    self.allCurrencyItemList.removeAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                    
                    self.saveCurrencyData()
                    
                    return true
                })
                likedButton.titleLabel?.font = font
                return [likedButton]
            }
        }
        return nil
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, didChangeSwipeState state: MGSwipeState, gestureIsActive: Bool) {
        var str: String
        switch (state) {
        case MGSwipeState.None:
            str = "None"
            break
        case MGSwipeState.SwipingLeftToRight:
            str = "SwippingLeftToRight"
            break
        case MGSwipeState.SwipingRightToLeft:
            str = "SwipingRightToLeft"
            break
        case MGSwipeState.ExpandingLeftToRight:
            str = "ExpandingLeftToRight"
            break
        case MGSwipeState.ExpandingRightToLeft:
            str = "ExpandingRightToLeft"
            break
        }
        if gestureIsActive {
            print("Swipe state: \(str) ::: Gesture: Active")
        } else {
            print("Swipe state: \(str) ::: Gesture: Ended")
        }
        
    }
    
}
