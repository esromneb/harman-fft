//
//  RoomTableCell.swift
//  PageApp
//
//  Created by Seonman Kim on 1/15/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
* RoomTableCell
* Table cell for room list view
*
* @version 1.0
*/
class RoomTableCell: UITableViewCell {
    
    /// image view for icon
    @IBOutlet weak var iconImageView: UIImageView!
    
    /// label for room
    @IBOutlet weak var roomLabel: UILabel!
    
    /// n speakers label
    @IBOutlet weak var nSpeakersLabel: UILabel!
    
    /// mic button
    @IBOutlet weak var micButton: UIButton!
    
    /// mic effect
    @IBOutlet weak var micEffect: RotatedImageView!
    
    var deviceGroup: DeviceGroup!

    
    /// is the broadcasting began?
    var broadcasting: Bool = false
    
    var streamingActivity: StreamingActivityView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        streamingActivity = StreamingActivityView()
        var rect = CGRect(x: self.frame.width - 120, y: 40, width: 32, height: 20)
        streamingActivity.frame = rect
        addSubview(streamingActivity)
    }
    
    /*!
    Configure this cell
    
    :param: room the room using by this cell
    */
    func configureForRoom(groupName: String, iconName: String, count:Int, selected: Bool) {
        roomLabel.text = groupName
        iconImageView.image = UIImage(named: "\(iconName)")
        micButton.selected = selected

        if count == 1 {
            nSpeakersLabel.text = "\(count) Speaker"
        }
        else {
            nSpeakersLabel.text = "\(count) Speakers"
        }
    }
    
    /*!
    Start broadcasting
    */
    func startBroadcastingEffect() {
        micEffect.hidden = false
        micEffect.runAnimation()
    }
    
    /*!
    Stop broadcasting
    */
    func stopBroadcastingEffect() {
        micEffect.hidden = true
        micEffect.stopAnimation()
    }
    
    /*!
    Action on mic button did press
    
    :param: sender the sender object
    */
    @IBAction func micButtonDidPress(sender: AnyObject) {
        if broadcasting {
            return
        }
        
        // Set broadcast state for the room and its speakers
        micButton.selected = !micButton.selected
        
        if micButton.selected {
            for deviceInfo in deviceGroup.deviceList {
                HKWControlHandler.sharedInstance().addDeviceToSession(deviceInfo.deviceId)
            }
        } else {
            for deviceInfo in deviceGroup.deviceList {
                HKWControlHandler.sharedInstance().removeDeviceFromSession(deviceInfo.deviceId)
            }
        }
        
        // Post broadcast changed notification 
        NSNotificationCenter.defaultCenter().postNotificationName("BroadcastChangedNotification", object: nil)
    }
}
