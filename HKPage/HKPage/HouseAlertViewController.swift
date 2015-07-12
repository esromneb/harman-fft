//
//  HouseAlertViewController.swift
//  PageApp
//
//  Created by Seonman Kim on 1/15/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
* HouseAlertViewController
* Modal controller for showing house alert confirmation
*
* @version 1.0
*/
class HouseAlertViewController: UIViewController, HKWPlayerEventHandlerDelegate {
    var alertSoundFile = "Industrial Alarm-30s.mp3" // default alarm
    
    var alert : UIAlertController!
    var assetUrl : NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HKWPlayerEventHandlerSingleton.sharedInstance().delegate = self
        
        var defaults = NSUserDefaults.standardUserDefaults()
        
        var alarmSoundName = ""
        if let tempName = defaults.stringForKey("alarmSound") {
            alarmSoundName = tempName
        }
        
        alertSoundFile = SelectAlarmSoundViewController.getAlarmSoundFile(alarmSoundName)
        
        var nsWavPath = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent(alertSoundFile)
        assetUrl = NSURL(fileURLWithPath: nsWavPath)
    }
        
    /*!
    Action on "Cancel" button did press
    
    :param: sender the sender object
    */
    @IBAction func cancelButtonDidPress(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*!
    Action on "Yes" button did press
    
    :param: sender the sender object
    */
    @IBAction func yesButtonDidPress(sender: AnyObject) {

        // add all the speakers to the session (make active)
        for var i = 0; i < HKWControlHandler.sharedInstance().getDeviceCount(); i++ {
            var deviceInfo = HKWControlHandler.sharedInstance().getDeviceInfoByIndex(i)
            
            HKWControlHandler.sharedInstance().addDeviceToSession(deviceInfo.deviceId)
        }
        
        alert = UIAlertController(title: "House Alert", message: "Alert is being announced to all speakers. Please press STOP to stop House Alert.  Alert will continue for 30 seconds.", preferredStyle: .Alert)

        alert.addAction(UIAlertAction(title: "STOP", style: UIAlertActionStyle.Default, handler: { (uiAlertAction: UIAlertAction!) -> Void in
            HKWControlHandler.sharedInstance().stop()
            self.dismissViewControllerAnimated(true, completion: nil)

        }))
        self.presentViewController(alert, animated: true, completion: nil)

        
        HKWControlHandler.sharedInstance().stop()
        
        HKWControlHandler.sharedInstance().playCAF(assetUrl, songName: alertSoundFile, resumeFlag: false)
        
    }
    
    // MARK: - HKWEventHandlerDelegate
    func hkwPlayEnded() {
        println("Alarm playback ended")
        
        self.alert.dismissViewControllerAnimated(true, completion: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
