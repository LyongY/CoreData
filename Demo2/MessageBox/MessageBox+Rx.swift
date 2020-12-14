//
//  MessageBox+Rx.swift
//  Demo2
//
//  Created by Raysharp666 on 2020/12/12.
//

import Foundation
import RxCocoa
import RxSwift

extension Reactive where Base: MessageBox {
    var message: Binder<String> {
        Binder(base) { (messageBox, message) in
            base.show(message: message)
        }
    }
}
