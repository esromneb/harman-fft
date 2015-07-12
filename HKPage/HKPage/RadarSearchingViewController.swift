//
//  RadarSearchingViewController.swift
//  HKTime
//
//  Created by Seonman Kim on 3/6/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
* Protocol for notifying the delegate about the search finish event.
*
* @author Alexander Volkov
* @version 1.0
*/
protocol RadarSearchingViewControllerDelegate {
    
    /**
    Invoked when the search for speakers is finished.
    */
    func searchFinished()
    
}

/**
* RadarSearchingViewController
* Controller for searching speakers
*
* @author TCSCODER, Alexander Volkov
* @version 1.1
*
* changes:
* 1.1:
* - Search screen is noticeably changed:
* -- The screen dynamically displays the speaker icons based on the number of speakers detected.
* -- Icons are evenly spaced around the center circle, one icon per detected speaker.
* -- Icons reflect the correct speaker type.
* -- The icon's distance from the center is based on one of five levels of signal strength (DBM).
* -- Speaker model and room names are shown under each icon.
* -- Tapping on any speaker presents Edit Speaker View for the selected speaker.
*/
class RadarSearchingViewController: UIViewController {
    
    /// Option: true - a custom navigation title wil be used, false - the title will be nested from the parentViewController
    let OPTION_USE_CUSTOM_NAVIGATION_TITLE = true
    
    /// state page right now (searching or done)
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var foundLabel: UILabel!
    
    /// founded speaker count label
    @IBOutlet weak var nFoundLabel: UILabel!
    @IBOutlet weak var foundSuffix: UILabel!
    
    // circles that imitate a 'sonar'
    @IBOutlet weak var circle1View: UIView!
    @IBOutlet weak var circle2View: UIView!
    @IBOutlet weak var circle3View: UIView!
    @IBOutlet weak var circle4View: UIView!
    
    /// the reference to the delegate to notify about a search end
    var delegate: RadarSearchingViewControllerDelegate?
    
    /// timer for simulating loading
    var timer: NSTimer!
    
    /// the timer for loading indicator animation
    var loadingIndicatorTimer: NSTimer?
    
    /// the number of current iteration of the loading indicator animation
    var loadingIndicatorCounter = 0
    
    /// number of data needed to be loaded
    var nData: Int = 0;
    
    /// number of loaded data
    var nLoadedData: Int = 0;
    
    /// last tapped speaker
    var lastSelectedSpeaker: DeviceInfo!
  
    var speakers : [DeviceInfo]!

    
    /// list of views added for the speakers
    var foundSpeakersIcons = [UIView]()
    
    var stopQuerying = false

    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make blue circles from rectanges
        makeRound(circle1View)
        makeRound(circle2View)
        makeRound(circle3View)
        makeRound(circle4View)
        
        // automatically start search when loaded
        startSearch()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        stopQuerying = false
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            while (!self.stopQuerying) {
                sleep(2)
                var deviceCount = HKWControlHandler.sharedInstance().getDeviceCount()
                for var i = 0; i < deviceCount; i++ {
                    let deviceInfo = HKWControlHandler.sharedInstance().getDeviceInfoByIndex(i)
                    HKWControlHandler.sharedInstance().refreshDeviceWiFiSignal(deviceInfo.deviceId)
                }
                
                if (self.stopQuerying) {
                    break;
                }
            }
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        stopQuerying = true
    }

    
    /**
    Change given rectangle view to a circle through adding rounded corners.
    
    :param: view the view to change
    */
    func makeRound(view: UIView) {
        view.layer.cornerRadius = view.frame.size.height/2
        view.layer.masksToBounds = true
    }
    
    /**
    Change navigation bar title to "Scanning" or "Found" depending on the parameter.
    
    :param: isScanning flag: true - need to show "Scanning", else "Found"
    */
    func setupNavigation(isScanning: Bool) {
        if OPTION_USE_CUSTOM_NAVIGATION_TITLE {
            if let vc = self.parentViewController as? SpeakerListContainerViewController {
                // Used custom label for the navigation title
                let label = UILabel(frame: CGRectMake(0, 0, self.view.frame.width, 44))
                if isScanning {
                    label.text = "Scanning"
                }
                else {
                    label.text = "Found"
                }
                label.textAlignment = NSTextAlignment.Center
                label.textColor = UIColor.whiteColor()
                vc.navigationItem.titleView = label
                vc.navigationController?.navigationBar.backgroundColor = UIColor(red: 18/255, green: 26/255, blue: 35/255, alpha: 1.0)
                vc.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "search_nav_background"), forBarMetrics: UIBarMetrics.Default)
            }
        }
    }
    
    /**
    Start searching
    */
    func startSearch() {
        setupNavigation(true)
        
        // Show "Scanning" label
        stateLabel.text = "Scanning"
        stateLabel.hidden = false
        foundLabel.hidden = true
        // Animate scanning label
        loadingIndicatorCounter = 0
        loadingIndicatorTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "animateScanning", userInfo: nil, repeats: true)
        
        foundSuffix.hidden = true
        
        for view in foundSpeakersIcons {
            view.removeFromSuperview()
        }
        foundSpeakersIcons.removeAll(keepCapacity: false)
        
        speakers = [DeviceInfo]()
        nData = HKWControlHandler.sharedInstance().getDeviceCount()

        for var i = 0; i < nData; i++ {
            speakers.append(HKWControlHandler.sharedInstance().getDeviceInfoByIndex(i))
        }
        speakers.sort { $0.wifiSignalStrength > $1.wifiSignalStrength}
        
        nLoadedData = 0
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "searching", userInfo: nil, repeats: true)
    }
    
    /**
    Change "Scanning" label suffix
    */
    func animateScanning() {
        loadingIndicatorCounter++
        
        var suffix = ""
        let n = loadingIndicatorCounter%4
        if n > 0 {
            for i in 1...n {
                suffix += "."
            }
        }
        stateLabel.text = "Scanning\(suffix)"
    }
    
    /*!
    Searching began
    */
    func searching() {
        
        if nData == 0 {
            timer.invalidate()
            
            // Change title
            setupNavigation(false)
            
            // Change state label
            stateLabel.hidden = true
            foundLabel.hidden = false
            loadingIndicatorTimer?.invalidate()
            
            nFoundLabel.text = "0 speaker"
            foundSuffix.hidden = false
            
            delegate?.searchFinished()

        } else {
            // speaker
            let speaker = speakers[nLoadedData]
            showFoundSpeaker(speaker)
            
            // Added loaded data
            nLoadedData++
            
            // Updated label
            nFoundLabel.text = "\(nLoadedData) speaker" + ( nLoadedData > 0 ? "s" : "" )
            
            // Searching done if loaded data count is same with data needed to be loaded
            if nLoadedData == nData {
                timer.invalidate()
                
                // Change title
                setupNavigation(false)
                
                // Change state label
                stateLabel.hidden = true
                foundLabel.hidden = false
                loadingIndicatorTimer?.invalidate()
                
                nFoundLabel.text = "\(nLoadedData) speaker" + ( nLoadedData > 0 ? "s" : "" )
                foundSuffix.hidden = false
                
                delegate?.searchFinished()
            }
        }
    }
    
    /**
    Show found speaker in the view.
    
    :param: speaker found speaker
    */
    func showFoundSpeaker(speaker: DeviceInfo) {
        
        let modelName = speaker.modelName
        let groupName = speaker.groupName
        let signal = speaker.wifiSignalStrength
        println("model:\(modelName), group:\(groupName), signal:\(signal)")
        
        let icon = UIView()
        
        // Image
        let image = getIconImageForModel(modelName)
        let imageView = UIImageView(image: image)
        icon.addSubview(imageView)
        
        // Model label
        let labelHeight: CGFloat = 12
        let labelYOffset = imageView.frame.height
        let labelWidth: CGFloat = 100
        let font = UIFont(name: "Arial", size: 10)
        let model = UILabel(frame: CGRectMake((imageView.frame.width - labelWidth)/2, labelYOffset, labelWidth, labelHeight))
        model.font = font
        model.textAlignment = NSTextAlignment.Center
        model.text = modelName
        model.textColor = UIColor.whiteColor()
        icon.addSubview(model)
        
        // Room
        let room = UILabel(frame: CGRectMake((imageView.frame.width - labelWidth)/2, model.frame.height + model.frame.origin.y, labelWidth, labelHeight))
        room.font = font
        room.textAlignment = NSTextAlignment.Center
        if speaker.groupId == 0 {
            room.text = kGroupNotAssigned
        } else {
            room.text = groupName
        }
        room.textColor = UIColor.whiteColor()
        icon.addSubview(room)
        
        // Edit button
        let button = EditSpeakerButton(frame: imageView.bounds)
        button.deviceInfo = speaker
        button.addTarget(self, action: "editButton:", forControlEvents: UIControlEvents.TouchUpInside)
        icon.addSubview(button)
        
        
        icon.frame = imageView.bounds
        icon.clipsToBounds = false
        
        ///  Place Speaker icon in view
        // evenly angle
        let angle: CGFloat = getEvenlyAngle()
        
        // distance
        let distance = getDistanceForSpeaker(signal)
        
        let x = self.circle4View.frame.midX + cos(angle) * distance - icon.frame.width/2
        let y = self.circle4View.frame.midY + sin(angle) * distance - icon.frame.height/2
        
        icon.frame.origin = CGPointMake(x, y)
        
        self.view.addSubview(icon)
        foundSpeakersIcons.append(icon)
    }
    
    /**
    Get evenly angle for next speaker.
    Uses the index of currently found speaker.
    
    :returns: the angle to place the next speaker at
    */
    func getEvenlyAngle() -> CGFloat {
        let n = Double(nData)
        if n > 2 {
            let i = Double(nLoadedData)
            let angleStep = CGFloat(M_PI * 2 / n * (floor(n/2) + 1) )
            return angleStep * CGFloat(self.nLoadedData)
        }
        else {
            // bug fix by Seonman
            return CGFloat(M_PI * Double(nLoadedData))
        }
    }
    
//    func getEvenlyAngle() -> CGFloat {
//        let n = Double(nData)
//        if n > 2 {
//            let i = Double(nLoadedData)
//            let angleStep = CGFloat(M_PI * 2 / n * (floor(n/2) + 1) )
//            return angleStep * CGFloat(self.nLoadedData)
//        }
//        else {
//            return CGFloat(M_PI)
//        }
//    }
    
    /**
    Get distance from the center for given speaker.
    Uses signal strength.
    
    :param: speaker the speaker
    */
    func getDistanceForSpeaker(signal: Int) -> CGFloat {
        let iconSize: CGFloat = 60
//        let maxDistance = (self.view.frame.width - iconSize ) / 2
        let maxDistance = (self.view.frame.height - iconSize ) / 2

        let minDistance = self.circle4View.frame.width/2 + 10
        
        let numberOfLevels = 5
        var level = 0
        switch signal {
        case let s where s >= -30:
            level = 0
        case let s where -30 > s && s >= -50:
            level = 1
        case let s where -50 > s && s >= -70:
            level = 2
        case let s where -70 > s && s >= -90:
            level = 3
        default:
            level = 4
        }
        return minDistance + (maxDistance - minDistance) * CGFloat(level) / CGFloat(numberOfLevels)
    }
    
    /**
    Edit speaker action
    
    :param: button the button
    */
    func editButton(button: EditSpeakerButton) {
        lastSelectedSpeaker = button.deviceInfo
        self.performSegueWithIdentifier("EditSearchedSpeaker", sender: self)
    }
    
    /**
    Provide speaker object into "Edit Speaker" screen.
    
    :param: segue  the segue to "Edit Speaker" screen.
    :param: sender the view controller
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "EditSearchedSpeaker" {
                var controller = segue.destinationViewController as! EditSpeakerViewController
                controller.deviceInfo = lastSelectedSpeaker
            }
        }
    }
    
}

/**
* Button that contains a speaker reference.
* Used to create "Edit Speacker" button.
*
* @author Alexander Volkov
* @version 1.0
*/
class EditSpeakerButton: UIButton {
    
//    var speaker: Speaker!
    var deviceInfo: DeviceInfo!
}