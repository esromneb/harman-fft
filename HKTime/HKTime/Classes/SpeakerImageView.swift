//
//  SpeakerImageView.swift
//  HKTime
//
//  Created by TCSASSEMBLER on 12/29/14.
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
Rounded Image view for speaker thumbnails

:author:  TCSASSEMBLER
:version: 1.0
*/
@IBDesignable
class SpeakerImageView: UIImageView {

    /**
    layout subviews of the view
    */
    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundColor = UIColor.whiteColor()
        layer.cornerRadius = bounds.width / 2
    }

}
