//
//  CoreDataStack.swift
//  Demo
//
//  Created by Raysharp666 on 2020/11/25.
//

import Foundation
import CoreData

class CoreDataStack {
    static let `default` = CoreDataStack()
    private init() {
        container = NSPersistentContainer(name: "Demo")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            DispatchQueue.main.async {
                self.isready = true
            }
        }
    }
    
    private let container: NSPersistentContainer
    var mainContext: NSManagedObjectContext { container.viewContext }
        
    
    var isready = false

}
