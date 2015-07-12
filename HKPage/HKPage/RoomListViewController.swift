//
//  RoomListViewController.swift
//  PageApp
//
//  Created by Seonman Kim on 1/15/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
* RoomListViewController
* Controller for showing room list
*
* @version 1.0
*/
class RoomListViewController: UIViewController, UITableViewDataSource, HKWDeviceEventHandlerDelegate {
    
    /// the tableView
    @IBOutlet weak var tableView: UITableView!
    
    /// is broadcasting?
    var broadcasting: Bool = false
    
    var voiceRecorder: VoiceRecorder!

    
    // MARK: UIViewController
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        voiceRecorder = VoiceRecorder()
        voiceRecorder.viewController = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        HKWDeviceEventHandlerSingleton.sharedInstance().delegate = self
        
        HKWControlHandler.sharedInstance().startRefreshDeviceInfo()

        NSNotificationCenter.defaultCenter().postNotificationName("BroadcastChangedNotification", object: nil)

    }
    
    override func viewDidDisappear(animated: Bool) {
        HKWControlHandler.sharedInstance().stopRefreshDeviceInfo()

        HKWDeviceEventHandlerSingleton.sharedInstance().delegate = nil
    }

    
    /*!
    Set broadcast status
    
    :param: broadcast broadcast status
    */
    func setBroadcastAll(broadcast: Bool) {
    }
    
    /*!
    Start broadcasting
    */
    func startBroadcasting() {
        broadcasting = true
        
        // Set all visible cells to start broadcasting effect
        for visibleCell in tableView.visibleCells() {
            var roomCell = visibleCell as! RoomTableCell
            roomCell.broadcasting = true
            if roomCell.micButton.selected {
                roomCell.startBroadcastingEffect()
            }
        }
        
        voiceRecorder.startRecordingVoice()
    }
    
    /*!
    Stop broadcasting
    */
    func stopBroadcasting() {
        voiceRecorder.stopRecodingVoice()

        
        broadcasting = false
        
        // Set all visible cells to stop broadcasting effect
        for visibleCell in tableView.visibleCells() {
            var roomCell = visibleCell as! RoomTableCell
            roomCell.broadcasting = false
            if roomCell.micButton.selected {
                roomCell.stopBroadcastingEffect()
            }
        }
    }
    
    // MARK: UITableView DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HKWControlHandler.sharedInstance().getGroupCount()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("RoomCell") as! RoomTableCell
        
        var deviceGroup = HKWControlHandler.sharedInstance().getDeviceGroupByIndex(indexPath.row)
        
        // check if any of devices in the group is inactive
        var deviceAllActive = true
        for deviceInfo in deviceGroup.deviceList {

            if !deviceInfo.active {
                deviceAllActive = false
                break
            }
        }
        
        var groupName = HKWControlHandler.sharedInstance().getDeviceGroupNameByIndex(indexPath.row)
        if deviceGroup.groupId == 0 {
            groupName = kGroupNotAssigned
        }
        
        var deviceCount = HKWControlHandler.sharedInstance().getDeviceCountInGroupIndex(indexPath.row)
        
        var groupIcon = getGroupIconName(groupName)

        cell.configureForRoom(groupName, iconName: groupIcon, count: deviceCount, selected: deviceAllActive)
        cell.deviceGroup = deviceGroup
        
        
        cell.broadcasting = broadcasting

        var roomPlaying = false
        for deviceInfo in deviceGroup.deviceList {
            if deviceInfo.isPlaying == true {
                roomPlaying = true
                break
            }
        }
        
        if roomPlaying {
            cell.streamingActivity.startAnimation()
        } else {
            cell.streamingActivity.stopAnimation()
        }


        return cell
    }
    
    
    // MARK: - HKWEventHandlerDelegate
    func hkwDeviceStateUpdated(deviceId: CLongLong, withReason reason: Int) {
        self.tableView.reloadData()
        NSNotificationCenter.defaultCenter().postNotificationName("BroadcastChangedNotification", object: nil)
    }
    
    
    func hkwErrorOccurred(errorCode: Int, withErrorMessage errorMesg: String!) {
        println("errorOccurred")
        var errorString = "Error(\(errorCode)): " + errorMesg
        var alert = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "STOP", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

