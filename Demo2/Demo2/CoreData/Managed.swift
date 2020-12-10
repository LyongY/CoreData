//
//  Managed.swift
//  Demo2
//
//  Created by Raysharp666 on 2020/12/10.
//

import CoreData

extension NSManagedObject: Managed {
    
}

protocol Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}

extension Managed where Self: NSManagedObject {
    static var entityName: String { Self.entity().name! }

    static var defaultSortDescriptors: [NSSortDescriptor] {
        []
    }
    
    static var defaultFetchRequest: NSFetchRequest<Self> {
        let req = NSFetchRequest<Self>(entityName: self.entityName)
        req.sortDescriptors = defaultSortDescriptors
        return req
    }
    
    static func insertFromMain() -> Self {
        NSEntityDescription.insertNewObject(forEntityName: entityName, into: DataBase.default.viewContext) as! Self
    }
}
