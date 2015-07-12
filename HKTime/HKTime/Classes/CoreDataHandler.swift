//
//  CoreDataHandler.swift
//  HKTime
//
//  Created by TCSASSEMBLER on 12/29/14.
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import CoreData

/**
The main persistence store class for accessing the core data

:author:  TCSASSEMBLER
:version: 1.0
*/
class CoreDataHandler {

    /// private constructor so that no one can instantiate it
    private init() {

    }

    // MARK: - Singleton

    /**
    Gets the singleton instance of the handler

    :returns: the singleton instance
    */
    class func defaultCoreDataHandler() -> CoreDataHandler {
        struct Static {
            static var once: dispatch_once_t = 0
            static var handler: CoreDataHandler!
        }

        dispatch_once(&Static.once) {
            Static.handler = CoreDataHandler()
        }
        return Static.handler
    }

    
}

// MARK: - Public API

extension CoreDataHandler {

    /**
    Fetch list of timers

    :returns: list of timers
    */
    func fetchTimers() -> [Timer] {

        let request = AppDelegate.sharedInstance.managedObjectModel.fetchRequestTemplateForName("timers")!
        let result = self.executeFetchRequest(request) as! [Timer]
        
        for timer in result {
            // restore the array of speakers (deviceId)
            timer.speakers = constructDeviceIdArrayFromString(timer.speakerListStr)
            timer.secondsTotalTime = timer.getTotalSeconds()
        }
        return result
    }
    
    /**
    executes the fetch request

    :param: request the fetch request
    :returns: the list of retrieved objects
    */
    private func executeFetchRequest(request: NSFetchRequest) -> [AnyObject] {

        var error: NSError?
        let result = AppDelegate.sharedInstance.managedObjectContext?.executeFetchRequest(request, error: &error)
        if error != nil {
            println("unexpected error while fetching data from CoreData:\(error)")
            return []
        }
        
        return result!
    }
}
