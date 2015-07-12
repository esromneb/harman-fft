//
//  Helper.swift
//  Wake
//
//  Created by TCSASSEMBLER on 12/28/14.
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit


extension UIColor {
    /**
    Initializes the UIColor with the passed integer values RGBA
    */
    convenience init(r: Int, g: Int, b: Int, a: CGFloat) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }

    /**
    Initializes the UIColor with the passed integer values RGB
    */
    convenience init(r: Int, g: Int, b: Int) {
        self.init(r: r, g: g, b: b, a: 1)
    }

    /**
    Gets the identity color

    :returns: the application identity color
    */
    class func appIdentityColor() -> UIColor {
        return UIColor(r: 101, g: 170, b: 235)
    }

    func createImageWithSize(size: CGSize) -> UIImage {
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension String {
    func toTypeSafeInt() -> Int {
        if let safeInt = self.toInt() {
            return safeInt
        } else {
            return 0
        }
    }
}

func cos(angle: CGFloat) -> CGFloat {
    return CGFloat(cosf(Float(angle)))
}

func sin(angle: CGFloat) -> CGFloat {
    return CGFloat(sinf(Float(angle)))
}