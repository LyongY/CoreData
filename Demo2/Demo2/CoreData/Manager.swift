//
//  Manager.swift
//  Demo2
//
//  Created by Raysharp666 on 2020/12/10.
//

import Foundation
import CoreData

fileprivate var managerStore: [String: Any] = [:]
class Manager<T: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
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
    
    @RxPropertyWrapper var objects: [T] = []
    private let frc: NSFetchedResultsController<T>
    private override init() {        
        frc = NSFetchedResultsController(fetchRequest: T.defaultFetchRequest,
                                         managedObjectContext: DataBase.default.viewContext,
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
        super.init()

        frc.delegate = self
        do {
            try frc.performFetch()
        } catch {
            fatalError("frc.performFetch() Fail")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objects = (controller.fetchedObjects as? [T]) ?? []
    }
}
