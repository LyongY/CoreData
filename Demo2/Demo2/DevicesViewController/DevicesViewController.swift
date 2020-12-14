//
//  RootViewController.swift
//  Demo2
//
//  Created by Raysharp666 on 2020/12/9.
//

import UIKit
import RxCocoa
import NSObject_Rx

class DevicesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let addBarbutton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: nil, action: nil)
    
    lazy var viewModel: DevicesViewModel = DevicesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bindViewModel()
    }
    
    func initUI() {
        title = "Devices"
        setupNavigation()
        setupTableView()
    }
    
    func setupNavigation() {
        navigationItem.rightBarButtonItem = addBarbutton
    }
    
    func setupTableView() {
        tableView.tableFooterView = .init()
        tableView.register(UINib(nibName: "DevicesViewControllerCell", bundle: .main), forCellReuseIdentifier: "cell")
    }
    
    func bindViewModel() {
        addBarbutton.rx.tap.subscribe(onNext: { [weak self] in
            let vc = DetailViewController.createFromStoryboard()
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
                
        viewModel.dataSource.bind(to: tableView.rx.items(cellIdentifier: "cell")) { index, model, cell in
            guard let cell = cell as? DevicesViewControllerCell else { return }
            cell.address.text = model.address
            cell.port.text = "\(model.port)"
        }.disposed(by: rx.disposeBag)
        
        tableView.rx.modelSelected(Device.self).subscribe(onNext: { [weak self] device in
            let vc = DetailViewController.createFromStoryboard()
            vc.device = device
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
                
        tableView.rx.modelDeleted(Device.self).map { (device) -> Bool in
            return Manager<Device>.default.delete(item: device)
        }.map { $0 ? "Success" : "Failed"}
        .bind(to: MessageBox.default.rx.message)
        .disposed(by: rx.disposeBag)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
