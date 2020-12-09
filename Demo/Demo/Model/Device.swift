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
    
    func updateChannelCountIfNeeded(with channelCount: Int) {
        let currentCount = self.channelManager.managedObjects.count
        if channelCount > currentCount {
            // 增加
            let need = channelCount - currentCount
            let success = Managers.channel.add(count: need) { (items) in
                for (index, item) in items.enumerated() {
                    item.name = "Channel \(index + currentCount + 1)"
                    item.index = Int64(index + currentCount)
                    item.deviceUUID = self.managed.uuid
                }
            }
            guard success else {
                fatalError("添加通道失败")
            }
        } else if channelCount < currentCount {
            // 删除
            let arr = Array(channelManager.managedObjects.suffix(from: channelCount))
            let success = Managers.channel.delete(arr)
            guard success else {
                fatalError("删除通道失败")
            }
        }
    }
}
