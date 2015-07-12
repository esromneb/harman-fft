//
//  SpeakerListViewController.swift
//  PageApp
//
//  Created by Seonman Kim on 1/15/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

var g_searchingShownBefore = false

extension UIViewController {
    var speakerListContainerViewController: SpeakerListContainerViewController? {
        var parent: UIViewController? = self
        
        // Iterate the parent until it found the SpeakerListContainerViewController or it has no parent anymore
        while (parent != nil) && !(parent is SpeakerListContainerViewController) {
            parent = parent!.parentViewController
        }
        return parent as! SpeakerListContainerViewController?
    }
}

/**
* SpeakerListContainerViewController
* Container for searching page, blank speaker list and speaker list controller
*
* @version 1.0
*/
class SpeakerListContainerViewController: UIViewController {
    
    /// the container view
    @IBOutlet weak var containerView: UIView!
    
    /// the top right add speaker button
    @IBOutlet var addSpeakerBarButton: UIBarButtonItem!
    
    /// current child controller shown
    var currentChildVC: UIViewController?
    
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        
        if !g_searchingShownBefore {
            showSearchingCount()
            g_searchingShownBefore = true
        } else {
            showSpeakerList()
        }
    }
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue is EmptySegue {
            removeContentController(currentChildVC)
            currentChildVC = segue.destinationViewController as? UIViewController
            displayContentController(currentChildVC!)
        }
    }
    
    /*!
    Setup the navigation bar
    */
    func setupNavigation() {
        // Used image for the navigation title
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "nav_title_image"))
        
        // Change background using image to achieve the same appearence with the design
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "navigation_bar_image"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    }
    
    /*!
    Show searching controller
    */
    func showSearchingCount() {
        self.performSegueWithIdentifier("SearchingSegue", sender: self)

        
        // Set the right bar button item when searching
        self.navigationItem.rightBarButtonItem = addSpeakerBarButton
//        addSpeakerBarButton.enabled = false
    }
    
    func showSearching() {
        //        self.performSegueWithIdentifier("SearchingSegue", sender: self)
        self.performSegueWithIdentifier("RadarSearchingSegue", sender: self)
        
        
        // Set the right bar button item when searching
        self.navigationItem.rightBarButtonItem = addSpeakerBarButton
        //        addSpeakerBarButton.enabled = false
    }
    
    /*!
    Show blank speaker list controller
    */
    func showBlankSpeakerList() {
        self.performSegueWithIdentifier("EmptySpeakerListSegue", sender: self)
        removeRightBarButton()
    }
    
    /*!
    Show speaker list
    */
    func showSpeakerList() {
        self.performSegueWithIdentifier("SpeakerListTabSegue", sender: self)
        addRightBarButton()
    }
    
    /*!
    Add right bar button item (Searching button)
    */
    func addRightBarButton() {
        self.navigationItem.rightBarButtonItem = addSpeakerBarButton
        addSpeakerBarButton.tintColor = UIColor.whiteColor()
        addSpeakerBarButton.enabled = true
    }
    
    /*!
    Remove right bar button item (Searching button)
    */
    func removeRightBarButton() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    /*!
    Action on add speaker button button did press
    
    :param: sender the sender object
    */
    @IBAction func addSpeakerButtonDidPress(sender: AnyObject) {
        showSearching()
    }
    
    /*!
    Action on menu button did press
    
    :param: sender the sender object
    */
    @IBAction func menuButtonDidPress(sender: AnyObject) {
        self.menuContainerViewController?.toggleMenu(true)
    }
    
    
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
