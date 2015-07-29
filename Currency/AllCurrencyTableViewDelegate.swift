//
//  AddItemFromAllCurrencyViewController.swift
//  Currency
//
//  Created by 黄俊明 on 15/7/29.
//  Copyright (c) 2015年 CS193p. All rights reserved.
//

import UIKit

protocol AllCurrencyTableViewDelegate {
    
    func addItemFromAllCurrencyTableViewController(controller: AllCurrencyTableViewController, currencyItem: CurrencyItem)
    func addItemFromAllCurrencyTableViewControllerDidCancel(controller: AllCurrencyTableViewController)
    
}
