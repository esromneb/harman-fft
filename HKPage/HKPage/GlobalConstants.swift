//
//  GlobalConstants.swift
//  HKPage
//
//  Created by Seonman Kim on 5/21/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import Foundation
import UIKit

// HKWirelessHD license key used for initializeHKWirelessHD
let kLicenseKeyGlobal = "2FA8-2FD6-C27D-47E8-A256-D011-3751-2BD6"

// The URL Scheme for HK Apps
let kHKControllerAppURLScheme = "hkcontroller"
let kHKControllerAppURL = kHKControllerAppURLScheme + "://"

let kHKPageAppURLScheme = "hkpage"
let kHKPageAppURL = kHKPageAppURLScheme + "://"

let kHKWakeAppURLScheme = "hkwake"
let kHKWakeAppURL = kHKWakeAppURLScheme + "://"

let kHKTimeAppURLScheme = "hktime"
let kHKTimeAppURL = kHKTimeAppURLScheme + "://"

// The App URL for HK Controller App
let kHKControllerAppStoreURL = "https://itunes.apple.com/us/app/harman-kardon-controller/id905859401?mt=8"

let kGroupNotAssigned = "Not Assigned"

// Retrieve the corresponding speaker icon from the model name
func getIconImageForModel(modelName: String) -> UIImage
{
    if modelName == kModelNameOmni10 {
        return UIImage(named: "speaker_fc1")!
    } else if modelName == kModelNameOmni20{
        return UIImage(named: "speaker_fc2")!
    } else if modelName == kModelNameOmniBar {
        return UIImage(named: "speaker_omnibar")!
    }
    else {
        return UIImage(named: "speaker_fca10")!
    }
}