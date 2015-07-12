//
//  WakeSpeaker.swift
//  HKTime
//
//  Created by TCSASSEMBLER on 12/31/14.
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import Foundation
import CoreData

@objc(WakeSpeaker)
class WakeSpeaker: NSManagedObject {

    @NSManaged var id: Int32
    @NSManaged var name: String
    @NSManaged var icon1Name: String
    @NSManaged var isActive: Bool
    @NSManaged var alarms: NSSet
    @NSManaged var room: WakeRoom
}
