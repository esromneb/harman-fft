//
//  RotatedImageView.swift
//  PageApp
//
//  Created by Seonman Kim on 1/15/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

class RotatedImageView: UIImageView {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func runAnimation() {
        var animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = atan2f(Float(self.transform.b), Float(self.transform.a));
        animation.toValue = 2*M_PI
        animation.duration = 1.0
        animation.repeatCount = Float32.infinity
        self.layer.addAnimation(animation, forKey: "rotation")
    }
    
    func stopAnimation() {
        self.layer.removeAllAnimations()
    }
}
