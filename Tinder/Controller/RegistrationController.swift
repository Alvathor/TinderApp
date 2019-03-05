//
//  RegistrationController.swift
//  Tinder
//
//  Created by Juliano Alvarenga on 02/03/19.
//  Copyright © 2019 Juliano Alvarenga. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        registrationViewModel.bindableImage.value = image
        dismiss(animated: true)
    }
}

class RegistrationController: UIViewController {
    
    //MARK: - V A R I A B L E S
    
    let registrationViewModel = RegistrationViewModel()
    let gradientLayer = CAGradientLayer()
    let registeringHUD = JGProgressHUD(style: .dark)
    
    let selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SelectPhoto", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        button.backgroundColor  = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }()
    
    let fullNameTextField: UITextField = {
        let tf = CustomTextField(padding: 16)
        tf.placeholder = "Enter full name"
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
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
    
    let registerButton: UIButton = {
        let bt = CustomButton()
        bt.setTitle("Register", for: .normal)
        bt.backgroundColor = .lightGray
        bt.isEnabled = false
        bt.addTarget(self, action: #selector(login), for: .touchUpInside)
        return bt
    }()
    
    lazy var overallStackView = UIStackView(arrangedSubviews: [
        selectPhotoButton,
        verticalStackView
        ])
    
    lazy var verticalStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [ fullNameTextField, emailTextField, passwordTextField, registerButton])
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 8
        return sv
    }()
    
    //MARK: - L O A D I N G
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientLayer()
        setupLayout()
        setupRegistrationViewModelObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNotificationObservers()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    //MARK: - F U N C T I O N S
    
    fileprivate func setupLayout() {
        view.addSubview(overallStackView)
        overallStackView.axis = .vertical
        overallStackView.spacing = 8
        overallStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        overallStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    fileprivate func setupGradientLayer() {
        let topColor = #colorLiteral(red: 0.9897844195, green: 0.3658325076, blue: 0.3792536259, alpha: 1)
        let bottomColor = #colorLiteral(red: 0.8935824037, green: 0.1105981693, blue: 0.461191535, alpha: 1)
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0,1]
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds
    }
    
    fileprivate func setupRegistrationViewModelObserver() {
        registrationViewModel.isBindableFormValid.bind { [unowned self] isFormValid in
            guard let isFormValid = isFormValid else { return }
            self.registerButton.isEnabled = isFormValid
            if isFormValid {
                self.registerButton.backgroundColor = #colorLiteral(red: 0.9897844195, green: 0.3658325076, blue: 0.3792536259, alpha: 1)
            } else {
                self.registerButton.backgroundColor = .lightGray
            }
        }
        
        registrationViewModel.bindableImage.bind { [unowned self] image in
            self.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        registrationViewModel.bindableRegistering.bind { [unowned self] isRegistering in
            guard let isRegistering = isRegistering else { return }
            if isRegistering {
                self.registeringHUD.textLabel.text = "Registering"
                self.registeringHUD.show(in: self.view)
            } else {
                self.registeringHUD.dismiss()
            }
        }
    }
    
    fileprivate func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Objc Targets
    
    @objc fileprivate func handleSelectPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    @objc fileprivate func handleTextChange(textField: UITextField) {
        switch textField {
        case fullNameTextField: registrationViewModel.fullName  = textField.text
        case emailTextField:    registrationViewModel.email     = textField.text
        case passwordTextField: registrationViewModel.password  = textField.text
        default: break
        }
    }
    
    @objc fileprivate func handleKeyBoardHide(notification: Notification) {
        UIView.animate(withDuration: 0.2) {
            self.view.transform = .identity
        }
    }
    
    @objc fileprivate func handleKeyBoardShow(notification: Notification) {
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyBoardFrame = value.cgRectValue
        let bottomSpace = view.frame.height - overallStackView.frame.origin.y - overallStackView.frame.height
        let difference = keyBoardFrame.height - bottomSpace
        
        if traitCollection.verticalSizeClass == .compact {
            UIView.animate(withDuration: 0.2) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -bottomSpace)
            }
            
        } else {
            UIView.animate(withDuration: 0.2) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -difference - 8)
            }
        }
    }
    
    @objc fileprivate func login() {
        view.endEditing(true)
        registrationViewModel.performRegistration { [unowned self] (err) in
            if let err = err {
                self.showHUDWithError(err)
            }
        }
    }
    
    fileprivate func showHUDWithError(_ error: Error) {
        self.registeringHUD.dismiss()
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Faile Registration"
        hud.detailTextLabel.text = error.localizedDescription
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 4)
    }
    
    // Handle Orientation
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.verticalSizeClass == .compact {
            overallStackView.axis = .horizontal
            selectPhotoButton.widthAnchor.constraint(equalToConstant: view.frame.width / 3).isActive = true
        } else {
            overallStackView.axis = .vertical
            selectPhotoButton.heightAnchor.constraint(equalToConstant: view.frame.height / 3).isActive = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
