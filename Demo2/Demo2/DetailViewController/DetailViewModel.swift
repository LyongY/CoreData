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
    private(set) var saveTapped: Driver<Bool>!
    
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
                
        saveEnabel = Driver.combineLatest(validInfo, saving.asDriver()).map { $0 && !$1 }
        
        saveTapped = save.withLatestFrom(info).flatMapLatest { (info) in
            Observable<Bool>.create { (observer) -> Disposable in
                saving.accept(true)
                
                let device = self.device ?? Device.insertFromMain()
                device.address = info.address
                device.port = info.port
                device.username = info.username
                device.password = info.password
                
                var result = false
                if let device = self.device {
                    device.address = info.address
                    device.port = info.port
                    device.username = info.username
                    device.password = info.password
                    result = DataBase.default.viewContext.rs.saveOrRollback()
                } else {
                    result = Manager<Device>.default.add { (device) in
                        device.address = info.address
                        device.port = info.port
                        device.username = info.username
                        device.password = info.password
                    }
                }
                
                saving.accept(false)
                observer.onNext(result)

                return Disposables.create()
            }
        }.asDriver(onErrorJustReturn: false)
    }
}
