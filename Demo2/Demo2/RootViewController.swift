//
//  RootViewController.swift
//  Demo2
//
//  Created by Raysharp666 on 2020/12/15.
//

import UIKit
import RxCocoa
import RxSwift
import NSObject_Rx

class RootViewController: UIViewController {
    
    enum DesType: String {
        case device = "Devices"
        case group = "Group"
    }
    
    let tableView = UITableView(frame: .zero, style: .plain)
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        bindViewModel()
    }
    
    func initUI() {
        view.backgroundColor = .white
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        view.addConstraints([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])
    }
    
    func bindViewModel() {
        Observable<[DesType]>.just([.device, .group]).bind(to: tableView.rx.items(cellIdentifier: "cell")) {
            index, model, cell in
            cell.textLabel?.text = model.rawValue
        }.disposed(by: rx.disposeBag)
        
        tableView.rx.modelSelected(DesType.self).subscribe(onNext: { [weak self] model in
            var vc: UIViewController? = nil
            if model == .device {
                vc = DevicesViewController.createFromStoryboard()
            } else {
                vc = GroupViewController()
            }
            self?.navigationController?.pushViewController(vc!, animated: true)
        }).disposed(by: rx.disposeBag)
    }
}
