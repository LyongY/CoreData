//
//  RootViewController.swift
//  Demo
//
//  Created by LyongY on 2020/11/25.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa
import RxDataSources
import RxCoreData

class RootViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    let addBarbutton = UIBarButtonItem(image: UIImage(systemName: "plus.circle"), style: .done, target: nil, action: nil)
    let tableView = UITableView(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bindViewModel()
    }
        
    func bindViewModel() {
        addBarbutton.rx.tap.subscribe { (_) in
            let vc = DeviceDetailViewController { (vc) -> DeviceDetailViewModel in
                DeviceDetailViewModel(device: Device(),
                                               address: vc.addressTextField.rx.text.orEmpty.asDriver(),
                                               port: vc.portTextField.rx.text.orEmpty.asDriver(),
                                               username: vc.usernameTextField.rx.text.orEmpty.asDriver(),
                                               password: vc.passwordTextField.rx.text.orEmpty.asDriver(),
                                               saveTap: vc.saveBarButton.rx.tap.asSignal())
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }
    
    func initUI() {
        navigationItem.rightBarButtonItem = addBarbutton
        
        setupTableView()
        
        
        

    }

    func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addConstraints([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])
        
        Managers.device.$managedObjects.behaviorRelay.bind(to: tableView.rx.items(cellIdentifier: "cell")) { index, model, cell in
            cell.textLabel?.text = "\(model.managed.address)"
            cell.detailTextLabel?.text = "\(model.managed.port)"
        }.disposed(by: disposeBag)
        
//        let device = Managers.device.managedObjects[0]
//        device.channelManager.$managedObjects.behaviorRelay.throttle(.seconds(1), scheduler: MainScheduler()).subscribe { (obj) in
//            print(obj)
//        } onError: { (err) in
//            print(err)
//        } onCompleted: {
//            print("compleeted")
//        } onDisposed: {
//            print("disposed")
//        }.disposed(by: disposeBag)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            device.addChannel()
//        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            Managers.device.add { () -> Device in
//                let device = Device()
//                device.managed.address = "12345"
//                device.managed.port = 33333
//                device.managed.username = "3333"
//                device.managed.password = "333"
//                return device
//            } completion: { (suc) in
//                print(suc)
//            }
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            Managers.device.managedObjects[1].save { (managed) in
//                managed.address = "2222"
//            } completion: { (suu) in
//                print("eeeee \(suu)")
//            }
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            let device = Managers.device.managedObjects[1]
//            Managers.device.delete(device) { (suc) in
//                print(suc)
//            }
//        }
    }
    
    var rr: Observable<[Device]>!
}

struct CustomData {
    var addr: String
    var port: Int64
    var username: String
    var password: String
}

struct SectionCustomData: SectionModelType {
    typealias Item = CustomData
    var headerr: String
    var items: [Item]
    
    init(original: SectionCustomData, items: [CustomData]) {
        self = original
        self.items = items
    }
}
