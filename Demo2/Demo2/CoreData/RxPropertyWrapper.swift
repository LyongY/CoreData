//
//  RxPropertyWrapper.swift
//  Demo2
//
//  Created by Raysharp666 on 2020/12/10.
//

import Foundation
import RxSwift
import RxCocoa

@propertyWrapper
class RxPropertyWrapper<Value> {
    private var value: Value
    let behaviorRelay: BehaviorRelay<Value>
    var wrappedValue: Value {
        get {
            value
        }
        set {
            value = newValue
            behaviorRelay.accept(newValue)
        }
    }
    
    init(wrappedValue: Value) {
        value = wrappedValue
        behaviorRelay = BehaviorRelay(value: wrappedValue)
    }
    
    var projectedValue: RxPropertyWrapper<Value> { self }
}
