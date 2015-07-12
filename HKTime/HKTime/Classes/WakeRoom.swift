//
//  Room.swift
//  HKTime
//
//  Created by TCSASSEMBLER on 12/31/14.
//  Updated by Seonman Kim - 2/28/2015
//  Copyright (c) 2015 Harman International. All rights reserved.
//

import Foundation
import CoreData

@objc(WakeRoom)
class WakeRoom: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var speakers: NSSet

}
