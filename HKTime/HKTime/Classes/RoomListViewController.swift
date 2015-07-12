//
//  RoomListViewController.swift
//  HKTime
//
//  Created by Seonman Kim on 2/1/2015.
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
    
    // Related alarm
    var timer: TmpTimer?
    
    /// is broadcasting?
    var broadcasting: Bool = false
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        HKWDeviceEventHandlerSingleton.sharedInstance().delegate = self

        g_HWControlHandler.startRefreshDeviceInfo()
        g_refreshingDevices = true
    NSNotificationCenter.defaultCenter().postNotificationName("BroadcastChangedNotification", object: nil)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        g_HWControlHandler.stopRefreshDeviceInfo()
        g_refreshingDevices = false

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

    }
    
    /*!
    Stop broadcasting
    */
    func stopBroadcasting() {
    }
    
    // MARK: UITableView DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return g_HWControlHandler.getGroupCount()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("RoomCell") as! RoomTableCell
        
        
        var deviceGroup = g_HWControlHandler.getDeviceGroupByIndex(indexPath.row)
        
        // check if any of devices in the group is inactive
        // If one of device in the group is inactive, then the group is inactive.
        var deviceAllActive = true
        if let tmer = timer {
            for deviceInfo in deviceGroup.deviceList {
                var included = false
                for speaker in tmer.speakers {
                    if deviceInfo.deviceId == speaker {
                        included = true
                        break
                    }
                }
                
                if !included {
                    deviceAllActive = false
                    break
                }
            }
        }
        
        
        var groupName = g_HWControlHandler.getDeviceGroupNameByIndex(indexPath.row)
        if deviceGroup.groupId == 0 {
            groupName = kGroupNotAssigned
        }
        
        var deviceCount = g_HWControlHandler.getDeviceCountInGroupIndex(indexPath.row)
        
        var groupIcon = getGroupIconName(groupName)
        
        cell.micButton.enabled = (timer != nil)
        cell.timer = timer
        cell.groupIndex = indexPath.row

        cell.configureForRoom(groupName, iconName: groupIcon, count: deviceCount, selected: deviceAllActive)        
        
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
    
    // Return list of speakers that correspond to the selected rooms
    func getSelectedSpeakers() -> [CLongLong] {
        var list = [CLongLong]()
        let groupCount = g_HWControlHandler.getGroupCount()
        
        for i in 0..<groupCount {
            let index = NSIndexPath(forRow: i, inSection: 0)
            if let cell = tableView.cellForRowAtIndexPath(index) as? RoomTableCell {
                if cell.micButton.selected {
                    let deviceGroup = g_HWControlHandler.getDeviceGroupByIndex(i)
                    
                    for deviceInfo in deviceGroup.deviceList {
                        list.append(deviceInfo.deviceId)
                    }
                    
                }
            }
        }
        return list
    }
    
    func hkwDeviceStateUpdated(deviceId: Int64, withReason reason: Int) {
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

