//
//  SpeakerListViewController.swift
//  PageApp
//
//  Created by Seonman Kim on 1/15/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
* SpeakerListTabController
* Container for speaker list tab
*
* @version 1.0
*/


var g_speakerListTVC: SpeakerListTabViewController!

class SpeakerListTabViewController: UIViewController {
    
    /// the container
    @IBOutlet weak var containerView: UIView!
    
    /// tab buton for speaker
    @IBOutlet weak var speakerTabButton: BlueTabButton!
    
    /// tab button for room
    @IBOutlet weak var roomTabButton: BlueTabButton!
    
    /// tab button for home alert
    @IBOutlet weak var homeAlertTabButton: UIButton!
    
    /// check button for speaker tab
    @IBOutlet weak var speakerCheckButton: UIButton!
    
    /// check button for room tab
    @IBOutlet weak var roomCheckButton: UIButton!
    
    /// image view for sound wave
    @IBOutlet weak var soundwaveView: UIImageView!
    
    /// button for broadcasting
    @IBOutlet weak var broadcastingButton: UIButton!
    
    /// image view for broadcasting effect
    @IBOutlet weak var broadcastingEffect: RotatedImageView!
    
    /// timer banner when broadcasting
    @IBOutlet weak var broadcastingBanner: UIView!
    
    /// label for showing time
    @IBOutlet weak var timeLabel: UILabel!
    
    /// the time
    var time: Int = 0
    
    /// the timer
    var timer: NSTimer?
    
    /// current child shown
    var currentChildVC: UIViewController?
    
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // First selected tab
        speakerTabButton.selected = true
        showSpeakerListTab()
        
        g_speakerListTVC = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Undo all not saved changes
        AppDelegate.sharedInstance.managedObjectContext!.reset()
        
        registerBroadcastNotification()
    }
    

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopBroadcasting()
        unregisterBroadcastNotification()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue is EmptySegue {
            removeContentController(currentChildVC)
            currentChildVC = segue.destinationViewController as? UIViewController
            displayContentController(currentChildVC!)
        }
    }
    
    /*!
    Register broadcast changed notification
    */
    func registerBroadcastNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "broadcastValueChanged", name: "BroadcastChangedNotification", object: nil)
    }
    
    /*!
    Unregister broadcast changed notification
    */
    func unregisterBroadcastNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "BroadcastChangedNotification", object: nil)
    }
    
    /*!
    Notify that there are some changed in broadcast value
    */
    func broadcastValueChanged() {
        // Check all speakers
        
        // broadcastingButton should be set by inquiring the device status.
        if currentChildVC is SpeakerListViewController {
            if HKWControlHandler.sharedInstance().getActiveDeviceCount() > 0 {
                broadcastingButton.enabled = true

            } else {
                broadcastingButton.enabled = false

            }
        }
        else {
            var activeGroupCount = HKWControlHandler.sharedInstance().getActiveGroupCount()
            if activeGroupCount > 0 {
                broadcastingButton.enabled = true

            } else {
                broadcastingButton.enabled = false
            }
        }
    }
    
    
    /*!
    Show speaker list tab
    */
    func showSpeakerListTab() {
        speakerCheckButton.hidden = false
        speakerTabButton.selected = true
        self.performSegueWithIdentifier("SpeakerListSegue", sender: self)
    }
    
    /*!
    Show room list tab
    */
    func showRoomListTab() {
        roomCheckButton.hidden = false
        roomTabButton.selected = true
        self.performSegueWithIdentifier("RoomListSegue", sender: self)
    }
    
    /*!
    Unselect all buttons
    */
    func unselectAllTabButtons() {
        speakerCheckButton.hidden = true
        roomCheckButton.hidden = true
        speakerTabButton.selected = false
        roomTabButton.selected = false
    }
    
    
    // Actions
    
    /*!
    Action on "SPEAKER" tab button did press
    
    :param: sender the sender object
    */
    @IBAction func speakerTabButtonDidPress(sender: AnyObject) {
        // If current tab selected is not the speaker tab
        if !speakerTabButton.selected {
            
            // unselect all tabs
            unselectAllTabButtons()
            
            // select the speaker tab
            showSpeakerListTab()
        }
    }
    
    /*!
    Action on "ROOM" button did press
    
    :param: sender the sender object
    */
    @IBAction func roomTabButtonDidPress(sender: AnyObject) {
        // If current tab selected is not the room tab
        if !roomTabButton.selected {
            
            // unselect all tabs
            unselectAllTabButtons()
            
            // select the room tab
            showRoomListTab()
        }
    }
    
    /*!
    Action on speaker check button did press
    
    :param: sender the sender object
    */
    @IBAction func speakerCheckButtonDidPress(sender: AnyObject) {
        speakerCheckButton.selected = !speakerCheckButton.selected
        var speakerController = currentChildVC as! SpeakerListViewController
        speakerController.setBroadcastAll(speakerCheckButton.selected)
        NSNotificationCenter.defaultCenter().postNotificationName("BroadcastChangedNotification", object: nil)
    }
    
    /*!
    Action on room check button did press
    
    :param: sender the sender object
    */
    @IBAction func roomCheckButtonDidPress(sender: AnyObject) {
        roomCheckButton.selected = !roomCheckButton.selected
        var roomController = currentChildVC as! RoomListViewController
        roomController.setBroadcastAll(roomCheckButton.selected)
        NSNotificationCenter.defaultCenter().postNotificationName("BroadcastChangedNotification", object: nil)
    }
    
    /*!
    Action on broadcasting button did press
    
    :param: sender the sender object
    */
    @IBAction func broadcastingButtonDidPress(sender: AnyObject) {
        broadcastingButton.selected = !broadcastingButton.selected
        
        if broadcastingButton.selected {
            startBroadcasting()
        }
        else {
            stopBroadcasting()
        }
    }
    
    /*!
    Start broadcasting
    */
    func startBroadcasting() {

        broadcastingButton.selected = true
        
        // Show banner for time
        broadcastingBanner.hidden = false
        broadcastingEffect.hidden = false
        
        // Show soundwave
        soundwaveView.hidden = false
        
        // Show effect
        broadcastingEffect.runAnimation()
        
        // Remove right bar button
        self.speakerListContainerViewController?.removeRightBarButton()
        
        // Notify current child
        childStartBroadcasting()
        
        // Start timer
        startTimer()
    }
    
    /*!
    Stop broadcasting
    */
    func stopBroadcasting() {
        
        broadcastingButton.selected = false
        
        // Hide banner for time
        broadcastingBanner.hidden = true
        broadcastingEffect.hidden = true
        
        // Hide soundwave
        soundwaveView.hidden = true
        
        // Stop effect
        broadcastingEffect.stopAnimation()
        
        // Add right bar button
        self.speakerListContainerViewController?.addRightBarButton()
        
        // Notify current child
        childStopBroadcasting()
        
        // Stop timer
        stopTimer()
    }
    
    /*!
    Start broadcasting timer
    */
    func startTimer() {
        time = 0
        setTimeLabel()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "timing", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    }
    
    /*!
    Stop broadcasting timer
    */
    func stopTimer() {
        time = 0
        timer?.invalidate()
        setTimeLabel()
    }
    
    /*!
    Set timer label when broadcasting
    */
    func setTimeLabel() {
        var minutes = time/6000
        var seconds = (time % 6000)/100
        var miseconds = (time % 6000) % 100
        var str = String(format: "%02d:%02d:%02d", minutes, seconds, miseconds)
        timeLabel.text = str
    }
    
    /*!
    Timing function
    */
    func timing() {
        time += 1
        setTimeLabel()
    }
    
    /*!
    Notify current child that the broadcasting is begun
    */
    func childStartBroadcasting() {
        if currentChildVC is SpeakerListViewController {
            var speakerController = currentChildVC as! SpeakerListViewController
            speakerController.startBroadcasting()
        }
        else {
            var roomController = currentChildVC as! RoomListViewController
            roomController.startBroadcasting()
        }
    }
    
    /*!
    Notify current child that the broadcasting is stopped
    */
    func childStopBroadcasting() {
        if currentChildVC is SpeakerListViewController {
            var speakerController = currentChildVC as! SpeakerListViewController
            speakerController.stopBroadcasting()
        }
        else {
            var roomController = currentChildVC as! RoomListViewController
            roomController.stopBroadcasting()
        }
    }
    
    
    // MARK: Manage Child Controllers
    
    func displayContentController(content: UIViewController) {
        self.addChildViewController(content)
        self.containerView.addSubview(content.view)
        content.view.frame.size = self.containerView.frame.size
        content.didMoveToParentViewController(self)
    }
    
    func removeContentController(content: UIViewController?) {
        if let content = content {
            content.willMoveToParentViewController(nil)
            content.view.removeFromSuperview()
            content.removeFromParentViewController()
        }
    }
}
