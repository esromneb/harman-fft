//
//  MenuViewController.swift
//  HKTime
//
//  Created by TCSCODER on 12/19/14.
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

let kTimerFiredNotification = "TimerFiredNotification"

//var g_menuContainerVC : MenuContainerViewController!

extension UIViewController {
    var menuContainerViewController: MenuContainerViewController? {
        var parent: UIViewController? = self
        
        // Iterate the parent until it found the MenuContainerViewController or it has no parent anymore
        while (parent != nil) && !(parent is MenuContainerViewController) {
            parent = parent!.parentViewController
        }
        return parent as! MenuContainerViewController?
    }
}

/**
* MenuContainerViewController
* Main container to encapsulate Menu and Main views
*
* @author TCSCODER
* @version 1.0
*/
class MenuContainerViewController: UIViewController, HKWPlayerEventHandlerDelegate {
    
    let mainViewControllerSegueId = "SetMainViewToAlerts"
    let speakersListSegueId = "showSpeakersList"
    
    /// the main view
    @IBOutlet weak var mainView: UIView!
    
    /// current child controller
    var currentChildVC: UIViewController?
    
    /// is the menu opened?
    var open: Bool = false
    
    /// overlay close button
    var overlayCloseButton: UIButton!
    
    var alert : UIAlertController!

    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTimerFired:", name: kTimerFiredNotification, object: nil)

        
        setupMainView()
        showAlerts()
        
    }
    
    /*!
    Setup main view constraint
    */
    func setupMainView() {
        self.mainView.frame = self.view.bounds
        self.mainView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        self.mainView.setTranslatesAutoresizingMaskIntoConstraints(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue is EmptySegue {
            if let identifier = segue.identifier {
//                if identifier == mainViewControllerSegueId {
                    removeContentController(currentChildVC)
                    currentChildVC = segue.destinationViewController as? UIViewController
                    displayContentController(currentChildVC!)
//                }
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    /*!
    Show speaker list controller
    */
    func showSpeakerListController() {
        self.closeMenu(true)
        self.performSegueWithIdentifier(speakersListSegueId, sender: self)
    }
    
    func showAlerts() {
        self.closeMenu(true)
        self.performSegueWithIdentifier(mainViewControllerSegueId, sender: self)
    }
    
    /*!
    Creating transformation for opening menu effect
    
    :param: view the view that is needed to open
    :return: the affine transform for opening menu effect
    */
    func openTransformForView(view: UIView) -> CGAffineTransform {
        var transformSize: CGFloat = 0.75;
        var newTransform = CGAffineTransformTranslate(view.transform, CGRectGetMidX(view.bounds) + 50, 0);
        return CGAffineTransformScale(newTransform, transformSize, transformSize);
    }
    
    /*!
    Open the menu
    
    :param: animated should the opening use animation
    */
    func openMenu(animated: Bool) {
        
        // If it's already opened, do nothing
        if self.open {
            return
        }
        
        // Set open
        self.open = true
        
        // Create the closure for opening the menu
        var openMenuClosure = {() -> () in
            self.mainView.transform = self.openTransformForView(self.mainView)
        }
        
        // When animation is completed, add overlay close button
        var completedClosure = {(finished: Bool) -> () in
            self.addOverlayCloseButton()
        }
        
        if animated {
            // Animate the opening
            UIView.animateWithDuration(NSTimeInterval(0.2), delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
                animations: {
                    openMenuClosure()
                }, completion: completedClosure)
        }
        else {
            openMenuClosure()
            completedClosure(true)
        }
    }
    
    /*!
    Close the menu
    
    :param: animated should the closing use animation
    */
    func closeMenu(animated: Bool) {
        // If it's already closed, do nothing
        if !self.open {
            return
        }
        
        // Set open
        self.open = false
        
        // Create the closure for closing the menu
        var closeMenuClosure = {() -> () in
            self.mainView.transform = CGAffineTransformIdentity
        }
        
        // Remove overlay button
        self.removeOverlayCloseButton()
        
        if animated {
            // Animate the closing
            UIView.animateWithDuration(NSTimeInterval(0.2), delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
                animations: {
                    closeMenuClosure()
                }, completion: nil)
        }
        else {
            closeMenuClosure()
        }
    }
    
    /*!
    Toggle the menu
    
    :param: animated should the toggling use animation
    */
    func toggleMenu(animated: Bool) {
        if self.open {
            closeMenu(animated)
        }
        else {
            openMenu(animated)
        }
    }
    
    // Overlay button
    
    /*!
    Add overlay close button for closing the menu
    */
    func addOverlayCloseButton() {
        var button = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        button.backgroundColor = UIColor.clearColor()
        button.opaque = false
        button.frame = self.mainView.frame
        button.addTarget(self, action: "closeButtonTouchUpInside", forControlEvents: UIControlEvents.TouchUpInside)
        button.addTarget(self, action: "closeButtonTouchDown", forControlEvents: UIControlEvents.TouchDown)
        button.addTarget(self, action: "closeButtonTouchUpOutside", forControlEvents: UIControlEvents.TouchUpOutside)
        self.view.addSubview(button)
        self.overlayCloseButton = button
    }
    
    /*!
    Remove overlay close button
    */
    func removeOverlayCloseButton() {
        self.overlayCloseButton.removeFromSuperview()
    }
    
    /*!
    Action on close button touch up inside
    */
    func closeButtonTouchUpInside() {
        closeMenu(true)
    }
    
    /*!
    Action on close button touch down
    */
    func closeButtonTouchDown() {
        self.overlayCloseButton.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
    }
    
    /*!
    Action on close button touch up outside
    */
    func closeButtonTouchUpOutside() {
        self.overlayCloseButton.backgroundColor = UIColor.clearColor()
    }
    
    
    // MARK: Manage Child Controllers
    
    func displayContentController(content: UIViewController) {
        self.addChildViewController(content)
        self.mainView.addSubview(content.view)
        content.view.frame.size = self.mainView.frame.size
        content.didMoveToParentViewController(self)
    }
    
    func removeContentController(content: UIViewController?) {
        if let content = content {
            content.willMoveToParentViewController(nil)
            content.view.removeFromSuperview()
            content.removeFromParentViewController()
        }
    }
    
    func handleTimerFired(notification: NSNotification) {
        g_HWControlHandler.stop()
        
        let timer = notification.object as! Timer

        if let mItem = timer.mediaItem() {
            var assetUrl = mItem.assetURL
            if let urlString = assetUrl.absoluteString {
                println("Item URL: \(urlString)")
            }
            
            let title = mItem.title
            
            var noAvailableSpeaker = 0
            let deviceCount = g_HWControlHandler.getDeviceCount()
            for var i = 0; i < deviceCount; i++ {
                var deviceInfo = g_HWControlHandler.getDeviceInfoByIndex(i)
                
                var found = false
                for deviceId in timer.speakers {
                    if deviceInfo.deviceId == deviceId {
                        noAvailableSpeaker++
                        found = true
                        break
                    }
                }
                
                if found {
                    g_HWControlHandler.addDeviceToSession(deviceInfo.deviceId)
                } else {
                    g_HWControlHandler.removeDeviceFromSession(deviceInfo.deviceId)
                }
            }
            
            if noAvailableSpeaker > 0 {
                // register callback for play ended
                HKWPlayerEventHandlerSingleton.sharedInstance().delegate = self
                
                if alert != nil {
                    alert.dismissViewControllerAnimated(true, completion: nil)
                    alert = nil
                }
                
                // show alert about playing audio
                alert = UIAlertController(title: "Timer Alert", message: "Playing '\(title)'.\nPlease press STOP to stop playing audio.", preferredStyle: .Alert)
                
                alert.addAction(UIAlertAction(title: "STOP", style: UIAlertActionStyle.Default, handler: { (uiAlertAction: UIAlertAction!) -> Void in
                    g_HWControlHandler.stop()
                    self.alert = nil
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
                
                
                g_HWControlHandler.playCAF(assetUrl, songName: title, resumeFlag: false)
            }
            else {
                if alert != nil {
                    alert.dismissViewControllerAnimated(true, completion: nil)
                    alert = nil
                }
                
                // show alert about playing audio
                alert = UIAlertController(title: "Timer Alert", message: "Tried to play '\(title)'.\nBut, there is no speaker available.", preferredStyle: .Alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (uiAlertAction: UIAlertAction!) -> Void in
                    self.alert = nil
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        }
        
        
    }
    
    func hkwPlayEnded() {
        println("Timer audio play has ended.")
        self.alert.dismissViewControllerAnimated(true, completion: nil)
    }

}
