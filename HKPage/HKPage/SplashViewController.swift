//
//  SplashViewController.swift
//  PageApp
//
//  Created by Seonman Kim on 1/15/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

// Seonman: add for HKWirelessHD
//var g_HWControlHandler: HKWControlHandler!
var g_alert: UIAlertController!

/**
* SplashViewController
* Controller for splash screen
*
* @version 1.0
*/
class SplashViewController: UIViewController {
    
    /// view for circle progress percentage
    @IBOutlet weak var percentView: SplashPercentView!
    
    /// view for text percentage
    @IBOutlet weak var percentLabel: UILabel!
    
    /// timer for simulating loading
    var timer: NSTimer!
    
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        HKWControlHandler.debugPrintOn(true)
        
        
        // Set percent to 0 at first launch
        setPercent(0)
        
        // Set the timer
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "loading", userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        println("SplashViewController::viewDidAppear()")
        
        g_alert = UIAlertController(title: "Finding HK WirelessHD Network", message: "If this dialog does not disappear, please check if any other HK WirelessHD App is running on the phone and kill it. Or, your phone is not in a Wifi network.", preferredStyle: .Alert)
        
        let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
        let rootViewController = appDelegate.window!.rootViewController
        rootViewController!.presentViewController(g_alert, animated: true, completion: nil)
        
        startHKWirelessHD()

    }
    
    
    func startHKWirelessHD() {
//        if g_HWControlHandler == nil {
//            return
//        }
        
        
        if !HKWControlHandler.sharedInstance().initializing() && !HKWControlHandler.sharedInstance().isInitialized() {

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                println("initializeHKWirelessControl ...");

                if HKWControlHandler.sharedInstance().initializeHKWirelessController(kLicenseKeyGlobal) != 0 {
                    println("failed in initializeHKWirelessController: invalid license key")
                    return
                }
                
                println("initializeHKWirelessControl - OK");

                // dismiss the network initialization dialog
                if g_alert != nil && g_alert.isBeingPresented() {
                    g_alert.dismissViewControllerAnimated(true, completion: {
                        self.performSegueWithIdentifier("SplashToSpeakerListSegue", sender: self)
                    })
                }
                
//                g_HWControlHandler = HKWControlHandler.sharedInstance()
            })
        }
    }
    
    
    /*!
    Loading simulation
    */
    func loading() {

        if percentView.percent + 1 <= 100 {
            // If the percent is less than 100
            // +1 percent
            setPercent(percentView.percent+1)
            

        }
        else {
            timer.invalidate()
            //self.performSegueWithIdentifier("SplashToSpeakerListSegue", sender: self)
        }
    }
    
    /*!
    Set percentage
    */
    func setPercent(percent: Double) {
        percentView.percent = percent
        percentLabel.text = "\(Int(percentView.percent))%"
    }
}


/**
* SplashPercentView
* view for circle progress percentage for splash screen
*
* @version 1.0
*/
class SplashPercentView: UIView {
    
    /// the percent value
    var percent: Double = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func awakeFromNib() {
        self.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let context = UIGraphicsGetCurrentContext()
        
        let center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        let outerLineWidth: CGFloat = 4.0
        let innerLineWidth: CGFloat = 4.0
        let shadowWidth: CGFloat = 8.0
        let radius = self.bounds.size.width/2 - outerLineWidth/2 - shadowWidth
        
        // inner line
        UIColor(red: 23/255, green: 38/255, blue: 55/255, alpha: 1.0).setStroke()
        CGContextBeginPath(context)
        CGContextAddArc(context, center.x, center.y, radius, CGFloat(M_PI * 2.0), 0, 1)
        CGContextSetLineWidth(context, innerLineWidth)
        CGContextStrokePath(context)
        
        // outer line
        UIColor(red: 0/255, green: 172/255, blue: 235/255, alpha: 1.0).setStroke()
        CGContextBeginPath(context)
        let endAngle = M_PI * 2.0 * percent/100.0
        CGContextAddArc(context, center.x, center.y, radius, CGFloat(endAngle), 0, 1)
        CGContextSetLineWidth(context, outerLineWidth)
        
        // draw outer glow using shadow
        CGContextSetShadowWithColor(context, CGSizeMake(0,0), shadowWidth, UIColor(red: 9/255, green: 151/255, blue: 251/255, alpha: 1.0).CGColor)
        CGContextStrokePath(context)
    }
}
