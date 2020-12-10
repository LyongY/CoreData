//
//  DataBase.swift
//  Demo2
//
//  Created by Raysharp666 on 2020/12/9.
//

import Foundation
import CoreData

class DataBase {
    static let `default` = DataBase(name: "Demo2")
    
    private let container: NSPersistentContainer
    private init(name: String) {
        container = NSPersistentContainer(name: name)
    }
    func load(complete: @escaping (_ success: Bool) -> Void) {
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                print("loadPersistentStores Error", error)
                DispatchQueue.main.async {
                    complete(false)
                }
            } else {
                DispatchQueue.main.async {
                    complete(true)
                }
            }
        }
    }
    
    var viewContext: NSManagedObjectContext { container.viewContext }
    
    private var contextArray: [NSManagedObjectContext] = []
    func createNewContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = viewContext
        contextArray.append(context)
        return context
    }
    
    func removeContext(_ context: NSManagedObjectContext) {
        contextArray = contextArray.filter{ $0 != context }
    }
}
