//
//  AllCurrencyTableViewController.swift
//  Currency
//
//  Created by 黄俊明 on 15/7/26.
//  Copyright (c) 2015年 CS193p. All rights reserved.
//

import UIKit

class AllCurrencyTableViewController: UITableViewController {

    var delegate: AllCurrencyTableViewDelegate?
    
    let cellIdentifier: String = "AllCurrency"
    var allCurrencyItemList: NSMutableArray = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currency: CurrencyItem = CurrencyItem(shortName: "HKD", fullName: "港币", price: 7.0)
        allCurrencyItemList.addObject(currency)
        
        let currencyItem: CurrencyItem = CurrencyItem(shortName: "CNY", fullName: "人民币", price: 6.20)
        allCurrencyItemList.addObject(currencyItem)
        
        
    }
    
    @IBAction func cancel(sender: AnyObject) {
        delegate?.addItemFromAllCurrencyTableViewControllerDidCancel(self)
    }
    //MARK: - tabelViewDelegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionName = ""
        switch section {
        case 0:
            sectionName = "收藏"
            break
        case 1:
            sectionName = "所有"
            break
        default:
            sectionName = ""
            break
        }
        return sectionName
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allCurrencyItemList.count
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
        
        var fullName = cell.viewWithTag(300) as! UILabel
        fullName.text = currencyForRow.currencyFullName
        
    }
    
    
}
