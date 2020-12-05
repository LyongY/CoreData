//
//  ManagedObject.swift
//  Demo
//
//  Created by LyongY on 2020/12/1.
//

import Foundation
import CoreData

class DBObject: NSManagedObject, Managed {
    @NSManaged var index: Int64 //添加时的顺序
    @NSManaged var uuid: String  //托管对象唯一标志
    var mamaged: AnyObject?
}
