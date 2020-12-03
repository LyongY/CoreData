//
//  PropertyWrapper+Manager.swift
//  Demo
//
//  Created by Raysharp666 on 2020/12/3.
//

import Foundation

import RxSwift
import RxCocoa

@propertyWrapper
class PropertyBehaviorRelay<Value> {
    private var value: Value
    let behaviorRelay: BehaviorRelay<Value>

    init(wrappedValue: Value) {
        value = wrappedValue
        behaviorRelay = BehaviorRelay(value: wrappedValue)
    }
    
    var wrappedValue: Value {
        get {
            value
        }
        set {
            value = newValue
            behaviorRelay.accept(newValue)
        }
    }
    
    var projectedValue: PropertyBehaviorRelay<Value> { return self }
}
