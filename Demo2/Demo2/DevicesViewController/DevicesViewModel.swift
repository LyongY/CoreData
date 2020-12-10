//
//  RootViewModel.swift
//  Demo2
//
//  Created by Raysharp666 on 2020/12/10.
//

import Foundation
import CoreData

class DevicesViewModel {
    let dataSource = Manager<Device>.default.$objects.behaviorRelay
}
