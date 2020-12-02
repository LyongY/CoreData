//
//  DeviceDetailViewController.swift
//  Demo
//
//  Created by Raysharp666 on 2020/11/26.
//

import UIKit
import RxCocoa
import RxSwift

class DeviceDetailViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    var viewModel: DeviceDetailViewModel!
    
    lazy var saveBarButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "aspectratio.fill"), style: .done, target: nil, action: nil)
    var addressTextField: UITextField = UITextField()
    var portTextField: UITextField = UITextField()
    var usernameTextField: UITextField = UITextField()
    var passwordTextField: UITextField = UITextField()
    
    init(makeViewModel: (_ vc: DeviceDetailViewController) -> DeviceDetailViewModel) {
        super.init(nibName: nil, bundle: nil)
        viewModel = makeViewModel(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bindViewModel()
    }
    
    func initUI() {
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = saveBarButton
        
        addressTextField.placeholder = "Address"
        addressTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addressTextField)
        view.addConstraints([
            addressTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 90),
            addressTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 20),
            addressTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])
        
        portTextField.placeholder = "Port"
        portTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(portTextField)
        view.addConstraints([
            portTextField.topAnchor.constraint(equalTo: addressTextField.bottomAnchor, constant: 20),
            portTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 20),
            portTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        usernameTextField.placeholder = "Username"
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameTextField)
        view.addConstraints([
            usernameTextField.topAnchor.constraint(equalTo: portTextField.bottomAnchor, constant: 20),
            usernameTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 20),
            usernameTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

        passwordTextField.placeholder = "Password"
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passwordTextField)
        view.addConstraints([
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 20),
            passwordTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
        ])

    }
    
    func bindViewModel() {
        viewModel.saved.drive { [weak self] (success) in
            if success {
                print("saved success")
                self?.navigationController?.popViewController(animated: true)
            } else {
                print("saved failed")
            }
        } onCompleted: {} onDisposed: {}
        .disposed(by: disposeBag)
        
        viewModel.saveEnable.drive(saveBarButton.rx.isEnabled).disposed(by: disposeBag)

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
