//
//  MainVC.swift
//  HWSimplePlayer
//
//  Created by Seonman Kim on 12/31/14.
//  Copyright (c) 2014 Harman International. All rights reserved.
//

import UIKit



class MainVC: UIViewController {
    var g_alert: UIAlertController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !HKWControlHandler.sharedInstance().isInitialized() {
            // show the network initialization dialog
            println("show dialog")
            g_alert = UIAlertController(title: "Initializing", message: "If this dialog does not disappear, please check if any other HK WirelessHD App is running on the phone and kill it. Or, your phone is not in a Wifi network.", preferredStyle: .Alert)
            
            self.presentViewController(g_alert, animated: true, completion: nil)
        }

    }

    override func viewDidAppear(animated: Bool) {
        
        if !HKWControlHandler.sharedInstance().initializing() && !HKWControlHandler.sharedInstance().isInitialized() {
            println("initializing in PlaylistTVC")
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                if HKWControlHandler.sharedInstance().initializeHKWirelessController(kLicenseKeyGlobal) != 0 {
                    println("initializeHKWirelessControl failed : invalid license key")
                    return
                }
                println("initializeHKWirelessControl - OK");
                
                // dismiss the network initialization dialog
                if self.g_alert != nil {
                    self.g_alert.dismissViewControllerAnimated(true, completion: nil)
                }
                
            })
        }
    }
}
