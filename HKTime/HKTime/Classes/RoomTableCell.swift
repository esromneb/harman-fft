//
//  RoomTableCell.swift
//  HKTime
//
//  Created by TCSCODER on 12/17/14.
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
* RoomTableCell
* Table cell for room list view
*
* @author TCSCODER
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
    
    /// is the broadcasting began?
    var broadcasting: Bool = false
    
    var isForTimer = false
    
    var timer : TmpTimer?

    var groupIndex = 0

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
        
        // Set broadcast state for the room and its speakers
        micButton.selected = !micButton.selected
        
        if micButton.selected {
            // add if needed
            if let tmer = timer {
                var deviceGroup = g_HWControlHandler.getDeviceGroupByIndex(groupIndex)
                
                for deviceInfo in deviceGroup.deviceList {
                    tmer.addSpeaker(deviceInfo.deviceId)
                }
            }
        } else {
            // remove all the speakers in the group
            if let tmer = timer {
                var deviceGroup = g_HWControlHandler.getDeviceGroupByIndex(groupIndex)
                
                for deviceInfo in deviceGroup.deviceList {
                    tmer.removeSpeaker(deviceInfo.deviceId)
                }
            }
        }
        
    }
    
//    @IBAction func micButtonDidPress(sender: AnyObject) {
//        if broadcasting {
//            return
//        }
//        
//        // Set broadcast state for the room and its speakers
//        micButton.selected = !micButton.selected
//        if isForTimer {
//            true
//        }
//        room.broadcast = micButton.selected
//        room.setSpeakersBroadcastState()
//        
//        // Save to Core Data
//        AppDelegate.sharedInstance.saveContext()
//        
//        // Post broadcast changed notification 
//        NSNotificationCenter.defaultCenter().postNotificationName("BroadcastChangedNotification", object: nil)
//    }
}
