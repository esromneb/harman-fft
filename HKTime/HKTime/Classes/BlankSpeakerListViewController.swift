//
//  BlankSpeakerListViewController.swift
//  HKTime
//
//  Created by TCSCODER on 12/17/14.
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
* BlankSpeakerListViewController
* Controller for speaker list with zero element
*
* @author TCSCODER
* @version 1.0
*/
class BlankSpeakerListViewController: UIViewController {
    
    /*!
    Action on "Add Speaker List" button did press
    
    :param: sender the sender object
    */
    @IBAction func addSpeakersListButtonDidPress(sender: AnyObject) {
        self.speakerListContainerViewController?.showSearching()
    }
}
