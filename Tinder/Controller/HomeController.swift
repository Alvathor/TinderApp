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

protocol SetupObservers {
    func didTapDetailObserver(_ cardView: CardView)
    func didSaveSettingsObserver(_ settingsController: SettingsController)
    func didLogginInObserver()
}

class HomeController: UIViewController {
    
    //MARK: - V A R I A B L E S
    let topStackView = TopNavigationStackView()
    let cardDeckView = UIView()
    let bottomControls = HomeButtonControllStackView()
    var cardViews = [CardViewModel]()
    fileprivate var user: User?
    
    //MARK: - L O A D I N G
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottomControls.refreshButton.addTarget(self, action: #selector(fetchUsersFromFirestore), for: .touchUpInside)
        fetchCurrentUser()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
            let loginController = LoginController()
            didLogginInObserver()
            let navController = UINavigationController(rootViewController: loginController)
            present(navController, animated: true)
        }
    }
    
    //MARK: - F U N C T I O N S
    fileprivate func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            guard let dictionaty = snapshot?.data() else { return }
            self.user = User(dictionary: dictionaty)
            self.fetchUsersFromFirestore()
        }
    }
    
    fileprivate func setupCardFrom(user: User) {
        let cardView = CardView(frame: .zero)
        cardView.cardViewModel = user.toCardViewModel()
        cardDeckView.addSubview(cardView)
        cardDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
        didTapDetailObserver(cardView)
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
    
    @objc fileprivate func handleSettings() {
        let settingsController = SettingsController()
        didSaveSettingsObserver(settingsController)
        let navController = UINavigationController(rootViewController: settingsController)
        present(navController, animated: true)
    }
    
    @objc fileprivate func fetchUsersFromFirestore() {
        guard let minAge = user?.minSeekingAge, let maxAge = user?.maxSeekingAge else { return }
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Feching users"
        hud.show(in: view)
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
        query.getDocuments { (snapShot, err) in
            hud.dismiss()
            if let err = err {
                print("failed to fetch users:", err)
                return
            }
            
            snapShot?.documents.forEach({ (documentSnapshot) in
                let userDictionaty = documentSnapshot.data()
                let user = User(dictionary: userDictionaty)
                if user.uid != Auth.auth().currentUser?.uid {
                    self.setupCardFrom(user: user)
                }
            })
        }
    }
}

extension HomeController: SetupObservers {
    
    func didLogginInObserver() {
        fetchCurrentUser()
    }
    
    func didTapDetailObserver(_ cardView: CardView) {
        cardView.bindableCardView.bind { [unowned self] (cdv) in
            let infoController = UserDetailsController()
            infoController.cardViewModel = cdv
            self.present(infoController, animated: true)
        }
    }
    
    func didSaveSettingsObserver(_ settingsController: SettingsController) {
        settingsController.bindableSave.bind { [unowned self] (_) in
            self.fetchCurrentUser()
        }
    }
}

