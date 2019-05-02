//
//  MatchView.swift
//  Tinder
//
//  Created by Juliano Alvarenga on 27/04/19.
//  Copyright © 2019 Juliano Alvarenga. All rights reserved.
//

import UIKit
import Firebase

class MatchView: UIView {
    
    var isReadyToReturnAlpha = Bindable<Bool>()
    
    var currentUser: User? {
        didSet {
            guard let user = currentUser else { return }
            guard let url = URL(string: user.imageUrl1 ?? "") else { return }
            currentUserImageView.sd_setImage(with: url) { (_, _, _, _) in
                self.returningAlphaObserver()
            }
        }
    }
    
    var cardUID: String? {
        didSet {
            guard let cardUID = cardUID else { return }
            let query = Firestore.firestore().collection("users")
            query.document(cardUID).getDocument { (snapshot, err) in
                if let err = err {
                    print("Failed to fetch card user:", err)
                    return
                }
                
                guard let dictionary = snapshot?.data() else { return }
                let user = User(dictionary: dictionary)
                guard let url = URL(string: user.imageUrl1 ?? "") else { return }
                self.cardUserImageView.sd_setImage(with: url) { (_, _, _, _) in
                    self.returningAlphaObserver()
                    self.descriptionLabel.text = "You and \(user.name ?? "") have a liked\nearch other"
                }
            }
        }
    }
    
    fileprivate let currentUserImageView: UIImageView = {
        let c = UIImageView()
        c.contentMode = .scaleAspectFill
        c.clipsToBounds = true
        c.layer.cornerRadius = 140 / 2
        c.layer.borderColor = UIColor.white.cgColor
        c.layer.borderWidth = 1
        return c
    }()
    
    fileprivate let cardUserImageView: UIImageView = {
        let c = UIImageView()
        c.contentMode = .scaleAspectFill
        c.clipsToBounds = true
        c.layer.cornerRadius = 140 / 2
        c.layer.borderColor = UIColor.white.cgColor
        c.layer.borderWidth = 1
        return c
    }()
    
    fileprivate let itsAMatchImageView: UIImageView = {
        let c = UIImageView()
        c.contentMode = .scaleAspectFill
        c.image = #imageLiteral(resourceName: "itsamatch")
        return c
    }()
    
    fileprivate let descriptionLabel: UILabel = {
        let c = UILabel()
        c.text = "You and X have a liked\nearch other"
        c.textAlignment = .center
        c.textColor = .white
        c.font = UIFont.systemFont(ofSize: 20)
        c.numberOfLines = 0
        return c
    }()
    
    fileprivate let sendMessageButton: UIButton = {
        let c = SendMessageButton()
        c.setTitle("Send Message", for: .normal)        
        return c
    }()
    
    fileprivate let keepSwipingButton: UIButton = {
        let c = KeepSwipingButton()
        c.setTitle("Keep swiping", for: .normal)
        return c
    }()
    
    fileprivate let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupBlueView()
        setupLayout()
    }
    
    fileprivate func returningAlphaObserver() {
       isReadyToReturnAlpha.value = (currentUserImageView.image != nil && cardUserImageView.image != nil)
        isReadyToReturnAlpha.bind { [unowned self] (isReady) in
            guard let isReady = isReady else { return }
            if isReady {
                self.setupAnimation()
            }
        }
    }
    
    fileprivate func setupAnimation() {
        self.alpha = 1
        let angle = 30 * CGFloat.pi / 180
        sendMessageButton.transform = CGAffineTransform.init(translationX: -500, y: 0)
        keepSwipingButton.transform = CGAffineTransform.init(translationX: 500, y: 0)
        currentUserImageView.transform = CGAffineTransform.init(translationX: 200, y: 0).rotated(by: -angle)
        cardUserImageView.transform = CGAffineTransform.init(translationX: -200, y: 0).rotated(by: angle)
        currentUserImageView.alpha = 0
        cardUserImageView.alpha = 0
        
        UIView.animateKeyframes(withDuration: 1.3, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.45, animations: {
                self.currentUserImageView.alpha = 1
                self.cardUserImageView.alpha = 1
                self.currentUserImageView.transform = CGAffineTransform(rotationAngle: -angle)
                self.cardUserImageView.transform = CGAffineTransform(rotationAngle: angle)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4, animations: {
                self.currentUserImageView.transform = .identity
                self.cardUserImageView.transform = .identity
            })
            
            UIView.animate(withDuration: 0.75, delay: 0.6 * 1.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
                self.sendMessageButton.transform = .identity
                self.keepSwipingButton.transform = .identity
            })
            
        }) { (_) in
            
        }
    }
    
    fileprivate func setupLayout() {
        self.alpha = 0
        addSubview(itsAMatchImageView)
        addSubview(descriptionLabel)
        addSubview(currentUserImageView)
        addSubview(cardUserImageView)
        addSubview(sendMessageButton)
        addSubview(keepSwipingButton)
        
        let imageWidth: CGFloat = 140
        
        itsAMatchImageView.anchor(top: nil, leading: currentUserImageView.leadingAnchor, bottom: descriptionLabel.topAnchor, trailing: cardUserImageView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 32, right: 0), size: .init(width: 0, height: 80))
        
        descriptionLabel.anchor(top: nil, leading: currentUserImageView.leadingAnchor, bottom: currentUserImageView.topAnchor, trailing: cardUserImageView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 32, right: 0), size: .init(width: 0, height: 50))
        
        currentUserImageView.anchor(top: nil, leading: nil, bottom: nil, trailing: centerXAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 16), size: .init(width: imageWidth, height: imageWidth))
        currentUserImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        cardUserImageView.anchor(top: nil, leading: centerXAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 16, bottom: 0, right: 0), size: .init(width: imageWidth, height: imageWidth))
        cardUserImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        sendMessageButton.anchor(top: currentUserImageView.bottomAnchor, leading: currentUserImageView.leadingAnchor, bottom: nil, trailing: cardUserImageView.trailingAnchor, padding: .init(top: 32, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 60))
        
        keepSwipingButton.anchor(top: sendMessageButton.bottomAnchor, leading: currentUserImageView.leadingAnchor, bottom: nil, trailing: cardUserImageView.trailingAnchor, padding: .init(top: 8, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 60))
    }
    
    fileprivate func setupBlueView() {
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
        self.alpha = 0
        addSubview(visualEffectView)
        visualEffectView.fillSuperview()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.alpha = 1
        }) { (_) in
         
        }
    }
    
    @objc fileprivate func handleTapDismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
