//
//  SpeakerTableCell.swift
//  HKTime
//
//  Created by Seonman Kim on 2/1/2015.
//  Copyright (c) 2015 Harman International. All rights reserved.
//


import UIKit

// Speaker Cell Delegate
protocol SpeakerTableCellDelegate {
    func speakerTableCell(speakerTableCell: SpeakerTableCell, editButtonDidPressAtIndex indexPath: NSIndexPath)
    func speakerTableCell(speakerTableCell: SpeakerTableCell, deleteButtonDidPressAtIndex indexPath: NSIndexPath)
}

/**
* SpeakerTableCell
* Table cell for speaker list view
*
* @version 1.0
*/
class SpeakerTableCell: UITableViewCell {

    /// image view for icon
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet var deviceNameLabel: UILabel!

    
    /// label for room
    @IBOutlet weak var roomLabel: UILabel!
    
    /// button for mic
    @IBOutlet weak var micButton: UIButton!
    
    /// view for edit button
    @IBOutlet weak var buttonsView: UIView!
    
    /// edit button
    @IBOutlet weak var editButton: UIButton!
    
    /// button's constraint using for showing/hiding buttons view
    @IBOutlet weak var buttonsViewTrailingConstraint: NSLayoutConstraint!
    
    /// mic effect
    @IBOutlet weak var micEffect: RotatedImageView!
    
    /// the delegate
    var delegate: SpeakerTableCellDelegate?
    
    var deviceInfo: DeviceInfo!
    
    /// pan recognizer
    var panRecognizer: UIPanGestureRecognizer!
    
    /// start point for panning gesture
    var panStartPoint: CGPoint!
    
    /// starting trailing constraint value
    var startingTrailingConstant: CGFloat!
    
    /// is buttons view shown?
    var buttonsViewShown: Bool = true
    
    /// this cell index
    var cellIndex: NSIndexPath!
    
    var isForAlarm = false
    
    var streamingActivity: StreamingActivityView!

    
    override func awakeFromNib() {
        super.awakeFromNib()

        setupGestureRecognizer()
        hideButtonsView(animated: false)
        
        streamingActivity = StreamingActivityView()
        var rect = CGRect(x: self.frame.width - 120, y: 40, width: 32, height: 20)
        streamingActivity.frame = rect
        addSubview(streamingActivity)
    }
    
    /*!
    Adding pan gesture recognizer
    */
    func setupGestureRecognizer() {
        panRecognizer = UIPanGestureRecognizer(target: self, action: "panCell:")
        panRecognizer.delegate = self
        self.contentView.addGestureRecognizer(panRecognizer)
    }
    
    /*!
    Calculate total with for every buttons in swiping view
    
    :return: total width
    */
    func totalButtonsWidth() -> CGFloat {
        return editButton.frame.size.width
    }
    
    /*!
    Do the pan
    
    :param: recognizer the gesture recognizer
    */
    func panCell(recognizer: UIPanGestureRecognizer) {
        if isForAlarm {
            return
        }
        switch recognizer.state {
            
            case .Began:
                // Set starting point
                panStartPoint = recognizer.translationInView(self.contentView)
                startingTrailingConstant = buttonsViewTrailingConstraint.constant
            
            case .Changed:
                
                // Calculate delta
                var currentPoint = recognizer.translationInView(self.contentView)
                var deltaX = currentPoint.x - panStartPoint.x
                
                // Check whether the panning is to the left or to the right
                var panningLeft = false
                if currentPoint.x < panStartPoint.x {
                    panningLeft = true
                }
                
                if !panningLeft {
                    // The panning is to the right
                    var constant = max(startingTrailingConstant-deltaX, -totalButtonsWidth())
                    buttonsViewTrailingConstraint.constant = constant
                }
                else {
                    // The panning is to the right
                    var constant = min(-totalButtonsWidth() - deltaX, 0)
                    buttonsViewTrailingConstraint.constant = constant
                }
                
                // Animate
                self.updateConstraintsIfNeeded(true, completion: nil)
            
            case .Ended:
                
                // End the pan
                var currentPoint = recognizer.translationInView(self.contentView)
                endPan(currentPoint)
            
            case .Cancelled:
                
                // End the pan
                var currentPoint = recognizer.translationInView(self.contentView)
                endPan(currentPoint)
            
            default:
                fatalError("Recognizer's state is not found")
        }
    }
    
    /*!
    End the pan
    
    :param: endPoint last point of the pan gesture
    */
    func endPan(endPoint: CGPoint) {
        // Calculate total delta
        var deltaX = endPoint.x - panStartPoint.x
        
        var half = totalButtonsWidth()/2
        
        // If the swiping view is shown
        if buttonsViewShown {
            // If the delta is more than half
            if deltaX >= half {
                
                // hide the view
                hideButtonsView()
            }
            else {
                
                // keep showing the view
                showButtonsView()
            }
        }
            
        // If the swiping view is now shown
        else {
            
            // If the delta is more than half in reverse direction
            if deltaX <= half {
                
                // show the view
                showButtonsView()
            }
            else {
                
                // keep hiding the view
                hideButtonsView()
            }
        }
    }
    
    /*!
    Show buttons view
    
    :param: animated should the showing being animated
    */
    func showButtonsView(animated: Bool = true) {
        buttonsViewShown = true
        buttonsViewTrailingConstraint.constant = 0
        self.updateConstraintsIfNeeded(animated, completion: nil)
    }
    
    /*!
    Hide buttons view
    
    :param: animated should the hiding being animated
    */
    
    func hideButtonsView(animated: Bool = true) {
        buttonsViewShown = false
        buttonsViewTrailingConstraint.constant = -totalButtonsWidth()
        self.updateConstraintsIfNeeded(animated, completion: nil)
    }
    
    /*!
    Update constraint
    
    :param: animated should the update being animated
    :param: completion completion callback
    */
    
    func updateConstraintsIfNeeded(animated: Bool, completion: ((Bool)->())?) {
        var duration: CGFloat = 0.0
        
        // Set duration
        if animated {
            duration = 0.1
        }
        
        // Animate
        UIView.animateWithDuration (NSTimeInterval(duration), delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.layoutIfNeeded()
            }, completion: completion)
    }
    
    
    /*!
    Action on mic button did press
    
    :param: sender the sender object
    */
    @IBAction func micButtonDidPress(sender: AnyObject) {
        println("micButtonDidPress")
        println("deviceid: \(deviceInfo.deviceId), deviceName: \(deviceInfo.deviceName)")

        
        // Set broadcast state for the speaker and its room
        micButton.selected = !micButton.selected
        
    }
    
    /*!
    Action on "Edit" button did press
    
    :param: sender the sender object
    */
    @IBAction func editButtonDidPress(sender: AnyObject) {
        delegate?.speakerTableCell(self, editButtonDidPressAtIndex: cellIndex)
        hideButtonsView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        hideButtonsView(animated: false)
    }
    
    // MARK: UIGestureRecognizer Delegate
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {

        
        if gestureRecognizer is UIPanGestureRecognizer {
            
            var panRecognizer = gestureRecognizer as! UIPanGestureRecognizer
            
            // Check whether the pan is from left -> right / right -> left
            var translation = panRecognizer.translationInView(self.contentView)
            if abs(translation.x) > abs(translation.y) {
                return true
            }            
            return false
        }
        return true
    }
}
