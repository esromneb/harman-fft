//
//  RoomSelectionTableViewCell.swift
//  HKPage
//
//  Created by Seonman Kim on 1/15/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

class RoomSelectionTableViewCell: UITableViewCell {
    
    /// image view for icon
    @IBOutlet weak var iconImageView: UIImageView!
    
    /// label for title
    @IBOutlet weak var titleLabel: UILabel!
    
    /// selected icon
    @IBOutlet weak var selectIcon: UIImageView!
    
    /*!
    Configure this cell
    
    :param: item the item using by this cell
    */
    func setItem(iconName: String, title: String, selected: Bool) {
        iconImageView.image = UIImage(named: iconName)
        titleLabel.text = title
        selectIcon.hidden = !selected
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
