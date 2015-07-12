//
//  HomeViewController.swift
//  HKTime
//
//  Created by TCSASSEMBLER on 12/27/14.
//  Updated by Fabrizio Lovato - fabrizyo on 02/20/2015
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/// the list of timers
var g_timers: [Timer]!

/**
The home view controller responsible for managing current timers and
timers list events, besides the swiping to show/hide the timers list

:author:  TCSASSEMBLER
:version: 1.0
:
:author:  Fabrizio Lovato - fabrizyo
:version: 1.1
*/

//return the time text value of timer
func getTimeString(time:NSTimeInterval) -> String {
    return pad(String(Int(time)/3600))+":"+pad(String(Int(time)%3600/60))+":"+pad(String(Int(time)%60))
}

//pad the string to max 2 length
func pad(s:String) -> String {
    if count(s)==1 {
        return "0" + s
    }
    return s
}

@objc
protocol TimersListViewControllerDelegate {
    func timersListViewController(timersListViewController: HomeViewController, startEditTimer timer: Timer)
}

class HomeViewController: UIViewController {
    
    
    
    /// the table view
    @IBOutlet weak var tableView: UITableView!
    
    /// the delegate
    weak var delegate: TimersListViewControllerDelegate?
    

    

    /// struct for static values
    private struct StaticValues {
        /// the minimum height constant for the height constraint
        static let minimumHeightConstant: CGFloat = 108
    }

    /// the height constraint
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    /// the menu image view that will be swiped up/down
    @IBOutlet weak var menuImageView: PressableImageView!
    /// the timers list container view
    @IBOutlet weak var timersContainerView: UIView!


    /// whether or not the current timer is collapsed with the timers list
    var collapsed: Bool = false {
        didSet {
            if collapsed {
                heightConstraint.constant = StaticValues.minimumHeightConstant + timersContainerView.bounds.height
            } else {
                heightConstraint.constant = StaticValues.minimumHeightConstant
            }
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0,
                options: UIViewAnimationOptions(0), animations: { () -> Void in
                    self.view.layoutIfNeeded()
                }, completion: nil)
        }
    }

    /// the editing timer
    var editingTimer: Timer?

    /**
    The current view controller has loaded its view. Configuring controller views
    */
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.shadowImage = UIColor.appIdentityColor().createImageWithSize(CGSize(width: 1, height: 1))
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        
        self.delegate=self;
        
        reload()
        
        tableView.tableFooterView = UIView()
        tableView.allowsMultipleSelectionDuringEditing = false

    }
    
    /**
    Reload view data
    */
    func reload() {
        // get the model
        g_timers = CoreDataHandler.defaultCoreDataHandler().fetchTimers()
        
        tableView.reloadData()
    }

    /**
    prepare for segue to configure the segue destination view controller

    :param: segue the segue that contains info about view controller
    :param: sender the sender that created the segue action
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)

        if let editingVC = segue.destinationViewController as? EditTimerViewController {
            editingVC.delegate = self
            editingVC.timer = editingTimer
        }
    }

    /**
    The add button tapped action

    :param: sender the sender that initiated the action
    */
    @IBAction func addButtonTapped(sender: AnyObject) {
        editingTimer = nil
        performSegueWithIdentifier("showEditing", sender: nil)
    }

    /**
    The settings button tapped action

    :param: sender the sender that initiated the action
    */
    @IBAction func settingsTapped(sender: AnyObject) {
        self.menuContainerViewController?.toggleMenu(true)
    }

    /**
    The menu button tapped action

    :param: sender the sender that initiated the action
    */
    @IBAction func menuTapped(sender: AnyObject) {

        collapsed = !collapsed
    }

    /**
    menu image panned
    
    param: sender the pan gesture
    */
    @IBAction func menuPanned(sender: UIPanGestureRecognizer) {

        switch sender.state {
        case .Began:
            menuImageView.press()

        case .Changed:
            let startPoint = StaticValues.minimumHeightConstant + (collapsed ? timersContainerView.bounds.height: 0)

            let translation = sender.translationInView(sender.view!).y
            var current = startPoint - translation

            if current < StaticValues.minimumHeightConstant {
                current = StaticValues.minimumHeightConstant
            } else if current > StaticValues.minimumHeightConstant + timersContainerView.bounds.height {
                current = StaticValues.minimumHeightConstant + timersContainerView.bounds.height
            }

            heightConstraint.constant = current

        case .Ended, .Failed, .Cancelled:
            menuImageView.releasePressing()

            let velocity = sender.velocityInView(sender.view).y
            if abs(velocity) > 500 {
                if (collapsed && velocity > 0) ||
                   (!collapsed && velocity < 0) {
                    collapsed = !collapsed
                } else {
                    collapsed = collapsed ? true : false
                }
            } else {
                let translation = sender.translationInView(sender.view!).y
                collapsed = abs(translation) > timersContainerView.bounds.height / 2 ? !collapsed: collapsed
            }

        case .Possible:
            println("switch state is possible")
        }
    }

    /**
    The menu swiped up action

    :param: sender the sender that initiated the action
    */
    @IBAction func menuSwipedUp(sender: UISwipeGestureRecognizer) {
        if !collapsed {
            collapsed = true
        }
    }

    /**
    The menu swiped down action

    :param: sender the sender that initiated the action
    */
    @IBAction func menuSwipedDown(sender: UISwipeGestureRecognizer) {
        if collapsed {
            collapsed = false
        }
    }
}

extension HomeViewController: TimersListViewControllerDelegate {
    /**
    start editing timer
    */
    func timersListViewController(timersListViewController: HomeViewController, startEditTimer timer: Timer) {
        editingTimer = timer
        performSegueWithIdentifier("showEditing", sender: nil)
    }

   
}

extension HomeViewController: EditTimerViewControllerDelegate {
    /**
    timer data changed
    */
    func editTimerViewControllerTimersDidChange(editTimerViewController: EditTimerViewController) {
        // reload the data
        reload()
    }
}



extension HomeViewController: UITableViewDataSource {
    
    /**
    gets number of rows for the table view
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return g_timers.count
    }
    
    /**
    Gets the cell for the row
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TimerTableViewCell
        cell.delegate = self
        cell.topLine.hidden = indexPath.row != 0
        cell.setAlternate(indexPath.row % 2 == 0)
        
        let timer = g_timers[indexPath.row]
        cell.switchControl.setIsOn(timer.isActive, animated: false)
        
        let speaker = getSpeakersAsString(timer.speakers)
        let room = getRoomsAsString(timer.speakers)
        
        if speaker == "" {
            cell.speakerDetailsLabel.text = "No speaker available"
            
        } else {
            //            cell.speakerDetailsLabel.text = "\(speaker) in \(room)"
            let mediaTitle = timer.mediaItem()?.title ?? "Unkown music"

            cell.speakerDetailsLabel.text = "'\(mediaTitle)' on " + getSpeakersInfo(timer.speakers)
        }
        
        
        cell.timer = timer
        cell.resetButton.accessibilityElements = [cell]
        cell.resetButton.addTarget(self, action: Selector("resetTimer:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.resetButton.enabled = timer.secondsRemaining != timer.getTotalSeconds()
        
//        if timer.getTotalSeconds() == timer.secondsRemaining {
//            cell.resetButton.enabled = false
//        } else {
//            
//        }
        
//        var time = cell.timer!.secondsRemaining
        cell.timeLabel.text = getTimeString(cell.timer!.secondsRemaining)
        if timer.secondsRemaining == timer.getTotalSeconds() {
            cell.timeLabel.textColor = UIColor.whiteColor()
        } else if !cell.timer!.isActive {
            cell.timeLabel.textColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        } else {
            cell.timeLabel.textColor = UIColor.greenColor()
        }
        
        //[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]

        
//        timer.secondsRemaining = time
        
        timer.cell = cell
        


        
        return cell
    }
    
    //reset the timer
    func resetTimer(sender:UIButton) {
        var cell=sender.accessibilityElements[0] as! TimerTableViewCell
        cell.timer!.reset()
        
        //save context
        AppDelegate.sharedInstance.saveContext()
        reload()
    }
    
    
//    //update the time text value of timer and invalidate timers not used
//    func updateTime(timer: NSTimer) {
//        var present = false
//        var cell = timer.userInfo as TimerTableViewCell
//        if (cell.timer != nil) {
//            var time = cell.timer!.secondsRemaining
//            cell.timeLabel.text = getTimeString(time)
//            
//            if time == 0 {
//                println("time: 0 --> stop timer")
//                cell.timer?.isActive = false
//            }
//        } else {
//            timer.invalidate()
//        }
//    }
    

    
    //necessary for timer delete
    func tableView(tableView: UITableView,canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
     //necessary for timer delete
    func tableView(tableView: UITableView,commitEditingStyle editingStyle: UITableViewCellEditingStyle,forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            //delete timer
            AppDelegate.sharedInstance.managedObjectContext?.deleteObject(g_timers[indexPath.row])
            
            // save the change
            AppDelegate.sharedInstance.saveContext()
            reload()
        }
    }
}


extension HomeViewController: UITableViewDelegate {
    
    /**
    cell ahs been selected
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        delegate?.timersListViewController(self, startEditTimer: g_timers[indexPath.row])
    }
    
}


extension HomeViewController: TimerTableViewCellDelegate {
    /**
    timer cell active state changed: stop or start the timer
    */
    func timerTableViewCell(timerTableViewCell: TimerTableViewCell, isActiveChangedTo isActive: Bool) {
        
        let indexPath = tableView.indexPathForCell(timerTableViewCell)!
        let timer = g_timers[indexPath.row]
        if timer.isActive != isActive {
            println("isActive: \(isActive)")
            if timer.isActive {
                println("timer.stop()")
                timer.stop()
            } else {
                println("timer.start()")
                timer.start()
                
                scheduleTimer(timer)
            }
            AppDelegate.sharedInstance.saveContext()
            reload()
        }
    }
    
    func scheduleTimer(timer: Timer) {
        let timeInterval = timer.secondsRemaining
        println("timeInterval: \(timeInterval)")
        
        scheduleTimerLocalNotification(timer, timeInterval: timeInterval)
        
        if let songTitle = timer.mediaItem()?.title {
            println("scheduleTimer for \(timeInterval) : song: \(songTitle)")
        }
    }

    
    func scheduleTimerLocalNotification(timer: Timer, timeInterval: NSTimeInterval) {
        
        timer.localNotification = UILocalNotification()
        
        /* Time and timezone settings */
        timer.localNotification.fireDate = NSDate(timeIntervalSinceNow: timeInterval)
        timer.localNotification.timeZone = NSCalendar.currentCalendar().timeZone
        
        timer.localNotification.alertBody = "HK Time! Please open the HKTime app to stop playing music."
        
        /* Action settings */
        timer.localNotification.hasAction = true
        timer.localNotification.alertAction = "View"
        
        
        /* Additional information, user info */
        timer.localNotification.userInfo = [
            "Key 1" : "Value 1",
            "Key 2" : "Value 2"
        ]
        
        /* Schedule the notification */
        UIApplication.sharedApplication().scheduleLocalNotification(timer.localNotification)
    }

}

