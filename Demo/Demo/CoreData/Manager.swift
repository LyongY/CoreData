//
//  Manager.swift
//  Demo
//
//  Created by Raysharp666 on 2020/12/2.
//

import Foundation
import CoreData

fileprivate var singletonsStore : [String: AnyObject] = [:]

class Manager<T: ManagedObject> {
    static var `default`: Manager<T> {
        NSLock().lock()
        let key = String(describing: T.self)
        if let singleton = singletonsStore[key] {
            return singleton as! Manager<T>
        } else {
            let singleton = Manager<T>()
            singletonsStore[key] = singleton
            return singleton
        }
    }
    
    var managedObjects: [T]
    
    private let frc: NSFetchedResultsController<T.DBObjectType>
    private init() {
        frc = NSFetchedResultsController(fetchRequest: T.DBObjectType.sortedFetchRequest,
                                         managedObjectContext: CoreDataStack.default.mainContext,
                                         sectionNameKeyPath: nil, cacheName: nil)
        do {
            try frc.performFetch()
            (frc.fetchedObjects ?? []).map { (dbObj) in
                
            }
            
            var tempDbObj = managedObjects.map { (managedObj) in
                managedObj.managed
            }
            
//            managedObjects = frc.fetchedObjects.map({ (dbObj) in
//                db
//            })
        } catch {
            
        }
    }
}
