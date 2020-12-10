//
//  DetailViewModel.swift
//  Demo2
//
//  Created by Raysharp666 on 2020/12/10.
//

import Foundation
import RxSwift
import RxCocoa

class DetailViewModel {
    
    var device: Device?
    
    let saveEnabel: Driver<Bool>
    let saveTapped: Driver<Bool>
    
    init(address: ControlProperty<String?>,
         port: ControlProperty<String?>,
         username: ControlProperty<String?>,
         password: ControlProperty<String?>,
         save: ControlEvent<Void>) {

        let info = Driver.combineLatest(address.orEmpty.asDriver(),
                                        port.orEmpty.asDriver(),
                                        username.orEmpty.asDriver(),
                                        password.orEmpty.asDriver()) {
            (address: $0, port: Int64($1) ?? 0, username: $2, password: $3)
        }
        
        let validInfo = info.map({ (info) in
            info.address.count >= 3 &&
                info.port > 0 &&
                info.username.count > 0 &&
                info.password.count > 0
        }).asDriver(onErrorJustReturn: false)
        
        let saving = BehaviorRelay(value: false)
        
        saveTapped = save.withLatestFrom(info).flatMapLatest { (info) in
            Observable<Bool>.create { (observer) -> Disposable in
                saving.accept(true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    saving.accept(false)
                    observer.onNext(true)
                }
                return Disposables.create()
            }
        }.asDriver(onErrorJustReturn: false)
        
        saveEnabel = Driver.combineLatest(validInfo, saving.asDriver()).map { $0 && !$1 }
    }
}
