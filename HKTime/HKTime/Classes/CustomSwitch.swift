//
//  CustomSwitch.swift
//  OnOff
//
//  Created by TCSASSEMBLER on 12/28/14.
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
The delegate protocol for the custom switch

:author:  TCSASSEMBLER
:version: 1.0
*/
@objc
protocol CustomSwitchDelegate {
    /**
    the switch state changed
    */
    func customSwitch(customSwitch: CustomSwitch, stateChangedTo isOn: Bool)
}

/**
The custom switch control is very similar to UISwitch but with different design

:author:  TCSASSEMBLER
:version: 1.0
*/
class CustomSwitch: UIView {

    /// the delegate
    weak var delegate: CustomSwitchDelegate?

    /// the scroll view
    var scrollView: UIScrollView!

    /// the on background image
    var onBackgroundImage: UIImageView!

    /// whether or not dragging has ended
    var endDragging = false

    /// the variable that holds the state of the switch (ON/OFF)
    var isOn = true

    /**
    Sets the state of the switch

    :param: isOn the state of the switch
    :param: animated whether or not perform animation while setting the state
    :param: informDelegate wether or not to inform the delegate
    */
    private func setIsOn(isOn: Bool, animated: Bool, informDelegate: Bool) {
        if isOn {
            scrollView.setContentOffset(CGPointZero, animated: animated)
        } else {
            scrollView.setContentOffset(CGPoint(x: scrollView.contentSize.width - scrollView.bounds.width,
                y: 0), animated: animated)
        }

        if self.isOn != isOn {
            self.isOn = isOn
            if informDelegate {
                delegate?.customSwitch(self, stateChangedTo: isOn)
            }
        }
    }

    /**
    Sets the state of the delegate

    :param: isOn the state of the delegate
    :param: animated whether or not the state is active or inactive
    */
    func setIsOn(isOn: Bool, animated: Bool) {
        setIsOn(isOn, animated: animated, informDelegate: false)
    }

    /**
    Creates new instance
    */
//    override init() {
//        super.init()
//        setup()
//    }

    /**
    Create new instance with coder

    :param: coder the decoder to unarchive from
    */
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    /**
    Create new instance with frame

    :param: frame the frame to use for the view
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    /**
    sets up the view
    */
    func setup() {

        if scrollView != nil {
            return
        }

        // create views
        let offBackgroundImage = UIImageView(image: UIImage(named: "off-bg1"))
        onBackgroundImage = UIImageView(image: UIImage(named: "on-bg"))
        scrollView = UIScrollView()
        let toggleImage = UIImageView(image: UIImage(named: "toggle"))
        let onLabel = UILabel()
        let offLabel = UILabel()

        // disable auto resizing
        offBackgroundImage.setTranslatesAutoresizingMaskIntoConstraints(false)
        onBackgroundImage.setTranslatesAutoresizingMaskIntoConstraints(false)
        scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        toggleImage.setTranslatesAutoresizingMaskIntoConstraints(false)
        onLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        offLabel.setTranslatesAutoresizingMaskIntoConstraints(false)

        // create hierarchy
        addSubview(offBackgroundImage)
        addSubview(onBackgroundImage)
        addSubview(scrollView)
        scrollView.addSubview(toggleImage)
        scrollView.addSubview(onLabel)
        scrollView.addSubview(offLabel)

        // **** create constraints ****
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|",
            options: NSLayoutFormatOptions(0), metrics: nil, views: ["view": offBackgroundImage]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|",
            options: NSLayoutFormatOptions(0), metrics: nil, views: ["view": offBackgroundImage]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|",
            options: NSLayoutFormatOptions(0), metrics: nil, views: ["view": onBackgroundImage]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|",
            options: NSLayoutFormatOptions(0), metrics: nil, views: ["view": onBackgroundImage]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|",
            options: NSLayoutFormatOptions(0), metrics: nil, views: ["view": scrollView]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|",
            options: NSLayoutFormatOptions(0), metrics: nil, views: ["view": scrollView]))

        // center the vertically views
        scrollView.addConstraint(NSLayoutConstraint(item: toggleImage, attribute: .CenterY,
            relatedBy: .Equal, toItem: scrollView, attribute: .CenterY, multiplier: 1.0, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: onLabel, attribute: .CenterY,
            relatedBy: .Equal, toItem: scrollView, attribute: .CenterY, multiplier: 1.0, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: offLabel, attribute: .CenterY,
            relatedBy: .Equal, toItem: scrollView, attribute: .CenterY, multiplier: 1.0, constant: 0))


        // horizontal layout
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-33-[view]",
            options: NSLayoutFormatOptions(0), metrics: nil, views: ["view": toggleImage]))

        scrollView.addConstraint(NSLayoutConstraint(item: toggleImage, attribute: .Leading,
            relatedBy: .Equal, toItem: onLabel, attribute: .Trailing, multiplier: 1.0, constant: 4))

        scrollView.addConstraint(NSLayoutConstraint(item: offLabel, attribute: .Leading,
            relatedBy: .Equal, toItem: toggleImage, attribute: .Trailing, multiplier: 1.0, constant: 1))


        onLabel.text = "ON"
        offLabel.text = "OFF"
        onLabel.textColor = UIColor.whiteColor()
        offLabel.textColor = UIColor.whiteColor()
        onLabel.font = UIFont(name: "arial", size: 13)
        offLabel.font = UIFont(name: "arial", size: 13)

        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.pagingEnabled = true
        scrollView.bounces = false
        scrollView.contentSize = CGSizeMake(offBackgroundImage.image!.size.width * 2 - toggleImage.image!.size.width,
            offBackgroundImage.image!.size.height)

        self.backgroundColor = UIColor.clearColor()

        // create the tap gesture
        let tap = UITapGestureRecognizer(target: self, action: Selector("switchTapped"))
        scrollView.addGestureRecognizer(tap)

        // invalidate the intrinsic content size
        invalidateIntrinsicContentSize()
    }

    /**
    Returns the natural size for the receiving view, considering only properties of the view itself.
    */
    override func intrinsicContentSize() -> CGSize {
        return onBackgroundImage.image!.size
    }

    /**
    switch button tapped
    */
    @objc func switchTapped() {
        setIsOn(!isOn, animated: true, informDelegate: true)
    }
}

extension CustomSwitch : UIScrollViewDelegate {

    /// the scroll percentage
    var scrollPercentage : CGFloat {
        return scrollView.contentOffset.x / (scrollView.contentSize.width - scrollView.bounds.width)
    }

    /**
    scrol view did scroll
    :param: scrollView the scroll view
    */
    func scrollViewDidScroll(scrollView: UIScrollView) {
        onBackgroundImage.alpha = 1 - scrollPercentage
    }

    /**
    scroll view did end dragging
    */
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            endScrolling()
        } else {
            endDragging = true
        }
    }

    /**
    Scroll view did end decelerating
    */
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if endDragging {
            endDragging = false
            endScrolling()
        }
    }

    func endScrolling() {
        let percentage = scrollPercentage
        setIsOn(percentage < 0.5, animated: true, informDelegate: true)
    }
}