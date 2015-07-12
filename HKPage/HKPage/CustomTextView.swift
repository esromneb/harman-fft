//
//  CustomTextView.swift
//  PageApp
//
//  Created by Seonman Kim on 1/15/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
* CustomTextView
* TextView with accessory done button
*
* @version 1.0
*/
class CustomTextView: UITextView {
    
    
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
