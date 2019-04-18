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
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty  == false && password?.isEmpty == false && bindableImage.value != nil
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
            self.storateImageToFirebase(completion: completion)
        }
    }
    
    fileprivate func storateImageToFirebase(completion: @escaping (Error?) -> ()) {
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
                let imageUrl = url?.absoluteString ?? ""
                self.saveInfoToFirestore(imageUrl: imageUrl, completion: completion)
            })
        })
    }
    
    fileprivate func saveInfoToFirestore(imageUrl: String, completion: @escaping (Error?) -> ()) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData: [String : Any] = [
            "fullName": fullName ?? "",
            "uid": uid,
            "imageUrl1": imageUrl,
            "age": 18,
            "minSeekingAge": SettingsController.defaultMinSeekingAge,
            "maxSeekingAge": SettingsController.defaultMaxSeekingAge
        ]
        
        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        }
    }
}
