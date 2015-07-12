//
//  MenuViewController.swift
//  HKTime
//
//  Created by Seonman Kim on 2/1/2015.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
* MenuViewController
* Controller for managing menu
*
* @version 1.0
*/
class MenuViewController: UIViewController {
    
    /// image view for profile image
    @IBOutlet weak var profileImageView: UIImageView!
    
    /// label for username
    @IBOutlet weak var usernameLabel: UILabel!
    
    var g_aboutDidShow = false

    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Rounding the profile image
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2.0
    }
    
    override func viewDidAppear(animated: Bool) {
        if g_aboutDidShow {
            self.menuContainerViewController?.showAlerts()
            
            g_aboutDidShow = false
        }
    }
    
    
    /*!
    Action on "Speakers" button did press
    
    :param: sender the sender object
    */
    @IBAction func speakersButtonDidPress(sender: AnyObject) {
        self.menuContainerViewController?.showSpeakerListController()
    }

    @IBAction func alertsButtonAction(sender: AnyObject) {
        self.menuContainerViewController?.showAlerts()
    }
    
    /*!
    Action on "Settings" button did press
    
    :param: sender the sender object
    */
    @IBAction func settingsButtonDidpress(sender: AnyObject) {
        var alert = UIAlertView(title: "", message: "Settings!", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
        self.menuContainerViewController?.closeMenu(true)
    }
    
    @IBAction func gotoHKControllerApp(sender: AnyObject) {
        
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: kHKControllerAppURL)!) {
            if UIApplication.sharedApplication().openURL(NSURL(string: kHKControllerAppURL)!) {
                println("Successfully launched HK Controller App")
                exit(0)
                
            } else {
                var alert = UIAlertController(title: "Error", message: "Could not launch the app", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        else {
            println("Cannot open HKController app")
            var alert = UIAlertController(title: "Alert", message: "HK Controller app was not found on the phone. Do you want to go to App Store and install  HK Controller app now?", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "YES", style: UIAlertActionStyle.Default, handler: {(paramAction: UIAlertAction!) in
                
                UIApplication.sharedApplication().openURL(NSURL(string: kHKControllerAppStoreURL)!)
            }))
            
            alert.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    /*!
    Action on "Harman Website" button did press
    
    :param: sender the sender object
    */
    @IBAction func harmanWebsiteButtonDidPress(sender: AnyObject) {
        
        self.performSegueWithIdentifier("AboutSegue", sender: self)
        
        g_aboutDidShow = true
    }
    
}
