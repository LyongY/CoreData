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
    
    @RxPropertyWrapper var device: Device?
    
    let saveEnabel: Driver<Bool>
    private(set) var saveTapped: Driver<Bool>!
    private(set) var updateTapped: Driver<Bool>!
    
    init(address: ControlProperty<String?>,
         port: ControlProperty<String?>,
         username: ControlProperty<String?>,
         password: ControlProperty<String?>,
         count: ControlProperty<String?>,
         update: ControlEvent<Void>,
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
        
        updateTapped = update.withLatestFrom(count.orEmpty.asDriver())
            .filter({ Int($0) != nil})
            .map({ Int($0)! })
            .flatMapLatest { (count) in
                Observable<Bool>.create { [weak self] (observer) -> Disposable in
                    guard let device = self?.device else {
                        observer.onCompleted()
                        return Disposables.create()
                    }
                    var result = false
                    let currentCount = device.channelArr.count
                    if count > currentCount {
                        result = Manager<Channel>.default.add(count: count - currentCount) { (index, channel) in
                            channel.number = Int64(currentCount + index)
                            channel.device = device
                        }
                    } else if count < currentCount {
                        let channels = device.channelArr.filter({ $0.number >= count })
                        result = Manager<Channel>.default.delete(items: channels)
                    } else {
                        result = true
                    }
                    observer.onNext(result)
                    return Disposables.create()
                }
            }
            .asDriver(onErrorJustReturn: false)
        
        
    }
}
