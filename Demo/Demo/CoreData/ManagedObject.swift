//
//  ManagedObject.swift
//  Demo
//
//  Created by Raysharp666 on 2020/12/1.
//

import Foundation
import CoreData

protocol ManagedObject: class {
    associatedtype DBObjectType: DBObject
    var managed: DBObjectType { get set }
    var context: NSManagedObjectContext! { get set }
}

extension ManagedObject where DBObjectType: Managed {
        
    var newEntity: DBObjectType {
        let subContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        subContext.parent = CoreDataStack.default.mainContext
        context = subContext
        return subContext.insertObject()
    }
    
    var context: NSManagedObjectContext {
        managed.managedObjectContext ?? CoreDataStack.default.mainContext
    }
        
    // 保存更改
    func save(changes: @escaping (_ managed: DBObjectType) -> Void, completion: @escaping (_ success: Bool) -> Void) {
        if context != CoreDataStack.default.mainContext {
            let center = NotificationCenter.default
            var token: NSObjectProtocol?
            token = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: context, queue: nil) { (noti) in
                center.removeObserver(token!)
                CoreDataStack.default.mainContext .mergeChanges(fromContextDidSave: noti)
                CoreDataStack.default.mainContext.perform {
                    let tempEntity = CoreDataStack.default.mainContext.object(with: self.managed.objectID) as! Self.DBObjectType
                    do {
                        if self.managed.uid == 0 {
                            let count = try self.context.count(for: DBObjectType.sortedFetchRequest) + 1
                            tempEntity.uid = Int64(count)
                        }
                        try CoreDataStack.default.mainContext.save()
                        self.managed = tempEntity
                        self.context = CoreDataStack.default.mainContext
                        completion(true)
                    } catch {
                        completion(false)
                    }
                }
            }
            context.performChanges {
                changes(self.managed)
            } completion: { (success) in
                if !success {
                    completion(false)
                }
            }
        } else {
            context.perform {
                do {
                    let count = try self.context.count(for: DBObjectType.sortedFetchRequest) + 1
                    self.context.performChanges {
                        if self.managed.uid == 0 {
                            self.managed.uid = Int64(count)
                        }
                        changes(self.managed)
                    } completion: { (success) in
                        completion(success)
                    }
                } catch {
                    completion(false)
                }
            }
        }
    }
}
