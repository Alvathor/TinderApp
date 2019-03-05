//
//  RegistrationViewModel.swift
//  Tinder
//
//  Created by Juliano Alvarenga on 03/03/19.
//  Copyright © 2019 Juliano Alvarenga. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewModel {
    
    var bindableRegistering = Bindable<Bool>()
    var bindableImage = Bindable<UIImage>()
    var isBindableFormValid = Bindable<Bool>()
    
    var fullName: String?   { didSet { checkFormValidity() } }
    var email: String?      { didSet { checkFormValidity() } }
    var password: String?   { didSet { checkFormValidity() } }
    
    fileprivate func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty  == false && password?.isEmpty == false
        isBindableFormValid.value = isFormValid
    }
    
    func performRegistration(completion: @escaping (Error?) -> ()) {
        guard let email = email, let password = password else { return }
        bindableRegistering.value = true
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err {
                completion(err)
                return
            }
            self.storatePicture(completion: { err in
                if let err = err {
                    completion(err)
                }
            })
        }
    }
    
    fileprivate func storatePicture(completion: @escaping (Error?) -> ()) {
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        ref.putData(imageData, metadata: metaData, completion: { (_, err) in
            if let err = err {
                completion(err)
                return
            }
            print("finished uploading image to storage")
            ref.downloadURL(completion: { (url, err) in
                if let err = err {
                    completion(err)
                    return
                }
                self.bindableRegistering.value = false
                print("download url of our image is :", url?.absoluteString ?? "")
            })
        })
    }
}
