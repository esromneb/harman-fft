//
//  AlarmSoundSelectionTableViewCell.swift
//  HKPage
//
//  Created by Seonman Kim on 2/16/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

class AlarmSoundSelectionTableViewCell: UITableViewCell {

    
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
    
    func setItem(title: String, selected: Bool) {

        titleLabel.text = title
        selectIcon.hidden = !selected
    }
    
    func inverseColor(image: UIImage) -> UIImage {
        var coreImage: CIImage = CIImage(CGImage: image.CGImage)
        var filter: CIFilter = CIFilter(name: "CIColorInvert")
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        var result: CIImage = filter.valueForKey(kCIOutputImageKey) as! CIImage
        return UIImage(CIImage: result)!
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
