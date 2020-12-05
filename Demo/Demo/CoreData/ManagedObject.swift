//
//  ManagedObject.swift
//  Demo
//
//  Created by LyongY on 2020/12/1.
//

import Foundation
import CoreData

class ManagedObject<DBObjectType: DBObject>: NSObject {
    lazy var managed: DBObjectType = newEntity
    private var _context: NSManagedObjectContext?
    var context: NSManagedObjectContext? {
        get {
            _context ?? CoreDataStack.default.mainContext
        }
        set {
            _context = newValue
        }
    }
    override required init() {
        super.init()
        managed = newEntity
    }
}

extension ManagedObject where DBObjectType: Managed {
        
    var newEntity: DBObjectType {
        let subContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        subContext.parent = CoreDataStack.default.mainContext
        context = subContext
        let entity = subContext.insertObject() as DBObjectType
        entity.mamaged = self
        return entity
    }
            
    // 保存更改
    func save(changes: @escaping (_ managed: DBObjectType) -> Void, completion: @escaping (_ success: Bool) -> Void) {
        let manager = Manager<DBObjectType, Self>.default
        guard manager.managedObjects.contains(self as! Self) || manager.handleObjects.contains(self as! Self) else {
            completion(false)
            return
        }
        if context != CoreDataStack.default.mainContext {
            let center = NotificationCenter.default
            var token: NSObjectProtocol?
            token = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: context, queue: nil) { (noti) in
                center.removeObserver(token!)
                CoreDataStack.default.mainContext.mergeChanges(fromContextDidSave: noti)
                CoreDataStack.default.mainContext.perform {
                    let tempEntity = CoreDataStack.default.mainContext.object(with: self.managed.objectID) as! DBObjectType
                    do {
                        try CoreDataStack.default.mainContext.save()
                        self.managed = tempEntity
                        self.context = CoreDataStack.default.mainContext
                        completion(true)
                    } catch {
                        completion(false)
                    }
                }
            }
            context!.performChanges {
                changes(self.managed)
            } completion: { (success) in
                if !success {
                    completion(false)
                }
            }
        } else {
            context!.performChanges {
                changes(self.managed)
            } completion: { (success) in
                completion(success)
            }
        }
    }
}
