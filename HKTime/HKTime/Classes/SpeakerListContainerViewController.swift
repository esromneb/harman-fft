//
//  SpeakerListViewController.swift
//  HKTime
//
//  Created by Seonman Kim on 2/1/2015.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit



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

protocol SpeakerListContainerViewControllerDelegate {
    
    // parameter: deviceId (CLongLong)
    func speakerListConfirmed(speakers: [CLongLong])
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
    
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    
    /// current child controller shown
    var currentChildVC: UIViewController?
    
    /**
    State of the tabs when speakers are found. If not BOTH tabs are enalbed,
    then we need to search automatically after the view controller is opened
    */
    var tabsState: SPEAKER_TABS_STATE = SPEAKER_TABS_STATE.BOTH {
        didSet {
            if tabsState != .BOTH {
                searchAutomatically = true
            }
        }
    }
    var delegate: SpeakerListContainerViewControllerDelegate?
    var timer: TmpTimer?
    
    // If true, then if there are no speakers the search view controller will be automatically loaded
    var searchAutomatically = false
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        
        showSpeakerList()
        
        if timer == nil {
            topMargin.constant = 0
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue is EmptySegue {
            removeContentController(currentChildVC)
            currentChildVC = segue.destinationViewController as? UIViewController
            if let vc = currentChildVC as? SpeakerListTabViewController {
                vc.state = tabsState
                vc.delegate = delegate
                vc.timer = timer

            }
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
    
    func searchFinished() {
        showSpeakerList()
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
