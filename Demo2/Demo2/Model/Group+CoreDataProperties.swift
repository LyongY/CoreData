//
//  Group+CoreDataProperties.swift
//  
//
//  Created by Raysharp666 on 2020/12/15.
//
//

import Foundation
import CoreData

extension Group {
    
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

extension Group {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Group> {
        return NSFetchRequest<Group>(entityName: "Group")
    }

    @NSManaged public var uid: Int64
    @NSManaged public var name: String?
    @NSManaged public var channels: NSOrderedSet?

}
