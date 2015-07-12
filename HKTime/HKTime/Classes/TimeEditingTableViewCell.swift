//
//  TimeEditingTableViewCell.swift
//  HKTime
//
//  Created by TCSASSEMBLER on 12/29/14.
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
The time table view cell which is responsible for editing the hours, minutes, period of the timer

:author:  TCSASSEMBLER
:version: 1.0
*/
class TimeEditingTableViewCell: UITableViewCell {

    /// the hours view
    @IBOutlet weak var hoursView: CustomPickerView!
    /// the minutes view
    @IBOutlet weak var minutesView: CustomPickerView!
    /// the seconds view
    @IBOutlet weak var secondsView: CustomPickerView!

    /**
    The selection button tapped action

    :param: sender the sender that initiated the action
    */
    @IBAction func selectionButtonTapped(sender: UIButton) {
        for view in [hoursView, minutesView, secondsView] {
            if view.selectionButton == sender {
                view.selectionButton.hidden = true
                view.backgroundColor = UIColor.appIdentityColor()
            } else {
                view.selectionButton.hidden = false
                view.backgroundColor = UIColor.clearColor()
            }
        }
    }
}


extension TimeEditingTableViewCell: UIPickerViewDataSource, UIPickerViewDelegate {

    /**
    Number of components for the picker view
    */
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    /**
    returns the # of rows in each component.
    */
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == hoursView.pickerView {
            return 100
        } else  {
            return 60
        }
    }

    /**
    Gets the view for the row
    */
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int,
        reusingView view: UIView!) -> UIView {

            var label: UILabel! = view as? UILabel
            if label == nil {
                label = UILabel()
                label.textColor = UIColor.whiteColor()
            }

            if pickerView == hoursView.pickerView {
                label.font = UIFont(name: "arial", size: 50)
                label.textAlignment = .Center
            } else  {
                label.font = UIFont(name: "arial", size: 50)
                label.textAlignment = .Right
            }

            // Fill the label text
            label.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
            return label
    }

    /**
    Gets the title for the row
    */
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {

        var value: String
        if pickerView == hoursView.pickerView {
            value = "\(row)"
        } else  {
            value = (row < 10 ? "0" : "") + "\(row)"
        }
        return value
    }

    /**
    Height for the rows
    */
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 70
    }
}