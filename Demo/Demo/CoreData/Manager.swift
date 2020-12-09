//
//  Manager.swift
//  Demo
//
//  Created by LyongY on 2020/12/2.
//

import Foundation
import CoreData
import Combine

fileprivate var uuidString = UUID().uuidString
fileprivate func uniqueUUID() -> String {
    guard Thread.current.isMainThread else {
        fatalError("必须在主线程取uuid")
    }
    var uuid = UUID().uuidString
    while uuid == uuidString {
        uuid = UUID().uuidString
    }
    uuidString = uuid
    return uuidString
}

fileprivate var singletonsStore : [String: AnyObject] = [:]
class Manager<U: DBObject, T: ManagedObject<U>>:NSObject, NSFetchedResultsControllerDelegate {
    static var `default`: Manager<U, T> {
        NSLock().lock()
        let key = String(describing: T.self)
        if let singleton = singletonsStore[key] {
            return singleton as! Manager<U, T>
        } else {
            let singleton = Manager<U, T>()
            singletonsStore[key] = singleton
            return singleton
        }
    }
    
    @PropertyBehaviorRelay var managedObjects: [T]
    private(set) var handleObjects: [T] = [] // 当前正在处理的
    func add(_ itemBlock: @escaping () -> T, completion: @escaping (_ success: Bool) -> Void) {
        let manager = Manager<U, T>.default // 所有托管对象从默认Manager中添加, 以防止多manager时index对不上
        manager.frc.managedObjectContext.perform {
            let item = itemBlock()
            // 已存在实体, add失败
            guard !manager.managedObjects.map({ $0.managed }).contains(item.managed) else {
                completion(false)
                return
            }
            
            // 托管对象唯一标志
            let uuid = uniqueUUID()
            item.managed.uuid = uuid
            
            // 添加index
            // handleObjects里有就从handleObjects里取, 否则从managedObjects中取
            let startIndex: Int64 = self.lastIndex() + 1
            item.managed.index = startIndex
            
            manager.handleObjects.append(item)
            
            item.save { (item) in
                
            } completion: { (success) in
                manager.handleObjects = manager.handleObjects.filter{ $0 != item }
                completion(success)
            }
        }
    }
    
    func add(count: Int, itemsBlock: ([U]) -> Void) -> Bool {
        guard Thread.current.isMainThread else {
            fatalError("要在主线程")
        }
        var array: [U] = []
        
        let startIndex: Int64 = self.lastIndex() + 1
        for index in 0..<Int64(count) {
            let managed: U = CoreDataStack.default.mainContext.insertObject()
            managed.index = startIndex + index
            managed.uuid = uniqueUUID()
            array.append(managed)
        }
        itemsBlock(array)
        
        let manager = Manager<U, T>.default
        manager.handleObjects.append(contentsOf: array.map {
            let managedObj = T()
            managedObj.context = CoreDataStack.default.mainContext
            managedObj.managed = $0
            return managedObj
        })
        let result = CoreDataStack.default.mainContext.saveOrRollback()
        // 消除 handleObjects 中已添加的对象
        manager.handleObjects = manager.handleObjects.filter {
            !manager.managedObjects.contains($0)
        }
        return result
    }
    
    func lastIndex() -> Int64 {
        let manager = Manager<U, T>.default // 所有托管对象从默认Manager中添加, 以防止多manager时index对不上
        var lastIndex: Int64 = 1
        if manager.handleObjects.last != nil {
            lastIndex = manager.handleObjects.last!.managed.index
        } else {
            lastIndex = (manager.managedObjects.last?.managed.index ?? 0)
        }
        return lastIndex
    }
    
    func delete(_ item: T, completion: @escaping (_ success: Bool) -> Void) {
        let manager = Manager<U, T>.default // 所有托管对象从默认Manager中移除
        guard manager.managedObjects.map({ $0.managed }).contains(item.managed) else { // 不存在直接回成功
            completion(true)
            return
        }
        // item已在managedObjects中, 表明item的实体在主上下文中
        CoreDataStack.default.mainContext.performChanges(block: {
            CoreDataStack.default.mainContext.delete(item.managed)
        }) { (success) in
            completion(true)
        }
    }
    
    func delete(_ items: [T]) -> Bool {
        guard Thread.current.isMainThread else {
            fatalError("不是主线程")
        }
        for item in items {
            CoreDataStack.default.mainContext.delete(item.managed)
        }
        let result = CoreDataStack.default.mainContext.saveOrRollback()
        return result
    }
    
    // MARK: - FetchedResultsController
    private let frc: NSFetchedResultsController<U>
    private override init() {
        frc = NSFetchedResultsController(fetchRequest: U.sortedFetchRequest,
                                         managedObjectContext: CoreDataStack.default.mainContext,
                                         sectionNameKeyPath: nil, cacheName: nil)
        do {
            try frc.performFetch()
            managedObjects = (frc.fetchedObjects ?? []).map { (dbObj) in
                let managedObj = T()
                managedObj.context = CoreDataStack.default.mainContext
                managedObj.managed = dbObj
                return managedObj
            }
        } catch {
            managedObjects = []
            fatalError("\(error)")
        }
        super.init()
        frc.delegate = self
    }
    
    init(_ fetchRequest: NSFetchRequest<U>) {
        let manager = Manager<U, T>.default
        frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                         managedObjectContext: CoreDataStack.default.mainContext,
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
        do {
            try frc.performFetch()
            managedObjects = (frc.fetchedObjects ?? []).map { (dbObj) in
                let managedObj = manager.managedObjects.filter{ $0.managed == dbObj }.first!
                return managedObj
            }
        } catch {
            managedObjects = []
            fatalError("\(error)")
        }
        super.init()
        frc.delegate = self        
    }
    
    internal func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let manager = Manager<U, T>.default
        if self == manager {
            // 处理默认Manager
            let new = (manager.frc.fetchedObjects ?? []).map { (managed) -> T in
                // 包含了返回已创建的对象, 未包含则从handleObjects中取, 取不到则创建新的
                if manager.managedObjects.map({ $0.managed }).contains(managed) {
                    return manager.managedObjects.filter({ $0.managed == managed}).first!
                } else {
                    let managedObj = manager.handleObjects.filter({ $0.managed == managed }).first ?? T()
                    managedObj.context = CoreDataStack.default.mainContext
                    managedObj.managed = managed
                    return managedObj
                }
            }
            manager.managedObjects = new
        } else {
            // 从默认manager中取
            let new = (frc.fetchedObjects ?? []).map { (dbObj) -> T in
                manager.managedObjects.filter{ $0.managed == dbObj }.first!
            }
            self.managedObjects = new
        }
    }
}
