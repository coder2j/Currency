//
//  AllCurrencyTableViewCell.swift
//  Currency
//
//  Created by 黄俊明 on 15/9/5.
//  Copyright (c) 2015年 CS193p. All rights reserved.
//

import MGSwipeTableCell

class AllCurrencyTableCell: MGSwipeTableCell {
    var shortNameLabel: UILabel
    var fullNameLabel: UILabel
    var flagImageView: UIImageView
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        self.shortNameLabel = UILabel(frame: CGRectZero)
        self.fullNameLabel = UILabel(frame: CGRectZero)
        self.flagImageView = UIImageView(frame: CGRectZero)
        
        self.shortNameLabel.font = UIFont(name: self.shortNameLabel.font.fontName, size: 17.0)
        self.fullNameLabel.font = UIFont(name: self.fullNameLabel.font.fontName, size: 12.0)

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(shortNameLabel)
        self.contentView.addSubview(fullNameLabel)
        self.contentView.addSubview(flagImageView)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shortNameLabel.frame = CGRectMake(10, 21, 42, 21)
        fullNameLabel.frame = CGRectMake(10, 56, 214, 16)
        flagImageView.frame = CGRectMake(self.contentView.bounds.size.width - 10 - 65 , 10, 65, 65)
    }
    

}