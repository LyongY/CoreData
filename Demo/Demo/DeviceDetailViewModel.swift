//
//  DeviceDetailViewModel.swift
//  Demo
//
//  Created by Raysharp666 on 2020/11/26.
//

import RxSwift
import RxCocoa

class DeviceDetailViewModel {
    var device: Device
    let saved: Driver<Bool>
    let saveEnable: Driver<Bool>
    init(device: Device,
         address: Driver<String>,
         port: Driver<String>,
         username: Driver<String>,
         password: Driver<String>,
         saveTap: Signal<Void>) {
        self.device = device
        
        let port = port.map{Int64($0) ?? 0}
        let info = Driver.combineLatest(address, port, username, password) {
            (address: $0, port: $1, username: $2, password: $3)
        }
        
        saved = saveTap.withLatestFrom(info).flatMapLatest({ (info) in
            Observable<Bool>.create { (observer) -> Disposable in
                Managers.device.add { () -> Device in
                    device.managed.address = info.address
                    device.managed.port = info.port
                    device.managed.username = info.username
                    device.managed.password = info.password
                    return device
                } completion: { (success) in
                    observer.onNext(success)
                }
                return Disposables.create()
            }.asDriver(onErrorJustReturn: false)
        })
        
        saveEnable = info.map({ (info) in
            info.address.count > 3 && info.port > 0 && info.username.count > 0 && info.password.count > 0
        })
    }
}
