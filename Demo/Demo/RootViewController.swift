//
//  RootViewController.swift
//  Demo
//
//  Created by Raysharp666 on 2020/11/25.
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
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionCustomData>.init { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = "\(item.addr)"
            cell.detailTextLabel?.text = "\(item.port)"
            return cell
        }
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            dataSource.sectionModels[index].headerr
        }
                
        let request = DBDevice.sortedFetchRequest
        request.fetchBatchSize = 20
        request.returnsObjectsAsFaults = false

//        let rrr = CoreDataStack.default.mainContext.rx.entities(fetchRequest: request)
//        rrr.bind(to: tableView.rx.items(cellIdentifier: "cell")) { index, model, cell in
//            cell.textLabel?.text = "\(model.address)"
//            cell.detailTextLabel?.text = "\(model.port)"
//        }.disposed(by: disposeBag)
        
//        更换为Manager<DBDevice, Device>
                                                              
//        rr = Managers.device.rx.observeWeakly([Device].self, "managedObjects").map { $0 ?? [] }
//
//        rr.subscribe { (obj) in
//            print(obj)
//        } onError: { (err) in
//            print(err)
//        } onCompleted: {
//            print("compleeted")
//        } onDisposed: {
//            print("disposed")
//        }.disposed(by: disposeBag)
        
        
//        let ee = Managers.device.rx.observeWeakly([Device].self, "uuuu").map { $0 ?? [] }
        
        Managers.device.$managedObjects.behaviorRelay.subscribe { (obj) in
            print(obj)
        } onError: { (err) in
            print(err)
        } onCompleted: {
            print("compleeted")
        } onDisposed: {
            print("disposed")
        }.disposed(by: disposeBag)


        
        Managers.device.$managedObjects.behaviorRelay.bind(to: tableView.rx.items(cellIdentifier: "cell")) { index, model, cell in
            cell.textLabel?.text = "\(model.managed.address)"
            cell.detailTextLabel?.text = "\(model.managed.port)"
        }.disposed(by: disposeBag)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            Managers.device.managedObjects[1].save { (managed) in
//                managed.address = "2222"
//            } completion: { (suu) in
//                print("eeeee \(suu)")
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
