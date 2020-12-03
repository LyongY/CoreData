//
//  Device.swift
//  Demo
//
//  Created by Raysharp666 on 2020/11/25.
//

import Foundation
import CoreData

final class DBDevice: DBObject {
    @NSManaged var address: String
    @NSManaged var port: Int64
    @NSManaged var username: String
    @NSManaged var password: String
}

class Device: ManagedObject<DBDevice> {

}
