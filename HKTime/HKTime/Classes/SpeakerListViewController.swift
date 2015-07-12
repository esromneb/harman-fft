//
//  SpeakerListViewController.swift
//  HKTime
//
//  Created by Seonman Kim on 2/1/2015.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit


/**
* SpeakerListViewController
* controller for speaker list with non-zero elements
*
* @version 1.0
*/
class SpeakerListViewController: UIViewController, UITableViewDataSource, SpeakerTableCellDelegate, HKWDeviceEventHandlerDelegate {
    
    /// the tableView
    @IBOutlet weak var tableView: UITableView!
    
    // Related alarm
    var timer: TmpTimer?
    
    /// current selected index
    var selectedIndex: NSIndexPath?
    
    /// is broadcasting?
    var broadcasting: Bool = false
    
    var selectedCell: SpeakerTableCell!
    var roomListVC: RoomListViewController!


    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "EditSpeakerSegue" {
                var controller = segue.destinationViewController as! EditSpeakerViewController

                
                println("selectedIndex.row: \(selectedIndex!.row)")
                
                var deviceInfo = g_HWControlHandler.getDeviceInfoByIndex(selectedIndex!.row)
                
                controller.deviceInfo = deviceInfo
                controller.speakerCell = selectedCell
            }
        }
    }
    
    // MARK: UITableView DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return g_HWControlHandler.getDeviceCount();
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SpeakerCell") as! SpeakerTableCell
        cell.cellIndex = indexPath
        cell.delegate = self
        
        var deviceInfo = g_HWControlHandler.getDeviceInfoByIndex(indexPath.row)
        
        cell.deviceInfo = deviceInfo
        cell.deviceNameLabel.text = deviceInfo.deviceName
        if deviceInfo.groupId == 0 {
            cell.roomLabel.text = kGroupNotAssigned
        } else {
            cell.roomLabel.text = "@" + deviceInfo.groupName
        }
        cell.iconImageView.image = getIconImageForModel(deviceInfo.modelName)
        
        cell.micButton.selected = false
        cell.isForAlarm = (timer != nil)
        if timer == nil {
            cell.micButton.enabled = false
        }


        if let tmer = timer  {
            for speaker in tmer.speakers {
                if deviceInfo.deviceId == speaker {
                    cell.micButton.selected = true
                }
            }
        }
        
        if deviceInfo.isPlaying {
            cell.streamingActivity.startAnimation()
        } else {
            cell.streamingActivity.stopAnimation()
        }
        
        return cell
    }
    
    // Return list of speakers that have checkmark selected
    func getSelectedSpeakers() -> [CLongLong] {
        var list = [CLongLong]()
        let deviceCount = g_HWControlHandler.getDeviceCount()
        println("getSelectedSpeakers: deviceCount: \(deviceCount)")
        
        for i in 0..<deviceCount {
            let index = NSIndexPath(forRow: i, inSection: 0)
            if let cell = tableView.cellForRowAtIndexPath(index) as? SpeakerTableCell {
                if cell.micButton.selected {
                    println("device added: \(cell.deviceInfo.deviceName)")
                    list.append(cell.deviceInfo.deviceId)
                    
                }
            }
        }
        return list
    }
    
    // MARK: SpeakerTableCell Delegate
    
    func speakerTableCell(speakerTableCell: SpeakerTableCell, editButtonDidPressAtIndex indexPath: NSIndexPath) {
        selectedIndex = indexPath
        self.performSegueWithIdentifier("EditSpeakerSegue", sender: self)
    }
    
    func speakerTableCell(speakerTableCell: SpeakerTableCell, deleteButtonDidPressAtIndex indexPath: NSIndexPath) {
    }
    
    // MARK: - HKWEventHandlerDelegate
    func hkwDeviceStateUpdated(deviceId: CLongLong, withReason reason:Int) {
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
