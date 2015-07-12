//
//  PressableImageView.swift
//  HKTime
//
//  Created by TCSASSEMBLER on 12/28/14.
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
An Image view with pressing/highlighting functionality

:author:  TCSASSEMBLER
:version: 1.0
*/
class PressableImageView: UIImageView {

    /// number of presses for the image view
    var presses = 0

    /**
    press on the image
    */
    func press() {
        presses++
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0
        UIColor.appIdentityColor().getRed(&r, green: &g, blue: &b, alpha: &a)

        tintColor = UIColor(red: r / 2, green: g / 2, blue: b / 2, alpha: a)
    }

    /**
    release the press
    */
    func releasePressing() {
        presses--
        if presses <= 0 {
            presses = 0
            tintColor = UIColor.appIdentityColor()
        }
    }

    /**
    Touch down began
    */
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        press()
    }

    /**
    touch down cancelled
    */
    override func touchesCancelled(touches: Set<NSObject>, withEvent event: UIEvent!) {
        releasePressing()
    }

    /**
    touch is up
    */
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        releasePressing()
    }
}
