//
//  CustomTableViewCell.swift
//  HKTime
//
//  Created by TCSASSEMBLER on 12/29/14.
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
This the base class for selectable cells as it provides a neat selectoin color

:author:  TCSASSEMBLER
:version: 1.0
*/
class CustomTableViewCell: UITableViewCell {

    /**
    The current view has been unarchived from a nib file.
    */
    override func awakeFromNib() {
        super.awakeFromNib()

        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.2)
        self.selectedBackgroundView = selectedBackgroundView
    }
}
