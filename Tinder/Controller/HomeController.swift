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
    func didSwipeCard(_ cardView: CardView)
    func didTapDetailObserver(_ cardView: CardView)
    func didTapLikeButtonObserver(_ cardView: CardView)
    func didSaveSettingsObserver(_ settingsController: SettingsController)
    func didLogginInObserver()
}

class HomeController: UIViewController {
    
    //MARK: - V A R I A B L E S
    fileprivate let topStackView = TopNavigationStackView()
    fileprivate let cardDeckView = UIView()
    fileprivate let bottomControls = HomeButtonControllStackView()
    fileprivate var cardViews = [CardViewModel]()
    fileprivate var topCardView: CardView?
    
    fileprivate let hud = JGProgressHUD(style: .dark)
    fileprivate var user: User?
    
    //MARK: - L O A D I N G
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottomControls.refreshButton.addTarget(self, action: #selector(fetchUsersFromFirestore), for: .touchUpInside)
        fetchCurrentUser()
        bottomControls.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        bottomControls.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
            let registrationController = RegistrationController()
            didLogginInObserver()
            let navController = UINavigationController(rootViewController: registrationController)
            present(navController, animated: true)
        }
    }
    
    //MARK: - F U N C T I O N S
    fileprivate func fetchCurrentUser() {
        hud.textLabel.text = "Loading"
        hud.show(in: view)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch user:", err)
                self.hud.dismiss()
                return
            }
            self.hud.dismiss()
            guard let dictionaty = snapshot?.data() else { return }
            self.user = User(dictionary: dictionaty)
            self.fetchSwipes()
        }
    }
    
    var swipes = [String: Int]()
    
    fileprivate func fetchSwipes() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("failed to fetch swipes info for currently logged in user:", err)
                return
            }
            
            print("swipes", snapshot?.data() ?? "")
            guard let data = snapshot?.data() as? [String: Int] else { return }
            self.swipes = data
            self.fetchUsersFromFirestore()
        }
    }
    
    fileprivate func setupCardFrom(user: User) -> CardView {
        let cardView = CardView(frame: .zero)
        cardView.cardViewModel = user.toCardViewModel()
        cardDeckView.addSubview(cardView)
        cardDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
        didTapDetailObserver(cardView)
        didSwipeCard(cardView)
        return cardView
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
        cardDeckView.subviews.forEach({$0.removeFromSuperview()})
        let minAge = user?.minSeekingAge ?? SettingsController.defaultMinSeekingAge
        let maxAge = user?.maxSeekingAge ?? SettingsController.defaultMaxSeekingAge
                
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Feching users"
        hud.show(in: view)
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
        topCardView = nil
        query.getDocuments { (snapShot, err) in
            hud.dismiss()
            if let err = err {
                print("failed to fetch users:", err)
                return
            }
            
            var previousCardView: CardView?
            
            snapShot?.documents.forEach({ (documentSnapshot) in
                let userDictionaty = documentSnapshot.data()
                let user = User(dictionary: userDictionaty)
                let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
//                let hasNotSwipedBefore = self.swipes[user.uid!] == nil
                let hasNotSwipedBefore = true
                if  isNotCurrentUser && hasNotSwipedBefore {
                let cardView = self.setupCardFrom(user: user)
                    previousCardView?.nexCardView = cardView
                    previousCardView = cardView
                    if self.topCardView == nil {
                        self.topCardView = cardView
                    }
                }
            })
        }
    }
    
    @objc fileprivate func handleLike() {
        saveSwipeToFirestore(isLike: 1)
        animateLikeDislike(translation: 700, angle: 15)
    }
    
    @objc fileprivate func handleDislike() {
        saveSwipeToFirestore(isLike: 0)
        animateLikeDislike(translation: -700, angle: -15)
    }
    
    fileprivate func saveSwipeToFirestore(isLike: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch swipe document", err)
                return
            }
            if snapshot?.exists == true {
                self.saveOrUpdateData(uid: uid, isLike, .update)
            } else {
                self.saveOrUpdateData(uid: uid, isLike, .save)
            }
        }
    }
    
    fileprivate func saveOrUpdateData(uid: String,_ isLike: Int, _ type: saveOrUpdate) {
        guard let cardUID = topCardView?.cardViewModel.uid else { return }
        if isLike == 1 {
            checkOfMatchExists(cardUID: cardUID)
        }
        let documentData = [cardUID: isLike]
        switch type {
        case .update:
            Firestore.firestore().collection("swipes").document(uid).updateData(documentData) { (err) in
                if let err = err {
                    print("Failed to save swipe data:", err)
                    return
                }
            }
        default:
            Firestore.firestore().collection("swipes").document(uid).setData(documentData) { (err) in
                if let err = err {
                    print("Failed to save swipe data:", err)
                    return
                }
            }
        }
    }
    
    fileprivate enum saveOrUpdate {
        case update, save
    }
    
    fileprivate func checkOfMatchExists(cardUID: String) {
        Firestore.firestore().collection("swipes").document(cardUID).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch document for card user", err)
                return
            }
            guard let data = snapshot?.data() else { return }
            print(data)
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let hasMatched = data[uid] as? Int == 1
            if hasMatched {
                print("had matched")
                self.presetMatchView(cardUID: cardUID)
            }
        }
    }
    
    fileprivate func presetMatchView(cardUID: String) {
        let matchView = MatchView()
        matchView.cardUID = cardUID
        matchView.currentUser = user
        view.addSubview(matchView)
        matchView.fillSuperview()
    }
    
    fileprivate func animateLikeDislike(translation: CGFloat, angle: CGFloat) {
        let duration = 0.3        
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = duration
        translationAnimation.fillMode = .forwards
        translationAnimation.isRemovedOnCompletion = false
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = duration
        
        let cardView = topCardView
        topCardView = cardView?.nexCardView
        
        cardView?.layer.add(translationAnimation, forKey: "translation")
        cardView?.layer.add(rotationAnimation, forKey: "rotation")
        CATransaction.commit()
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }
    }
}

extension HomeController: SetupObservers {
    
    func didSwipeCard(_ cardView: CardView) {
        cardView.bindableCardSwipe.bind { [unowned self] (direction) in
            if direction == 1 {
                self.handleLike()
            } else {
                self.handleDislike()
            }
        }
    }
    
    func didTapLikeButtonObserver(_ cardView: CardView) {
        self.topCardView?.removeFromSuperview()
        cardView.bindableDidRemove.bind { [unowned self] (cv) in
            self.topCardView = cv
        }
    }
    
    func didLogginInObserver() {
        fetchCurrentUser()
    }
    
    func didTapDetailObserver(_ cardView: CardView) {
        cardView.bindableCardView.bind { [unowned self] (cvm) in
            let infoController = UserDetailsController()
            infoController.cardViewModel = cvm
            self.present(infoController, animated: true)
        }
    }
    
    func didSaveSettingsObserver(_ settingsController: SettingsController) {
        settingsController.bindableSave.bind { [unowned self] (_) in
            self.fetchCurrentUser()
        }
    }
}

