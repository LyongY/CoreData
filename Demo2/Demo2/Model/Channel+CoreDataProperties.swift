//
//  Channel+CoreDataProperties.swift
//  
//
//  Created by Raysharp666 on 2020/12/15.
//
//

import Foundation
import CoreData


extension Channel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Channel> {
        return NSFetchRequest<Channel>(entityName: "Channel")
    }

    @NSManaged public var number: Int64
    @NSManaged public var uid: Int64
    @NSManaged public var device: Device?
    @NSManaged public var group: NSSet?

}

// MARK: Generated accessors for group
extension Channel {

    @objc(addGroupObject:)
    @NSManaged public func addToGroup(_ value: Group)

    @objc(removeGroupObject:)
    @NSManaged public func removeFromGroup(_ value: Group)

    @objc(addGroup:)
    @NSManaged public func addToGroup(_ values: NSSet)

    @objc(removeGroup:)
    @NSManaged public func removeFromGroup(_ values: NSSet)

}
