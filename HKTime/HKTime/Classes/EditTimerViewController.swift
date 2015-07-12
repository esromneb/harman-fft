//
//  EditTimerViewController.swift
//  HKTime
//
//  Created by TCSASSEMBLER on 12/28/14.
//  Updated by Fabrizio Lovato - fabrizyo on 02/20/2015
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit
import MediaPlayer

/**
The edit timer view controller delegate protocol

:author:  TCSASSEMBLER
:version: 1.0
:
:author:  Fabrizio Lovato - fabrizyo
:version: 1.1
*/
@objc
protocol EditTimerViewControllerDelegate {
    func editTimerViewControllerTimersDidChange(editTimerViewController: EditTimerViewController)
}

/**
The edit timer view controller responsible for adding new timer or editing an existing one

:author:  TCSASSEMBLER
:version: 1.0
:
:author:  Fabrizio Lovato - fabrizyo
:version: 1.1
*/
class EditTimerViewController: UIViewController {

    /// the table view
    @IBOutlet weak var tableView: UITableView!

    /// the delegate
    weak var delegate: EditTimerViewControllerDelegate?

    /// the timer to edit or nil for adding new one
    var timer: Timer?
    /// the timer that we edit or add
    var dirtyTimer: TmpTimer!

    /// the time editing cell
    var timeCell: TimeEditingTableViewCell!

    // Is set when user taps speakers or rooms row.
    var nextTabsState: SPEAKER_TABS_STATE!
    
    /**
    The current view controller has loaded its view. Configuring controller views
    */
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()

        timeCell = tableView.dequeueReusableCellWithIdentifier("timeCell",
            forIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as! TimeEditingTableViewCell

        if timer == nil {
            // adding a new timer
            dirtyTimer = TmpTimer()
            timeCell.minutesView.pickerView.selectRow(1, inComponent: 0, animated: false)

            title = "Add Timer"
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"), style: .Plain,
                target: self, action: Selector("dismissButtonTapped"))

        } else {
            // editing existing timer
            dirtyTimer = TmpTimer(timer!)

            title = "Edit Timer"
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back-icon"), style: .Plain,
                target: self, action: Selector("dismissButtonTapped"))

            var hoursIndex = Int(dirtyTimer.hours)
            
            timeCell.hoursView.pickerView.selectRow(hoursIndex, inComponent: 0, animated: false)
            timeCell.minutesView.pickerView.selectRow(Int(dirtyTimer.minutes), inComponent: 0, animated: false)
            timeCell.secondsView.pickerView.selectRow(Int(dirtyTimer.seconds), inComponent: 0, animated: false)

        }
    }

    /**
    prepare for segue to configure the segue destination view controller

    :param: segue the segue that contains info about view controller
    :param: sender the sender that created the segue action
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)

        if let vc = segue.destinationViewController as? SpeakerListContainerViewController {
            vc.tabsState = nextTabsState
            vc.delegate = self
            vc.timer = dirtyTimer
        }
    }

    /**
    The add button tapped action

    :param: sender the sender that initiated the action
    */
    @IBAction func addButtonTapped(sender: AnyObject) {

        
       if dirtyTimer.mediaItemPersistentID == nil {
            UIAlertView(title: nil, message: "Please select media to play",
                delegate: nil, cancelButtonTitle: "Ok").show()
            return
        }

        if dirtyTimer.getSpeakers().count == 0 {
            UIAlertView(title: nil, message: "Please select speaker to play the media",
                delegate: nil, cancelButtonTitle: "Ok").show()
            return
        }

        // set the time
        var hours = Int16(timeCell.hoursView.pickerView.selectedRowInComponent(0))

        dirtyTimer.hours = Int(hours)
        dirtyTimer.minutes = Int(timeCell.minutesView.pickerView.selectedRowInComponent(0))
        var seconds = Int(timeCell.secondsView.pickerView.selectedRowInComponent(0))
        dirtyTimer.seconds = seconds
        
        dirtyTimer.secondsRemaining = dirtyTimer.getTotalSeconds()
        
        dirtyTimer.speakerListStr = constructSpeakerListString(dirtyTimer.speakers)

        // Remove previous timer
        if timer != nil {
            AppDelegate.sharedInstance.managedObjectContext?.deleteObject(timer!)
        }
        
        // Add new timer
        let alert2save = Timer(dirtyTimer)
        
        AppDelegate.sharedInstance.saveContext()
        delegate?.editTimerViewControllerTimersDidChange(self)

        self.navigationController?.popViewControllerAnimated(true)
    }

    /**
    The dimiss button tapped action

    :param: sender the sender that initiated the action
    */
    @objc func dismissButtonTapped() {
        if AppDelegate.sharedInstance.managedObjectContext!.hasChanges {
            AppDelegate.sharedInstance.managedObjectContext!.rollback()
        }

        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension EditTimerViewController : UITableViewDataSource {

    /**
    Number of rows for the table
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timer == nil ? 4 : 5
    }

    /**
    Gets the cell for the row
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return timeCell

        } else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCellWithIdentifier("deleteCell",
                forIndexPath: indexPath) as! DeleteTableViewCell
            return cell

        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("detailsCell",
                forIndexPath: indexPath) as! DetailsTableViewCell

            if indexPath.row == 3 && timer != nil {
                cell.separatorInset = UIEdgeInsetsZero
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 17)
            }

            switch indexPath.row {
            case 1:
                cell.iconImageView.image = UIImage(named: "music-icon")

                if let item = dirtyTimer.mediaItem() {
                    cell.nameLabel.text = item.title
                } else {
                    cell.nameLabel.text = "Sound"
                }
            case 2:

                cell.iconImageView.image = UIImage(named: "volume-icon")
                let speakers = dirtyTimer.getSpeakers()
                if speakers.count == 0 {
                    cell.nameLabel.text = "Speaker"
                }
                else {
                    let deviceInfo = g_HWControlHandler.getDeviceInfoById(speakers[0])
                    if deviceInfo != nil {
                        let deviceName = deviceInfo.deviceName
                        cell.nameLabel.text = getSpeakersAsString(speakers)
                    } else {
                        cell.nameLabel.text = "No speaker available"
                    }
                }
            default:
                cell.iconImageView.image = UIImage(named: "direction-icon")
                let speakers = dirtyTimer.getSpeakers()
                if speakers.count == 0 {
                    cell.nameLabel.text = "Room"
                }
                else {
                    let deviceInfo = g_HWControlHandler.getDeviceInfoById(speakers[0])
                    cell.nameLabel.text = getRoomsAsString(speakers)
                }
        
            }

            return cell
        }
    }
}

extension EditTimerViewController : UITableViewDelegate {
    /**
    Gets the height for row
    */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return tableView.bounds.height - (44 * 3 + (timer == nil ? 25 : 77))
        } else if indexPath.row == 4 {
            return 77
        } else {
            return 44
        }
    }

    /**
    Should highlight row
    */
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row > 0
    }

    /**
    Row at index path has been selected.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        switch indexPath.row {
        case 1:
            // open the media picker
            let picker = MPMediaPickerController(mediaTypes: .AnyAudio)
            picker.delegate = self
            presentViewController(picker, animated: true, completion: nil)
        case 2:
            nextTabsState = .SPEAKERS_ONLY
            performSegueWithIdentifier("findSpeakers", sender: self)
        case 3:
            nextTabsState = .ROOMS_ONLY
            performSegueWithIdentifier("findSpeakers", sender: self)
        case 4:
            UIAlertView(title: "", message: "Are you sure you want to delete this timer?",
                delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Delete").show()
        default:
            assertionFailure("Invalid case")
        }
    }
}

extension EditTimerViewController : MPMediaPickerControllerDelegate {

    /**
    Media picker has selected a media item
    */
    func mediaPicker(mediaPicker: MPMediaPickerController!,
        didPickMediaItems mediaItemCollection: MPMediaItemCollection!) {
            dismissViewControllerAnimated(true, completion: nil)
            
            let item = mediaItemCollection.items[0] as! MPMediaItem
            let isCloudItem = item.valueForProperty(MPMediaItemPropertyIsCloudItem) as! Bool
            if isCloudItem {
                let itemTitle = item.valueForProperty(MPMediaItemPropertyTitle) as? String
                var warningMesg = ""
                if let title = itemTitle {
                    warningMesg = "'\(title)' cannot be played, because it does not exist in the device The song is only available via iTunes Match. Please choose other song."
                }
                println("mesg: \(warningMesg)")
                
                var alert = UIAlertController(title: "Notice", message: warningMesg, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
                return
            }
            
            if timer == nil {
                dirtyTimer.mediaItemPersistentID = String(item.persistentID)
            }
            else {
                dirtyTimer.mediaItemPersistentID = String(item.persistentID)
            }
            
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .None)
    }

    /**
    media picker has been cancelled
    */
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension EditTimerViewController: SpeakerListContainerViewControllerDelegate {

    func speakerListConfirmed(devices: [CLongLong]) {
        println("speakerListConfirmed")
        var ids = [CLongLong]()
        for dev in devices {
            ids.append(dev)
        }
        dirtyTimer.speakers = ids
        
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0), NSIndexPath(forRow: 3, inSection: 0)], withRowAnimation: .None)
    }
}

extension EditTimerViewController: UIAlertViewDelegate {
    /**
    The alert view button has been tapped
    */
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {

            // delete the timer
            if timer == nil {
                AppDelegate.sharedInstance.managedObjectContext?.deleteObject(Timer(dirtyTimer))
            }
            else {
                AppDelegate.sharedInstance.managedObjectContext?.deleteObject(timer!)
            }

            // save the change
            AppDelegate.sharedInstance.saveContext()

            // inform the delegate
            delegate?.editTimerViewControllerTimersDidChange(self)

            // dimiss the controller
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}
