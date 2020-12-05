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
            var index: Int64 = 1
            
            if manager.handleObjects.last != nil {
                index = manager.handleObjects.last!.managed.index + 1
            } else {
                index = (manager.managedObjects.last?.managed.index ?? 0) + 1
            }
            item.managed.index = index
            
            manager.handleObjects.append(item)
            
            item.save { (item) in
                
            } completion: { (success) in
                manager.handleObjects = manager.handleObjects.filter{ $0 != item }
                completion(success)
            }
        }
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
        frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                         managedObjectContext: CoreDataStack.default.mainContext,
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
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
    
    internal func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let new = (self.frc.fetchedObjects ?? []).map { (managed) -> T in
            // 包含了返回已创建的对象, 未包含则从handleObjects中取, 取不到则创建新的
            if self.managedObjects.map({ $0.managed }).contains(managed) {
                return self.managedObjects.filter({ $0.managed == managed}).first!
            } else {
                let managedObj = self.handleObjects.filter({ $0.managed == managed }).first ?? T()
                managedObj.context = CoreDataStack.default.mainContext
                managedObj.managed = managed
                return managedObj
            }
        }
        self.managedObjects = new
    }
}
