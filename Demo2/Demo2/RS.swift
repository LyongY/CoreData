//
//  RS.swift
//  Demo2
//
//  Created by Raysharp666 on 2020/12/12.
//

import Foundation

struct RS<Base> {
    let base: Base
}

protocol RSCompatible {
    associatedtype RSBase
    var rs: RS<RSBase> { get }
}

extension RSCompatible {
    var rs: RS<Self> {
        RS(base: self)
    }
}

import class Foundation.NSObject
extension NSObject: RSCompatible {  }



