//
//  DeleteTableViewCell.swift
//  HKTime
//
//  Created by TCSASSEMBLER on 12/29/14.
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
The delete timer table view cell

:author:  TCSASSEMBLER
:version: 1.0
*/
class DeleteTableViewCell: UITableViewCell {

    /// the delete button
    @IBOutlet weak var deleteButton: UIButton!

    /**
    Set selection state of the cell
    */
    override func setSelected(selected: Bool, animated: Bool) {
        // does nothing
    }

    /**
    Set the highlighting state of the cell
    */
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        deleteButton.highlighted = highlighted
    }

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
