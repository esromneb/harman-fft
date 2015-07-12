//
//  MenuViewController.swift
//  PageApp
//
//  Created by Seonman Kim on 1/15/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

extension UIViewController {
    var menuContainerViewController: MenuContainerViewController? {
        var parent: UIViewController? = self
        
        // Iterate the parent until it found the SpeakerListContainerViewController or it has no parent anymore
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
* @version 1.0
*/
class MenuContainerViewController: UIViewController {
    
    /// the main view
    @IBOutlet weak var mainView: UIView!
    
    /// current child controller
    var currentChildVC: UIViewController?
    
    /// is the menu opened?
    var open: Bool = false
    
    /// overlay close button
    var overlayCloseButton: UIButton!
    
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainView()
        showSpeakerListController()
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
                if identifier == "SetMainViewToSpeakerListSegue" {
                    removeContentController(currentChildVC)
                    currentChildVC = segue.destinationViewController as? UIViewController
                    displayContentController(currentChildVC!)
                }
                else if identifier == "SetMainViewToAlarmSoundListSegue" {
                    removeContentController(currentChildVC)
                    currentChildVC = segue.destinationViewController as? UIViewController
                    displayContentController(currentChildVC!)
                }
            }
        }
    }
    
    /*!
    Show speaker list controller
    */
    func showSpeakerListController() {
        self.closeMenu(true)
        self.performSegueWithIdentifier("SetMainViewToSpeakerListSegue", sender: self)
    }
    
    func showAlarmSoundListController() {
        self.closeMenu(true)
        self.performSegueWithIdentifier("SetMainViewToAlarmSoundListSegue", sender: self)
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
}
