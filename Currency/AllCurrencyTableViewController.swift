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
    var allCurrencyItemList = [CurrencyItem]()
    var likedCurrencyItemList = [CurrencyItem]()
    
    var jsonDataFromYahoo: NSDictionary = NSDictionary()
    var currencyNamesDict: NSDictionary = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        perpareData()
    
    }
    
    func perpareData() {
        DataManager.getTopAppsDataFromFileWithSuccess { (data) -> Void in
            
            let dictionay: Dictionary = JSON(data:data).dictionary!
            
            var allCurrencyArray = [CurrencyItem]()
            var likedCurrencyArray = [CurrencyItem]()
            
            for (shortName, fullName) in dictionay {
                
                var currency = CurrencyItem(shortName: shortName, fullName: fullName.string!, price: 1)
                allCurrencyArray.append(currency)
                
                if shortName == "CNY" || shortName == "EUR" || shortName == "USD" {
                    likedCurrencyArray.append(currency)
                }
            }
            
            self.allCurrencyItemList = allCurrencyArray.sorted {$0.currencyShortName < $1.currencyShortName}
            self.likedCurrencyItemList = likedCurrencyArray.sorted {$0.currencyShortName < $1.currencyShortName}
            
            self.tableView.reloadData()
            
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
        
        switch indexPath.section {
        case 0:
            let currencyItem = likedCurrencyItemList[indexPath.row]
            delegate?.addItemFromAllCurrencyTableViewController(self, currencyItem: currencyItem)
            break
        case 1:
            let currencyItem = allCurrencyItemList[indexPath.row]
            delegate?.addItemFromAllCurrencyTableViewController(self, currencyItem: currencyItem)
            break
        default:
            break
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        switch indexPath.section {
        case 0:
            var currencyForRow = likedCurrencyItemList[indexPath.row]
            updateTableViewCellCustomViews(cell, currencyForRow: currencyForRow, indexPath: indexPath)
            break
        case 1:
            var currencyForRow = allCurrencyItemList[indexPath.row]
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
