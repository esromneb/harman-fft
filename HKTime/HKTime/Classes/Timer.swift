//
//  Timer.swift
//  HKTime
//
//  Created by TCSASSEMBLER on 12/31/14.
//  Updated by Fabrizio Lovato - fabrizyo on 02/20/2015
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import Foundation
import CoreData
import MediaPlayer

var g_counter = 0

func constructSpeakerListString(deviceList: [CLongLong]) -> String {
    if deviceList.count == 0 {
        return ""
    }
    
    var result = String(format: "%lld", deviceList[0])
    for var i = 1; i < deviceList.count; i++ {
        var idStr = String(format: "%lld", deviceList[i])
        result = result + ",\(idStr)"
    }
    
    return result
}

func constructDeviceIdArrayFromString(listStr: String) -> [CLongLong] {
    var strArray = listStr.componentsSeparatedByString(",")
    var deviceIdArray = [CLongLong]()
    
    for var i = 0; i < strArray.count; i++ {
        var nsStr : NSString = strArray[i]
        deviceIdArray.append(nsStr.longLongValue)
    }
    
    return deviceIdArray
}

func getSpeakersAsString(deviceList: [CLongLong]) -> String {
    if deviceList.count == 0 {
        return ""
    }
    
    var str = ""
    for deviceId in deviceList {
        var deviceInfo = g_HWControlHandler.getDeviceInfoById(deviceId)
        if deviceInfo == nil {
            return ""
        }
        
        str += ( str != "" ? ", " : "") + deviceInfo.deviceName
    }
    return str
}

func getSpeakersInfo(deviceList: [CLongLong]) -> String {
    if deviceList.count == 0 {
        return ""
    }
    
    var str = ""
    for deviceId in deviceList {
        var deviceInfo = g_HWControlHandler.getDeviceInfoById(deviceId)
        if deviceInfo != nil {
            str += ( str != "" ? ", " : "") + deviceInfo.deviceName + "@" + deviceInfo.groupName
        }
    }
    return str
}

func getRoomsAsString(deviceList: [CLongLong]) -> String {
    if deviceList.count == 0 {
        return "No speaker available"
    }
    
    var tempGroupNames = [String]()
    
    for deviceId in deviceList {
        let deviceInfo = g_HWControlHandler.getDeviceInfoById(deviceId)
        var groupName = "N/A"
        if deviceInfo != nil {
            groupName = deviceInfo.groupName
            
            var found = false
            for gName in tempGroupNames {
                if gName == groupName {
                    found = true
                    break
                }
            }
            
            if !found {
                tempGroupNames.append(groupName)
            }
        }
    }
    
    var str = ""
    for s in tempGroupNames {
        str += ( str != "" ? ", " :"") + s
    }
    
    return str
}

@objc(Timer)
class Timer: NSManagedObject {
    
    @NSManaged var hours: Int
    @NSManaged var minutes: Int
    @NSManaged var seconds: Int
    
    @NSManaged var mediaItemPersistentID: String!

     //the date of activation of timer
    @NSManaged var startTime:NSDate?
    
     //the seconds that remain when the timer is not active (stopped)
    @NSManaged var secondsRemaining:NSTimeInterval

    @NSManaged var speakerListStr: String!

    var secondsTotalTime:NSTimeInterval = 0
    
    var speakers: [CLongLong]!
    
    //true if the timer is active
    var isActive: Bool = false
    
    var cell : TimerTableViewCell!
    var cellTimer : NSTimer!
    
    var localNotification: UILocalNotification!


}

extension Timer {
   
    convenience init(_ dirtyTimer: TmpTimer) {
        self.init()
        self.hours = dirtyTimer.hours
        self.mediaItemPersistentID = dirtyTimer.mediaItemPersistentID
        self.minutes = dirtyTimer.minutes
        self.seconds = dirtyTimer.seconds

        self.isActive = dirtyTimer.isActive
        self.speakers = dirtyTimer.speakers
        self.secondsRemaining=dirtyTimer.secondsRemaining
        self.startTime=dirtyTimer.startTime
        
        self.speakerListStr = dirtyTimer.speakerListStr

    }
    
    convenience init(_ dirtyTimer: Timer) {
        self.init()
        self.hours = dirtyTimer.hours
        self.mediaItemPersistentID = dirtyTimer.mediaItemPersistentID
        self.minutes = dirtyTimer.minutes
        self.seconds = dirtyTimer.seconds

        self.isActive = dirtyTimer.isActive
        self.speakers = dirtyTimer.speakers
        self.secondsRemaining=dirtyTimer.secondsRemaining
        self.startTime=dirtyTimer.startTime
        
        self.speakerListStr = constructSpeakerListString(dirtyTimer.speakers)

    }
    /**
    Convenience initializer to add the entity into core data directly
    */
    convenience init() {
        let context = AppDelegate.sharedInstance.managedObjectContext!
        let entity = NSEntityDescription.entityForName("Timer", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    /**
    Gets the media item
    
    :return: returns the media item or nil, if there is no item associated with the timer
    */
    func mediaItem() -> MPMediaItem? {
        if mediaItemPersistentID == nil {
            return nil
        }
        
        // query the media library
        let query = MPMediaQuery.songsQuery()
        let predicate = MPMediaPropertyPredicate(value: mediaItemPersistentID,
            forProperty: MPMediaItemPropertyPersistentID)
        query.addFilterPredicate(predicate)
        
        let item = query.items.first as? MPMediaItem
        return item
    }
    
    
    //start the timer
    func start() {
        println("timer start")
        if cellTimer != nil {
            return
        }
        
        if secondsRemaining == 0 {
            return
        }
        
        println("set resetButton.enabled = true")
        cell.resetButton.enabled = true
        cell.timeLabel.textColor = UIColor.greenColor()


        isActive = true
        startTime = NSDate()

        cellTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)

    }
    
    func updateTimer() {
        println("updateTimer(): secondsRemaining: \(secondsRemaining)")
        if secondsRemaining == 0 {
            
            if cellTimer != nil {
                cellTimer.invalidate()
                cellTimer = nil
            }
            
            isActive = false
            cell.switchControl.setIsOn(false, animated: false)
            // set color to tintColor (blue)
            cell.timeLabel.textColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)

            // [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]

            let notification = NSNotification(name: kTimerFiredNotification, object: self)
            NSNotificationCenter.defaultCenter().postNotification(notification)

        }
        else {
            secondsRemaining--
            var timeString = getTimeString(secondsRemaining)
            cell.timeLabel.text = timeString
            cell.timeLabel.textColor = UIColor.greenColor()
            cell.resetButton.enabled = true
            
//            println("timeString: \(timeString)")
        }
    }
    
    
    func getTotalSeconds() -> NSTimeInterval {
        return Double(self.hours*Int(3600)+self.minutes*Int(60)+self.seconds)
    }
    
    //stop the timer
    func stop() {
        println("stop()")
        isActive = false
        
        if cellTimer != nil {
            cellTimer.invalidate()
            cellTimer = nil
        }
        
        if localNotification != nil {
            // cancel LocalNotification
            UIApplication.sharedApplication().cancelLocalNotification(localNotification)
            localNotification = nil
            println("localNotification canceled")
        }
        
        cell.resetButton.enabled = true
        cell.switchControl.setIsOn(false, animated: false)
        cell.timeLabel.textColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)

    }
    
    
    //reset the timer
    func reset() {
        if isActive {
            stop()
        }
        
        if localNotification != nil {
            // cancel LocalNotification
            UIApplication.sharedApplication().cancelLocalNotification(localNotification)
            localNotification = nil
            println("localNotification canceled")
        }
        
        isActive = false
        self.secondsRemaining=(Double)(self.hours*3600+self.minutes*60+self.seconds)
        
        cell.resetButton.enabled = false
    }

  
    
    func timerFired(paramTimer: NSTimer) {
        println("timer fired!!")
        
        let notification = NSNotification(name: kTimerFiredNotification, object: self)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
}

