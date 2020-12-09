//
//  Managers.swift
//  Demo
//
//  Created by LyongY on 2020/12/5.
//

import Foundation

class Managers {
    static let device: Manager<DBDevice, Device> = Manager.default
    static let channel: Manager<DBChannel, Channel> = Manager.default
    static func channelManager(_ device: Device) -> Manager<DBChannel, Channel> {
        let fetchReq = DBChannel.sortedFetchRequest
        fetchReq.predicate = NSPredicate(format: "%K == %@", #keyPath(DBChannel.deviceUUID), device.managed.uuid)
        return .init(fetchReq)
    }
}
