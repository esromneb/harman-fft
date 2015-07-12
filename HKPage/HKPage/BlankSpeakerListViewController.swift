//
//  BlankSpeakerListViewController.swift
//  PageApp
//
//  Created by Seonman Kim on 1/15/15.
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import UIKit

/**
* BlankSpeakerListViewController
* Controller for speaker list with zero element
*
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
