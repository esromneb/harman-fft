//
//  BlueTabButton.swift
//  HKTime
//
//  Created by TCSCODER on 12/17/14.
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
* BlueTabButton
* Tab button used by speaker list tab
*
* @author TCSCODER
* @version 1.0
*/
class BlueTabButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }    
    
    override var highlighted: Bool {
        get {
            return super.highlighted
        }
        set {
            if !self.selected {
                if newValue {
                    backgroundColor = UIColor(red: 18/255, green: 48/255, blue: 67/255, alpha: 1.0)
                }
                else {
                    backgroundColor = UIColor.clearColor()
                }
                super.highlighted = newValue
            }
        }
    }
    
    override var selected: Bool {
        get {
            return super.selected
        }
        set {
            if newValue {
                self.highlighted = false
                backgroundColor = UIColor(red: 18/255, green: 48/255, blue: 67/255, alpha: 1.0)
            }
            else {
                self.highlighted = true
                backgroundColor = UIColor.clearColor()
            }
            super.selected = newValue
        }
    }
}

