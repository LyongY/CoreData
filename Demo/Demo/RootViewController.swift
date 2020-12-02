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
        
        Observable<Int>.create { (_) -> Disposable in
            Disposables.create()
        }
        
        let request = DBDevice.sortedFetchRequest
        request.fetchBatchSize = 20
        request.returnsObjectsAsFaults = false

        let rrr = CoreDataStack.default.mainContext.rx.entities(fetchRequest: request)
        rrr.bind(to: tableView.rx.items(cellIdentifier: "cell")) { index, model, cell in
            cell.textLabel?.text = "\(model.address)"
            cell.detailTextLabel?.text = "\(model.port)"
        }.disposed(by: disposeBag)
    }
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
