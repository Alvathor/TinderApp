//
//  ViewController.swift
//  Tinder
//
//  Created by Juliano Alvarenga on 02/02/19.
//  Copyright © 2019 Juliano Alvarenga. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UIViewController {
    
    //MARK: - V A R I A B L E S
    let topStackView = TopNavigationStackView()
    let cardDeckView = UIView()
    let buttonsStackView = HomeButtonControllStackView()
    
    var cardViews = [CardViewModel]()
    
    //MARK: - L O A D I N G
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        fetchUsersFromFirestore()
    }
    
    //MARK: - F U N C T I O N S
    @objc fileprivate func handleSettings() {
        let registrationController = RegistrationController()
        present(registrationController, animated: true)
    }
    
    fileprivate func fetchUsersFromFirestore() {
        Firestore.firestore().collection("users").getDocuments { (snapShot, err) in
            if let err = err {
                print("failed to fetch users:", err)
                return
            }
            
            snapShot?.documents.forEach({ (documentSnapshot) in
                let userDictionaty = documentSnapshot.data()
                let user = User(dictionary: userDictionaty)
                self.cardViews.append(user.toCardViewModel())
            })
            self.setupFirestoreUsersCards()            
        }
    }
    
    fileprivate func setupFirestoreUsersCards() {
        cardViews.forEach { (cardViewModel) in
            let cardView = CardView(frame: .zero)            
            cardView.cardViewModel = cardViewModel
            cardDeckView.addSubview(cardView)
            cardView.fillSuperview()            
        }
    }
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardDeckView, buttonsStackView])
        view.addSubview(overallStackView)
        overallStackView.axis = .vertical
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        overallStackView.bringSubviewToFront(cardDeckView)
    }
}

