//
//  SpeakerTableViewCell.swift
//  HKTime
//
//  Created by TCSASSEMBLER on 12/31/14.
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
The speaker table view cell

:author:  TCSASSEMBLER
:version: 1.0
*/
class SpeakerTableViewCell: CustomTableViewCell {

    /// the selection button
    @IBOutlet weak var selectionButton: UIButton!
    /// the name label
    @IBOutlet weak var nameLabel: UILabel!
    /// the room label
    @IBOutlet weak var roomLabel: UILabel!
    /// the speaker status image
    @IBOutlet weak var statusImage: UIImageView!
    /// the speaker big thumbnail image
    @IBOutlet weak var bigImageView: UIImageView!

    /**
    Sets the state of the speaker
    */
    func setIsActiveSpeaker(isActive: Bool) {
        statusImage.image = UIImage(named: isActive ? "status-active": "status-inactive")
    }
}