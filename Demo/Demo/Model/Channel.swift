//
//  Channel.swift
//  Demo
//
//  Created by LyongY on 2020/12/5.
//

import Foundation

final class DBChannel: DBObject {
    @NSManaged var deviceUUID: String
    @NSManaged var name: String
    @NSManaged var number: Int64
}

extension DBChannel {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(number), ascending: true)]
    }
}

class Channel: ManagedObject<DBChannel> {
    
}
