//
//  DemoTests.swift
//  DemoTests
//
//  Created by Raysharp666 on 2020/12/7.
//

import XCTest

@testable import Demo

class DemoTests: XCTestCase {

    override class func setUp() {
        // 新数据库
        let paths = ["\(NSHomeDirectory())/Library/Application Support/Demo.sqlite",
                     "\(NSHomeDirectory())/Library/Application Support/Demo.sqlite-shm",
                     "\(NSHomeDirectory())/Library/Application Support/Demo.sqlite-wal"]
        for item in paths {
            try! FileManager.default.removeItem(atPath: item)
        }
        
        // 加载数据库
        while !CoreDataStack.default.isready {
            usleep(100000) // 0.1秒
        }
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_add_a_device() {
        let promise = expectation(description: "add success")
        var addSuccess = false
        Managers.device.add { () -> Device in
            let device = Device()
            return device
        } completion: { (success) in
            addSuccess = success
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        XCTAssert(addSuccess, "添加不成功")
        XCTAssert(Managers.device.managedObjects.count == 1, "不止一个对象")
        XCTAssert(Manager<DBDevice, Device>.init(DBDevice.sortedFetchRequest).managedObjects[0].managed == Managers.device.managedObjects[0].managed)
        XCTAssert(Manager<DBDevice, Device>.init(DBDevice.sortedFetchRequest).managedObjects[0] == Managers.device.managedObjects[0])
    }
    
    func test_add_an_other_device() {
        let promise = expectation(description: "add success")
        var addSuccess = false
        let manager = Manager<DBDevice, Device>.init(DBDevice.sortedFetchRequest)
        manager.add { () -> Device in
            let device = Device()
            return device
        } completion: { (success) in
            addSuccess = success
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
        
        XCTAssert(addSuccess, "添加不成功")
        XCTAssert(Managers.device.managedObjects.count == 2, "没有成功添加两个Device")
        XCTAssert(Manager<DBDevice, Device>.init(DBDevice.sortedFetchRequest).managedObjects[0].managed == Managers.device.managedObjects[0].managed)
        XCTAssert(Manager<DBDevice, Device>.init(DBDevice.sortedFetchRequest).managedObjects[0] == Managers.device.managedObjects[0])
        XCTAssert(manager.managedObjects[0].managed == Managers.device.managedObjects[0].managed)
        XCTAssert(manager.managedObjects[0] == Managers.device.managedObjects[0])
    }
    
    func test_add_channels_with_second_device() {
        let device = Managers.device.managedObjects[1]
        device.updateChannelCountIfNeeded(with: 6)
        
        XCTAssert(device.channelManager.managedObjects.count == 6)
        XCTAssert(Managers.channel.managedObjects.count == 6)
    }
    
    func test_delete_channels_with_second_device() {
        let device = Managers.device.managedObjects[1]
        device.updateChannelCountIfNeeded(with: 4)

        XCTAssert(device.channelManager.managedObjects.count == 4)
        XCTAssert(Managers.channel.managedObjects.count == 4)
    }
}
