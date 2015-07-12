//
//  TimerTableViewCell.swift
//  HKTime
//
//  Created by TCSASSEMBLER on 12/28/14.
//  Updated by Fabrizio Lovato - fabrizyo on 02/20/2015
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
The timer table view cell delegate protocol

:author:  TCSASSEMBLER
:version: 1.0
:
:author:  Fabrizio Lovato - fabrizyo
:version: 1.1
*/
@objc
protocol TimerTableViewCellDelegate {
    func timerTableViewCell(timerTableViewCell: TimerTableViewCell, isActiveChangedTo isActive: Bool)
}

/**
The timer table view cell

:author:  TCSASSEMBLER
:version: 1.0
:author:  Fabrizio Lovato - fabrizyo
:version: 1.1
*/
class TimerTableViewCell: CustomTableViewCell {

    /// the top line view
    @IBOutlet weak var topLine: UIView!
    /// the time label
    @IBOutlet weak var timeLabel: UILabel!
    /// the period label
    @IBOutlet weak var periodLabel: UILabel!
    /// the repetition label
    @IBOutlet weak var repetitionLabel: UILabel!
    /// the speaker details label
    @IBOutlet weak var speakerDetailsLabel: UILabel!
    /// the switch control
    @IBOutlet weak var switchControl: CustomSwitch!
    /// the reset button
    @IBOutlet weak var resetButton: UIButton!

    /// the delegate
    weak var delegate: TimerTableViewCellDelegate?
    
    weak var timer: Timer?

    /**
    The current view has been unarchived from a nib file.
    */
    override func awakeFromNib() {
        super.awakeFromNib()

        switchControl.delegate = self
        backgroundView = UIImageView()
    }

    func setAlternate(alernate: Bool) {
        let imageView = (self.backgroundView as? UIImageView)
        if alernate {
            imageView?.image = UIImage(named: "cell-bg2")
        } else {
            imageView?.image = UIImage(named: "cell-bg1")
        }
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

extension TimerTableViewCell: CustomSwitchDelegate {
    /**
    switch state changed
    */
    func customSwitch(customSwitch: CustomSwitch, stateChangedTo isOn: Bool) {
        delegate?.timerTableViewCell(self, isActiveChangedTo: isOn)
    }
}