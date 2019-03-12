//
//  ViewController.swift
//  Tinder
//
//  Created by Juliano Alvarenga on 02/02/19.
//  Copyright © 2019 Juliano Alvarenga. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class HomeController: UIViewController {
    
    //MARK: - V A R I A B L E S
    let topStackView = TopNavigationStackView()
    let cardDeckView = UIView()
    let bottomControls = HomeButtonControllStackView()
    
    var cardViews = [CardViewModel]()
    
    //MARK: - L O A D I N G
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottomControls.refreshButton.addTarget(self, action: #selector(fetchUsersFromFirestore), for: .touchUpInside)
        fetchUsersFromFirestore()
    }
    
    //MARK: - F U N C T I O N S
    @objc fileprivate func handleSettings() {
        let settingsController = SettingsController()
        let navController = UINavigationController(rootViewController: settingsController)
        present(navController, animated: true)
    }
    
    var lastFetchedUser: User?
    
    @objc fileprivate func fetchUsersFromFirestore() {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Feching users"
        hud.show(in: view)
        let query = Firestore.firestore().collection("users").order(by: "uid").start(after: [lastFetchedUser?.uid ?? ""]).limit(to: 2)
        query.getDocuments { (snapShot, err) in
            hud.dismiss()
            if let err = err {
                print("failed to fetch users:", err)
                return
            }
            
            snapShot?.documents.forEach({ (documentSnapshot) in
                let userDictionaty = documentSnapshot.data()
                let user = User(dictionary: userDictionaty)
                self.cardViews.append(user.toCardViewModel())
                self.lastFetchedUser = user
                self.setupCardFrom(user: user)
            })
        }
    }
    
    fileprivate func setupCardFrom(user: User) {
        let cardView = CardView(frame: .zero)
        cardView.cardViewModel = user.toCardViewModel()
        cardDeckView.addSubview(cardView)
        cardDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
    }
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardDeckView, bottomControls])
        view.addSubview(overallStackView)
        overallStackView.axis = .vertical
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        overallStackView.bringSubviewToFront(cardDeckView)
    }
}

