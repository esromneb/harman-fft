//
//  SpeakerListViewController.swift
//  Wake
//
//  Created by Seonman Kim on 2/1/2015.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

enum SPEAKER_TABS_STATE {
    case BOTH, SPEAKERS_ONLY, ROOMS_ONLY
}

/**
* SpeakerListTabController
* Container for speaker list tab
*
* @version 1.0
*/
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
    
//    /// the time
//    var time: Int = 0
//    
//    /// the timer
//    var timer: NSTimer?
    
    /// current child shown
    var currentChildVC: UIViewController?
    
    // Changes the avalability of tabs buttons
    var state: SPEAKER_TABS_STATE = SPEAKER_TABS_STATE.BOTH
    var timer: TmpTimer?
    var delegate: SpeakerListContainerViewControllerDelegate?
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeAlertTabButton.hidden = true
        if state == .SPEAKERS_ONLY {
            // First selected tab
            speakerTabButton.selected = true
            showSpeakerListTab()
            // Disable tab 2
            roomTabButton.enabled = false
        }
        else if state == .ROOMS_ONLY {
            // First selected tab
            roomTabButton.selected = true
            showRoomListTab()
            // Disable tab 1
            speakerTabButton.enabled = false
        }
        else { // Both tabs enabled
            // First selected tab
            speakerTabButton.selected = true
            showSpeakerListTab()
            broadcastingButton.hidden = true
        }
        
        // house alert
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "houseAlertSelected", name: "HouseAlertSelectedNotification", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().postNotificationName("BroadcastChangedNotification", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Undo all not saved changes
        AppDelegate.sharedInstance.managedObjectContext!.rollback()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue is EmptySegue {
            removeContentController(currentChildVC)
            currentChildVC = segue.destinationViewController as? UIViewController
            if let vc = currentChildVC as? SpeakerListViewController {
                vc.timer = timer
            }
            else if let vc = currentChildVC as? RoomListViewController {
                vc.timer = timer
            }
            displayContentController(currentChildVC!)
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
        
        if state == .BOTH {
            if broadcastingButton.selected {
            }
            else {
            }
        }
        else if state == .SPEAKERS_ONLY {
            println("Speaker selection done")
            if let vc = currentChildVC as? SpeakerListViewController {
                // Create list of selected speakers
                var list = vc.getSelectedSpeakers()
                delegate?.speakerListConfirmed(list)
            }
            // Dismiss this window
            self.navigationController?.popViewControllerAnimated(true)
        }
        else if state == .ROOMS_ONLY {
            println("Room selection done")
            if let vc = currentChildVC as? RoomListViewController {
                // Create list of selected speakers
                var list = vc.getSelectedSpeakers()
                delegate?.speakerListConfirmed(list)
            }
            // Dismiss this window
            self.navigationController?.popViewControllerAnimated(true)
        }

    }
    
//    
//    /*!
//    Start broadcasting timer
//    */
//    func startTimer() {
//        time = 0
//        setTimeLabel()
//        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "timing", userInfo: nil, repeats: true)
//        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
//    }
//    
//    /*!
//    Stop broadcasting timer
//    */
//    func stopTimer() {
//        time = 0
//        timer?.invalidate()
//        setTimeLabel()
//    }
//    
//    /*!
//    Set timer label when broadcasting
//    */
//    func setTimeLabel() {
//        var minutes = time/6000
//        var seconds = (time % 6000)/100
//        var miseconds = (time % 6000) % 100
//        var str = String(format: "%02d:%02d:%02d", minutes, seconds, miseconds)
//        timeLabel.text = str
//    }
//    
//    /*!
//    Timing function
//    */
//    func timing() {
//        time += 1
//        setTimeLabel()
//    }
//    
    
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
