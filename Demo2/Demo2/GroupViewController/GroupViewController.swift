//
//  GroupViewController.swift
//  Demo2
//
//  Created by Raysharp666 on 2020/12/15.
//

import UIKit

class GroupViewController: UIViewController {

    let tableView = UITableView(frame: .zero, style: .plain)
    let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    
//    lazy var viewModel: GroupViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bindViewModel()
    }
    
    func initUI() {
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = addBarButtonItem
        
        tableView.tableFooterView = .init()
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
        addBarButtonItem.rx.tap.subscribe(onNext: { [weak self] in
            let alert = UIAlertController(title: "添加组", message: nil, preferredStyle: .alert)
            
            alert.addTextField { $0.placeholder = "组名" }
            let textField = alert.textFields!.first!
            
            alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(.init(title: "OK", style: .destructive, handler: { (_) in
                let result = Manager<Group>.default.add { (group) in
                    group.name = textField.text
                }
                MessageBox.default.show(message: result ? "Success" : "Failed" )
            }))
            
            let action = alert.actions[1]
            textField.rx.text.orEmpty.map({ $0.count > 0 }).bind(to: action.rx.isEnabled).disposed(by: alert.rx.disposeBag)
            
            self?.present(alert, animated: true, completion: nil)
        }).disposed(by: rx.disposeBag)
        
        Manager<Group>.default.$objects.behaviorRelay.bind(to: tableView.rx.items(cellIdentifier: "cell")) {
            index, model, cell in
            cell.textLabel?.text = model.name
        }.disposed(by: rx.disposeBag)
        
        tableView.rx.modelDeleted(Group.self).map{
            Manager<Group>.default.delete(item: $0)
        }.map { $0 ? "Success" : "Failed"}
        .bind(to: MessageBox.default.rx.message)
        .disposed(by: rx.disposeBag)
    }
}
