//
//  TmpTimer.swift
//  HKTime
//
//  Created by Alexander Volkov on 06.01.15.
//  Updated by Fabrizio Lovato - fabrizyo on 02/20/2015
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import Foundation
import MediaPlayer

// Temporary object for editing Timer
class TmpTimer {
    
    var hours: Int
    var minutes: Int
    var seconds: Int

    
    var mediaItemPersistentID: String?
    
    // This is array of DeviceInfo
    var speakers: [CLongLong]
    
    var speakerListStr: String!
    

    //truet if the timer is active
    var isActive: Bool
    //the date of activation of timer
    var startTime: NSDate?
    //the seconds that remain when the timer is not active (stopped)
    var secondsRemaining:NSTimeInterval

   
    
    init() {
        self.hours = 0
        self.mediaItemPersistentID = nil
        self.minutes = 0
        self.seconds = 0

        self.isActive = false
        self.secondsRemaining=0
        
        self.speakers = [CLongLong]()
        self.speakerListStr = ""
    }
    
    init(_ dirtyTimer: Timer) {
      
        self.hours = dirtyTimer.hours
        self.mediaItemPersistentID = dirtyTimer.mediaItemPersistentID
        self.minutes = dirtyTimer.minutes
        self.seconds = dirtyTimer.seconds

        self.isActive = dirtyTimer.isActive
        self.speakers = dirtyTimer.speakers
        self.startTime=dirtyTimer.startTime
        self.secondsRemaining=dirtyTimer.secondsRemaining
        
        self.speakerListStr = dirtyTimer.speakerListStr
    }
    
    func getSpeakers() -> [CLongLong] {
        
        return speakers
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

    func addSpeaker(deviceId: CLongLong) {
        // check if the deviceId already exist
        for speaker in speakers {
            if speaker == deviceId {
                // the deviceId already included
                return
            }
        }
        
        // the deviceId is not included in the speaker list, so we add it
        speakers.append(deviceId)
        var idStr = String(format: "%lld", deviceId)
        speakerListStr = speakerListStr + ",\(idStr)"
    }
    
    func removeSpeaker(deviceId: CLongLong) {
        var removed = false
        for var i = 0; i < speakers.count; i++ {
            if speakers[i] == deviceId {
                speakers.removeAtIndex(i)
                removed = true
                break
            }
        }
        
        if removed {
            // reconstruct string
            speakerListStr = constructSpeakerListString(speakers)
        }
    }
    
    func getTotalSeconds() -> NSTimeInterval {
        return Double(self.hours*Int(3600)+self.minutes*Int(60)+self.seconds)
    }
}