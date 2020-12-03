//
//  Manager.swift
//  Demo
//
//  Created by Raysharp666 on 2020/12/2.
//

import Foundation
import CoreData
import Combine

class Managers {
    static let device: Manager<DBDevice, Device> = Manager.default
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
    var handleObjects: [T] = [] // 当前正在处理的
    func add(_ itemBlock: @escaping () -> T, completion: @escaping (_ success: Bool) -> Void) {
        uid还需要处理
        frc.managedObjectContext.perform {
            let item = itemBlock()
            self.handleObjects.append(item)
            item.save { (item) in
                
            } completion: { (success) in
                self.handleObjects = self.handleObjects.filter{ $0 != item }
                if success {
                    self.managedObjects.append(item)
                }
                completion(success)
            }
        }
    }
    
    
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
        }
        super.init()
        frc.delegate = self
    }
    
    internal func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let new = self.managedObjects.filter{
            (self.frc.fetchedObjects ?? []).contains($0.managed)
        }
        self.managedObjects = new
    }
}
