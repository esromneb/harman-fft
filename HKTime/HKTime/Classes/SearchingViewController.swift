//
//  SearchingViewController.swift
//  HKTime
//
//  Created by Seonman Kim on 2/1/2015.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
* SearchingViewController
* Controller for searching speakers
*
* @version 1.0
*/
class SearchingViewController: UIViewController {
    
    /// image view for outer circle
    @IBOutlet weak var outerCircleImageView: UIImageView!
    
    /// image view for speaker image
    @IBOutlet weak var speakerImageView: UIImageView!
    
    /// image view for searching effect
    @IBOutlet weak var searchingEffect: RotatedImageView!
    
    /// view for searching percentage
    @IBOutlet weak var searchingPercentView: SearchingPercentView!
    
    /// founded speaker count label
    @IBOutlet weak var nFoundLabel: UILabel!
    
    /// state page right now (searching or done)
    @IBOutlet weak var stateLabel: UILabel!
    
    /// timer for simulating loading
    var timer: NSTimer!
    
    /// status of speaker image view
    var speakerOn: Bool = false
    
    /// number of data needed to be loaded
    var nData: Int = 0;
    
    /// number of loaded data
    var nLoadedData: Int = 0;
    
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchingEffect.runAnimation()
        
        // Initialize
        initalize()
    }
    
    func initalize() {
        searchingPercentView.percent = 0
        nLoadedData = 0;
        speakerOn = false;
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "searching", userInfo: nil, repeats: true)
    }
    
    /*!
    Searching began
    */
    func searching() {
        if g_HWControlHandler.getDeviceCount() == 0 {
            timer.invalidate()
            
            nFoundLabel.text = "No Speaker Found"
            searchingPercentView.percent = 100

            
            // Change state label
            stateLabel.text = "Done"
            
            // Hide the effect
            searchingEffect.hidden = true
            
            // Change the state image
            outerCircleImageView.image = UIImage(named: "circle_loading_red")
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "redCirclingDone", userInfo: nil, repeats: false)
            
            return
        }
        
        
        // Added loaded data
        nLoadedData++
        
        // Updated label
        nFoundLabel.text = "\(nLoadedData) Found"
        searchingPercentView.percent = Double(nLoadedData)/Double(nData) * 100.0
        
        // Check if the speaker image should be on or not
        if nLoadedData > 0 && !speakerOn {
            speakerOn = true
            speakerImageView.image = UIImage(named: "speaker_loading_on")
        }
        
        // Searching done if loaded data count is same with data needed to be loaded
        
        var noSpeaker = 0

        noSpeaker = g_HWControlHandler.getDeviceCount()
        if nLoadedData == noSpeaker {
            timer.invalidate()
            
            // Change state label
            stateLabel.text = "Done"
            
            // Hide the effect
            searchingEffect.hidden = true
            
            // Change the state image
            outerCircleImageView.image = UIImage(named: "circle_loading_red")
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "redCirclingDone", userInfo: nil, repeats: false)
        }
    }
    
    /*!
    Red outer circle should be done
    */
    func redCirclingDone() {
        outerCircleImageView.image = UIImage(named: "circle_loading_on")
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "searchingDone", userInfo: nil, repeats: false)
    }
    
    /*!
    Searching is done
    */
    func searchingDone() {
        self.speakerListContainerViewController?.showSpeakerList()
    }
    
}


/**
* SearchingPercentView
* view for circle progress percentage for searching screen
*
* @version 1.0
*/
class SearchingPercentView: UIView {
    
    /// the percent value
    var percent: Double = 65 {
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
        let radius = self.bounds.size.width/2
        
        // draw
        UIColor(red: 0/255, green: 172/255, blue: 236/255, alpha: 0.1).setFill()
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, center.x, center.y);
        let endAngle = M_PI * 2.0 * percent/100.0
        CGContextAddArc(context, center.x, center.y, radius, CGFloat(endAngle), 0, 1)
        CGContextClosePath(context)
        CGContextFillPath(context)
    }
}