//
//  DetailsTableViewCell.swift
//  HKTime
//
//  Created by TCSASSEMBLER on 12/29/14.
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
A details table view cell for holding a label and an image view

:author:  TCSASSEMBLER
:version: 1.0
*/
class DetailsTableViewCell: CustomTableViewCell {

    /// the icon image view
    @IBOutlet weak var iconImageView: UIImageView!
    /// the name label
    @IBOutlet weak var nameLabel: UILabel!

    /// The default spacing to use when laying out content in the view.
    override var layoutMargins: UIEdgeInsets {
        get {
            return UIEdgeInsetsZero
        }
        set {
            // does nothing
        }
    }
}
