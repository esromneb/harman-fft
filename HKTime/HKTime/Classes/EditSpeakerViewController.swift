//
//  EditSpeakerViewController.swift
//  HKTime
//
//  Created by Seonman Kim on 2/1/2015.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit
import CoreData
import CoreImage


var g_wifiQuerying = false


/**
* EditSpeakerViewController
* Controller for managing the edit speaker page
*
* @version 1.0
*/
class EditSpeakerViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, HKWDeviceEventHandlerDelegate {
    
    /// the scroll view
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet var deviceNameTF: UITextField!
    
    /// image view for icon
    @IBOutlet weak var iconImageView: UIImageView!
    
    /// label for model
    @IBOutlet weak var modelLabel: UILabel!
    
    /// label for zone
    @IBOutlet weak var zoneLabel: UILabel!
    
    /// label for room
    @IBOutlet weak var roomLabel: UILabel!
    
    
    @IBOutlet weak var volumeLabel: UILabel!
    
    @IBOutlet weak var volumeSlider: UISlider!
    
    /// the textView
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet var wifiImageView: UIImageView!
    @IBOutlet var wifiValueLabel: UILabel!
    
    @IBOutlet var firmwareVersionLabel: UILabel!
    
    var deviceInfo: DeviceInfo!
    var speakerCell: SpeakerTableCell!
    
    var streamingActivity: StreamingActivityView!


    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSlider()
        
        // Setup navigation items
        self.setupNavigationItems()
        
        deviceNameTF.text = deviceInfo.deviceName
        modelLabel.text = deviceInfo.modelName
        firmwareVersionLabel.text = "v\(deviceInfo.version)"
        
        if deviceInfo.groupId == 0 {
            roomLabel.text = kGroupNotAssigned
        } else {
            roomLabel.text = deviceInfo.groupName
            
        }
        iconImageView.image = getIconImageForModel(deviceInfo.modelName)
        zoneLabel.text = deviceInfo.ipAddress
        volumeLabel.text = "\(deviceInfo.volume)"
        volumeSlider.value = Float(deviceInfo.volume)
        
        wifiImageView.image = getWifiImage(deviceInfo.wifiSignalStrength)
        wifiValueLabel.text = "\(deviceInfo.wifiSignalStrength)dBm"
        
        streamingActivity = StreamingActivityView()
        var rect = CGRect(x: 20, y: 36, width: 32, height: 20) // y: 100 for Page app
        streamingActivity.frame = rect
        view.addSubview(streamingActivity)
        if deviceInfo.isPlaying {
            streamingActivity.startAnimation()
        } else {
            streamingActivity.stopAnimation()
        }
        
        textView.text = ""
        
        deviceNameTF.delegate = self
        deviceNameTF.returnKeyType = UIReturnKeyType.Done
        
        loadNoteInfo()
    }
    
    override func viewDidAppear(animated: Bool) {
        HKWDeviceEventHandlerSingleton.sharedInstance().delegate = self
        
        g_wifiQuerying = true
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            while (g_wifiQuerying) {
                sleep(3)
                g_HWControlHandler.refreshDeviceWiFiSignal(self.deviceInfo.deviceId)
                
                if (!g_wifiQuerying) {
                    break;
                }
            }
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        g_wifiQuerying = false
        
        if streamingActivity != nil {
            streamingActivity.stopAnimation()
        }
    }
    
    func getWifiImage(value: Int) -> UIImage
    {
        var image : UIImage!
        
        if value < -90 {
            image = UIImage(named: "ic_signal_wifi_0_bar_black_48dp")!
        } else if value < -70 {
            image = UIImage(named: "ic_signal_wifi_1_bar_black_48dp")!
        } else if value < -50 {
            image = UIImage(named: "ic_signal_wifi_2_bar_black_48dp")!
        } else if value < -30 {
            image = UIImage(named: "ic_signal_wifi_3_bar_black_48dp")!
        }
        else {
            image = UIImage(named: "ic_signal_wifi_4_bar_black_48dp")!
        }
        
        return inverseColor(image)
    }
    
    func inverseColor(image: UIImage) -> UIImage {
        var coreImage: CIImage = CIImage(CGImage: image.CGImage)
        var filter: CIFilter = CIFilter(name: "CIColorInvert")
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        var result: CIImage = filter.valueForKey(kCIOutputImageKey) as! CIImage
        return UIImage(CIImage: result)!
    }
    
    func loadNoteInfo() {
        var appDel: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        var context: NSManagedObjectContext = appDel.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "Note")
        request.returnsObjectsAsFaults = false
        
        var deviceIdStr = String(format: "%lld", deviceInfo.deviceId)
        request.predicate = NSPredicate(format: "deviceid = %@", deviceIdStr)
        
        var results: NSArray = context.executeFetchRequest(request, error: nil)!
        
        if(results.count > 0) {
            var res = results[0] as! NSManagedObject
            var noteStr = res.valueForKey("note") as! String
            println("noteStr: \(noteStr)")
            
            textView.text = noteStr
            
            
        } else {
            println("0 Results Returned .. potential error")
        }
    }
    
    func saveNoteInfo() {
        var appDel: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        var context: NSManagedObjectContext = appDel.managedObjectContext!
        
        var request = NSFetchRequest(entityName: "Note")
        request.returnsObjectsAsFaults = false
        
        var deviceIdStr = String(format: "%lld", deviceInfo.deviceId)
        request.predicate = NSPredicate(format: "deviceid = %@", deviceIdStr)
        
        var results: NSArray = context.executeFetchRequest(request, error: nil)!
        
        if(results.count > 0) {
            var res = results[0] as! NSManagedObject
            res.setValue(textView.text, forKey: "note")
            
        } else {
            var newUser = NSEntityDescription.insertNewObjectForEntityForName("Note", inManagedObjectContext: context) as! NSManagedObject
            newUser.setValue(deviceIdStr, forKey: "deviceid")
            newUser.setValue(textView.text, forKey: "note")
            println(newUser)
            
        }
        context.save(nil)
        
        println("Object Saved.")
    }
    
    
    
    /*!
    Setup slider using custom image
    */
    func setupSlider() {
        volumeSlider.setMinimumTrackImage(UIImage(named: "slider_min"), forState: UIControlState.Normal)
        volumeSlider.setMaximumTrackImage(UIImage(named: "slider_max"), forState: UIControlState.Normal)
        volumeSlider.setThumbImage(UIImage(named: "slider_thumb"), forState: UIControlState.Normal)
        volumeSlider.addTarget(self, action: "sliderValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    /*!
    Slider value changed Action
    
    :param: sender the sender object
    */
    func sliderValueChanged(sender: AnyObject) {
        var value = volumeSlider.value
        volumeLabel.text = "\(Int(value))"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Speaker Info"

        
        // Register keyboard notifications
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        // Unregister keyboard notifications
        unregisterForKeyboardNotifications()
    }    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            
            if identifier == "SelectRoomSegue" {
                println("goes to SelectRoomSegue")
                var controller = segue.destinationViewController as! SelectRoomViewController
                
                // Select Speaker
                controller.title = "Room Selection"
                controller.deviceInfo = deviceInfo
                controller.roomName = deviceInfo.groupName
                controller.editSpeakerVC = self
            }
        }
    }
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unregisterForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /*!
    Setup navigation items for this page
    */
    func setupNavigationItems() {
        self.title = "Edit Speaker"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: "saveButtonDidPress:")
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 7/255, green: 158/255, blue: 217/255, alpha: 1.0)
        self.navigationController?.navigationBar.topItem?.title = " "
    }
    
    /*!
    Action on "Save" button did press
    
    :param: sender the sender object
    */
    func saveButtonDidPress(sender: AnyObject) {
        g_HWControlHandler.setDeviceName(deviceInfo.deviceId, deviceName:deviceNameTF.text);
        
        // save Note
        saveNoteInfo()
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    /*!
    Action on room cell did press
    
    :param: sender the sender object
    */
    @IBAction func roomDidPress(sender: AnyObject) {
        self.performSegueWithIdentifier("SelectRoomSegue", sender: self)
    }
    
    
    @IBAction func volumeChanged(sender: AnyObject) {
        println("slideVolumeChanged: \(volumeSlider.value)")
        g_HWControlHandler.setVolumeDevice(deviceInfo.deviceId, volume:NSInteger(volumeSlider.value))
        volumeLabel.text = "\(Int(volumeSlider.value))"
    }
    
    // MARK: Keyboard notification
    
    func keyboardWasShown(notification: NSNotification) {
        
        // Set the scrollView inset when the keyboard was shown
        
        let info = notification.userInfo!
        
        if !deviceNameTF.editing {
            
            // Get keyboard size
            if let kbRectValue = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                var kbRect = kbRectValue
                kbRect = self.view.convertRect(kbRect, fromView: nil)
                
                println("kbRect.eize.height: \(kbRect.size.height)")
                
                // Calculate the inset value
                let contentInsets = UIEdgeInsets(top: self.scrollView.contentInset.top, left: 0, bottom: kbRect.size.height, right: 0)
                self.scrollView.contentInset = contentInsets
                self.scrollView.scrollIndicatorInsets = contentInsets
                
                // Scroll the scrollView to the selected field
                var visRect =  self.textView.superview!.frame
                visRect.size.height = 70
                self.scrollView.scrollRectToVisible(visRect, animated: true)
            }
        }
        
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: self.scrollView.contentInset.top, left: 0, bottom: 0, right: 0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    // UITextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        println("textFieldShouldReturn")
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - HKWEventHandlerDelegate
    func hkwDeviceStateUpdated(deviceId: CLongLong, withReason reason: Int) {
        println("new WiF Signal length: \(self.deviceInfo.wifiSignalStrength)")
        self.wifiImageView.image = self.getWifiImage(self.deviceInfo.wifiSignalStrength)
        self.wifiValueLabel.text = "\(self.deviceInfo.wifiSignalStrength)dBm"
        
        if self.deviceInfo.isPlaying {
            self.streamingActivity.startAnimation()
        } else {
            self.streamingActivity.stopAnimation()
        }
    }
    
    
    func hkwErrorOccurred(errorCode: Int, withErrorMessage errorMesg: String!) {
        var errorString = "Error(\(errorCode)): " + errorMesg
        var alert = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "STOP", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
