//
//  LoginViewModel.swift
//  Tinder
//
//  Created by Juliano Alvarenga on 06/04/19.
//  Copyright © 2019 Juliano Alvarenga. All rights reserved.
//

import Foundation
import Firebase

class LoginViewModel {
    
    var isLogginIn = Bindable<Bool>()
    var isFormValid = Bindable<Bool>()
    
    var email: String? { didSet { checkFormValidity() } }
    var passWord: String? { didSet { checkFormValidity() } }
    
    
    fileprivate func checkFormValidity() {
        guard let email = email, let password = passWord else { return }
        let isValid = !email.isEmpty && !password.isEmpty
        isFormValid.value = isValid
    }
    
    func performLogin(completion: @escaping (Error?) -> Void) {
        guard let email = email, let password = passWord else { return }
        isLogginIn.value = true
        Auth.auth().signIn(withEmail: email, password: password) { (red, err) in
            completion(err)
        }
    }
}

