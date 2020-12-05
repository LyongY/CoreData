//
//  Device.swift
//  Demo
//
//  Created by LyongY on 2020/11/25.
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
    lazy var channelManager = Managers.channelManager(self)
    
    func addChannel() {
        for index in Int64(0)..<7 {
            Managers.channel.add { () -> Channel in
                let channel = Channel()
                channel.managed.name = "Channel \(index + 1)"
                channel.managed.number = index
                channel.managed.deviceUUID = self.managed.uuid
                return channel
            } completion: { (succe) in
                print("add channel \(index), \(succe)")
            }

        }
    }
}
