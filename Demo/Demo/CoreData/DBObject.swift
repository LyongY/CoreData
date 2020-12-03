//
//  ManagedObject.swift
//  Demo
//
//  Created by Raysharp666 on 2020/12/1.
//

import Foundation
import CoreData

class DBObject: NSManagedObject, Managed {
    @NSManaged var uid: Int64
    var mamaged: AnyObject?
}
