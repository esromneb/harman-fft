//
//  CustomTextView.swift
//  HKTime
//
//  Created by TCSCODER on 12/20/14.
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
* CustomTextView
* TextView with accessory done button
*
* @author TCSCODER
* @version 1.0
*/
class CustomTextView: UITextView {
    
//    override init() {
//        super.init()
//        addAccessoryView()
//    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addAccessoryView()
    }
    
    // Add accessory view to TextField
    // To show done button in UIToolbar above keyboard
    func addAccessoryView() {
        let accessoryView = UIToolbar()
        accessoryView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        accessoryView.sizeToFit()
        var frame = accessoryView.frame
        frame.size.height = 44.0
        accessoryView.frame = frame
        
        // done button
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "doneButtonDidPress:")
        let flexibleSpaceLeft = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        accessoryView.setItems([flexibleSpaceLeft, doneButton], animated: false)
        self.inputAccessoryView = accessoryView
    }
    
    func doneButtonDidPress(sender: AnyObject) {
        self.resignFirstResponder()
    }
}
