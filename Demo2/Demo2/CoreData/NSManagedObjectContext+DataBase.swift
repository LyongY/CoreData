//
//  NSManagedContext+DataBase.swift
//  Demo2
//
//  Created by Raysharp666 on 2020/12/12.
//

import CoreData

extension RS where Base: NSManagedObjectContext {
    func saveOrRollback() -> Bool {
        do {
            try base.save()
            return true
        } catch {
            base.rollback()
            return false
        }
    }
}
