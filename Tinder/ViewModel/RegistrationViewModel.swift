//
//  RegistrationViewModel.swift
//  Tinder
//
//  Created by Juliano Alvarenga on 03/03/19.
//  Copyright © 2019 Juliano Alvarenga. All rights reserved.
//

import Foundation

class RegistrationViewModel {
    var fullName: String? { didSet { checkFormValidity() } }
    var email: String? { didSet { checkFormValidity() } }
    var password: String? { didSet { checkFormValidity() } }
    
    fileprivate func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty  == false && password?.isEmpty == false
        isFormValidObserver?(isFormValid)                
    }
    
    var isFormValidObserver: ((Bool) -> ())?
}
