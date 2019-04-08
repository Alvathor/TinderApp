//
//  LoginController.swift
//  Tinder
//
//  Created by Juliano Alvarenga on 06/04/19.
//  Copyright © 2019 Juliano Alvarenga. All rights reserved.
//

import UIKit
import JGProgressHUD

class LoginController: UIViewController {
    let gradientLayer = CAGradientLayer()
    
    let emailTextField: UITextField = {
        let tf = CustomTextField(padding: 16)
        tf.placeholder = "Enter email"
        tf.keyboardType = .emailAddress
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = CustomTextField(padding: 16)
        tf.placeholder = "Enter password"
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    let loginButton: UIButton = {
        let bt = CustomButton()
        bt.setTitle("Register", for: .normal)
        bt.backgroundColor = .lightGray
        bt.isEnabled = false
        bt.addTarget(self, action: #selector(login), for: .touchUpInside)
        return bt
    }()
    
    let backButton: UIButton = {
        let bt = CustomButton()
        bt.setTitle("Go back", for: .normal)
        bt.setTitleColor(.white, for: .normal)
        bt.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        bt.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        return bt
    }()
    
    lazy var verticalStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 8
        return sv
    }()
    
    fileprivate var loginViewModel = LoginViewModel()
    fileprivate let loginHud = JGProgressHUD(style: .dark)    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientLayer()
        setupLayout()
        setupBindables()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    fileprivate func setupBindables() {
        loginViewModel.isFormValid.bind { [unowned self] (isFormValid) in
            guard let isFormValid = isFormValid else { return }
            self.loginButton.isEnabled = isFormValid
            self.loginButton.backgroundColor = isFormValid ? #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1) : .lightGray
            self.loginButton.setTitleColor(isFormValid ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : .gray, for: .normal)
        }
        
        loginViewModel.isLogginIn.bind { [unowned self] (isRegistering) in
            guard let isRegisteting = isRegistering else { return }
            if isRegisteting {
                self.loginHud.textLabel.text = "Register"
                self.loginHud.show(in: self.view)
            } else {
                self.loginHud.dismiss()
            }
        }
    }
    
    @objc fileprivate func handleTextChange(_ textField: UITextField) {
        if textField == emailTextField {
            loginViewModel.email = textField.text
        } else {
            loginViewModel.passWord = textField.text
        }
        
    }
    
    @objc fileprivate func login() {
        loginViewModel.performLogin { (err) in
            self.loginHud.dismiss()
            if let err = err {
                print("Failed to log in:", err)
                return
            }
            
            print("Logged in successfully")
            self.dismiss(animated: true, completion: {
                let didFinishLogginIn = Bindable<Void>()
                didFinishLogginIn.value = nil
            })
        }
    }
    
    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setupLayout() {
        navigationController?.isNavigationBarHidden = true
        view.addSubview(verticalStackView)
        verticalStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets.init(top: 0, left: 50, bottom: 0, right: 50))
        verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        view.addSubview(backButton)
        backButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    fileprivate func setupGradientLayer() {
        let topColor = #colorLiteral(red: 0.9897844195, green: 0.3658325076, blue: 0.3792536259, alpha: 1)
        let bottomColor = #colorLiteral(red: 0.8935824037, green: 0.1105981693, blue: 0.461191535, alpha: 1)
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0,1]
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds
    }

}
