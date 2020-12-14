//
//  DetailViewController.swift
//  Demo2
//
//  Created by Raysharp666 on 2020/12/9.
//

import UIKit

class DetailViewController: UIViewController {
    var device: Device?
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let saveBarButton = UIBarButtonItem(systemItem: .save)
    
    lazy var viewModel = DetailViewModel(address: addressTextField.rx.text,
                                     port: portTextField.rx.text,
                                     username: usernameTextField.rx.text,
                                     password: passwordTextField.rx.text,
                                     save: saveBarButton.rx.tap)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
    }
    
    func setupUI() {
        navigationItem.rightBarButtonItem = saveBarButton
    }
    
    func bindViewModel() {
        if let device = device {
            viewModel.device = device
            addressTextField.text = device.address
            portTextField.text = "\(device.port)"
            usernameTextField.text = device.username
            passwordTextField.text = device.password
        }

        viewModel.saveEnabel.drive(saveBarButton.rx.isEnabled).disposed(by: rx.disposeBag)
                
        viewModel.saveTapped.drive(onNext: { [weak self] success in
            if success {
                self?.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: rx.disposeBag)
        
        viewModel.saveTapped.map({ $0 ? "Success" : "Failed"}).drive(MessageBox.default.rx.message).disposed(by: rx.disposeBag)
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
