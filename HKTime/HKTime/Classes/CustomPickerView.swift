//
//  CustomPickerView.swift
//  HKTime
//
//  Created by TCSASSEMBLER on 12/29/14.
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
A custom view for holding picker view and a selection button

:author:  TCSASSEMBLER
:version: 1.0
*/
class CustomPickerView: UIView {
    /// the picker view
    @IBOutlet weak var pickerView: UIPickerView!
    /// the selection button
    @IBOutlet weak var selectionButton: UIButton!
}