//
//  Device+CoreDataProperties.swift
//  
//
//  Created by Raysharp666 on 2020/12/15.
//
//

import Foundation
import CoreData

extension Device {
    
    var channelArr: [Channel] {
        get {
            channels?.sortedArray(using: [.init(key: #keyPath(Channel.number), ascending: true)]) as? [Channel] ?? []
        }
        set {
            let newSet = NSOrderedSet(array: newValue)
            channels = newSet
        }
    }
}

extension Device {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device")
    }

    @NSManaged public var address: String?
    @NSManaged public var name: String?
    @NSManaged public var password: String?
    @NSManaged public var port: Int64
    @NSManaged public var uid: Int64
    @NSManaged public var username: String?
    @NSManaged private var channels: NSOrderedSet?

}
