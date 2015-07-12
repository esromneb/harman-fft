//
//  SpeakerListViewController.swift
//  PageApp
//
//  Created by Seonman Kim on 1/15/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit


class SpeakerListViewController: UIViewController, UITableViewDataSource, SpeakerTableCellDelegate, HKWDeviceEventHandlerDelegate  {
    
    /// the tableView
    @IBOutlet weak var tableView: UITableView!
    
    
    /// current selected index
    var selectedIndex: NSIndexPath?
    
    /// is broadcasting?
    var broadcasting: Bool = false
    
    
    var selectedCell: SpeakerTableCell!
    
    var roomListVC: RoomListViewController!
    
    var voiceRecorder: VoiceRecorder!
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("SpeakerListViewController: viewDidLoad()")
        
        voiceRecorder = VoiceRecorder()
        voiceRecorder.viewController = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        println("SpeakerListViewController: viewWillAppear()")


        self.tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        println("SpeakerListViewController: viewDidAppear()")

        HKWDeviceEventHandlerSingleton.sharedInstance().delegate = self
        
        HKWControlHandler.sharedInstance().startRefreshDeviceInfo()
        
        NSNotificationCenter.defaultCenter().postNotificationName("BroadcastChangedNotification", object: nil)

    }

    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        HKWControlHandler.sharedInstance().stopRefreshDeviceInfo()

        HKWDeviceEventHandlerSingleton.sharedInstance().delegate = nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      
        if (segue.identifier != nil) {
            var identifier: String = segue.identifier!

            if identifier == "EditSpeakerSegue" {
                var controller = segue.destinationViewController as! EditSpeakerViewController
                
                var deviceInfo = HKWControlHandler.sharedInstance().getDeviceInfoByIndex(selectedIndex!.row)
                controller.deviceInfo = deviceInfo
                controller.speakerCell = selectedCell
                
            }
        }
    }
    
    /*!
    Set broadcast status
    
    :param: broadcast broadcast status
    */
    func setBroadcastAll(broadcast: Bool) {
        // Set speaker broadcast status
        
        // Set current visible cells broadcast status
        for visibleCell in tableView.visibleCells() {
            var speakerCell = visibleCell as! SpeakerTableCell
            speakerCell.micButton.selected = broadcast
        }
    }
    
    /*!
    Start broadcasting
    */
    func startBroadcasting() {
        broadcasting = true
        
        // Set all visible cells to start broadcasting effect
        for visibleCell in tableView.visibleCells() {
            var speakerCell = visibleCell as! SpeakerTableCell
            speakerCell.broadcasting = true
            
            if speakerCell.deviceInfo.active {
                speakerCell.startBroadcastingEffect()
            }
        }
        
        // Seonman: start recording voice here
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
            var speakerCell = visibleCell as! SpeakerTableCell
            speakerCell.broadcasting = false

            if speakerCell.deviceInfo.active {

                speakerCell.stopBroadcastingEffect()
            }
        }
    }
    
    // MARK: UITableView DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return HKWControlHandler.sharedInstance().getDeviceCount();
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SpeakerCell") as! SpeakerTableCell
        cell.cellIndex = indexPath
        cell.delegate = self

        var deviceInfo = HKWControlHandler.sharedInstance().getDeviceInfoByIndex(indexPath.row)
        
        println("----------------------------------")
        println("deviceName: \(deviceInfo.deviceName)")
        println("zoneName: \(deviceInfo.zoneName)")
        println("groupName: \(deviceInfo.groupName)")
        println("groupId: \(deviceInfo.groupId)")
        println("volume: \(deviceInfo.volume)")
        println("deviceId: \(deviceInfo.deviceId)")
        println("deviceActive: \(deviceInfo.active)")
        println("modelName: \(deviceInfo.modelName)")
        println("wifiStrength: \(deviceInfo.wifiSignalStrength)")
        println("----------------------------------")
        
        cell.deviceInfo = deviceInfo
        cell.deviceNameLabel.text = deviceInfo.deviceName
        if deviceInfo.groupId == 0 {
            cell.roomLabel.text = kGroupNotAssigned
        } else {
            cell.roomLabel.text = "@" + deviceInfo.groupName
        }
        cell.iconImageView.image = getIconImageForModel(deviceInfo.modelName)
        cell.micButton.selected = deviceInfo.active
        
        cell.broadcasting = broadcasting
        
        if broadcasting && HKWControlHandler.sharedInstance().getDeviceInfoByIndex(indexPath.row).active {
            cell.startBroadcastingEffect()
        }
        else {
            cell.stopBroadcastingEffect()
        }
        
        if deviceInfo.isPlaying {
            cell.streamingActivity.startAnimation()
        } else {
            cell.streamingActivity.stopAnimation()
        }
        
        return cell
    }
    
    // MARK: SpeakerTableCell Delegate
    
    func speakerTableCell(speakerTableCell: SpeakerTableCell, editButtonDidPressAtIndex indexPath: NSIndexPath) {
        selectedIndex = indexPath
        selectedCell = speakerTableCell
        
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
