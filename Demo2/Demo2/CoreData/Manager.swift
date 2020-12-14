//
//  Manager.swift
//  Demo2
//
//  Created by Raysharp666 on 2020/12/10.
//

import Foundation
import CoreData

fileprivate var managerStore: [String: Any] = [:]
class Manager<T: NSManagedObject & DataBaseObject>: NSObject, NSFetchedResultsControllerDelegate {
    @RxPropertyWrapper var objects: [T] = []
    private let frc: NSFetchedResultsController<T>
    private override init() {
        let request: NSFetchRequest<T> = NSFetchRequest(entityName: T.entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "uid", ascending: true)]
        frc = NSFetchedResultsController(fetchRequest: request,
                                         managedObjectContext: DataBase.default.viewContext,
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
        super.init()

        frc.delegate = self
        do {
            try frc.performFetch()
            objects = frc.fetchedObjects ?? []
        } catch {
            fatalError("frc.performFetch() Fail")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objects = (controller.fetchedObjects as? [T]) ?? []
    }
}

extension Manager {
    static var `default`: Manager<T> {
        NSLock().lock()
        let key = String(describing: T.self)
        if let manager = managerStore[key] {
            return manager as! Manager<T>
        } else {
            let manager = Manager()
            managerStore[key] = manager
            return manager
        }
    }

    func lastObjectValue<Value>(for key: String) -> Value? {
        objects.last?.value(forKey: key) as? Value
    }
    
    func add(item: (_ item: T) -> Void) -> Bool {
        let uid = (Manager<T>.default.objects.last?.uid ?? 0) + 1
        var entity = NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: frc.managedObjectContext) as! T
        entity.uid = uid
        item(entity)
        return frc.managedObjectContext.rs.saveOrRollback()
    }
    
    func add(count: Int, itemBlock: (_ index: Int, _ item: T) -> Void) -> Bool {
        let uid = (Manager<T>.default.objects.last?.uid ?? 0) + 1
        for index in 0..<count {
            var entity = NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: frc.managedObjectContext) as! T
            entity.uid = uid + Int64(index)
            itemBlock(index, entity)
        }
        return frc.managedObjectContext.rs.saveOrRollback()
    }
    
    func delete(item: T) -> Bool {
        frc.managedObjectContext.delete(item)
        return frc.managedObjectContext.rs.saveOrRollback()
    }
    
    func delete(items: [T]) -> Bool {
        items.forEach {
            frc.managedObjectContext.delete($0)
        }
        return frc.managedObjectContext.rs.saveOrRollback()
    }
}
