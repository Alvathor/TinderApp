//
//  CardView.swift
//  Tinder
//
//  Created by Juliano Alvarenga on 02/02/19.
//  Copyright © 2019 Juliano Alvarenga. All rights reserved.
//

import UIKit
import SDWebImage

class CardView: UIView {
    
    fileprivate let imageView = UIImageView()
    fileprivate let informationLabel = UILabel()
    fileprivate let threshold: CGFloat = 100
    fileprivate let barStackView = UIStackView()
    fileprivate let barDeselectedColor = UIColor.darkGray.withAlphaComponent(0.2)
    fileprivate let gradientLayer = CAGradientLayer()
    
    var imageIndex = 0
    
    var cardViewModel: CardViewModel! {
        didSet {
            let imageName = cardViewModel.imageNames.first ?? ""
            if let url = URL(string: imageName) {
                imageView.sd_setImage(with: url) { (_, _, _, _) in
//                    UIView.animate(withDuration: 0.3, animations: {
//                        self.alpha = 1
//                    })                    
                }
            }
            informationLabel.attributedText = cardViewModel.attributedString
            informationLabel.textAlignment = cardViewModel.textAligment
            
            (0..<cardViewModel.imageNames.count).forEach { (c) in
                let barView = UIView()
                barView.backgroundColor = barDeselectedColor
                barView.layer.cornerRadius = 2
                barView.clipsToBounds = true
                barStackView.addArrangedSubview(barView)
            }
            barStackView.arrangedSubviews.first?.backgroundColor = .white
            setupImageIndexObserver()
        }
    }
    
    override func layoutSubviews() {
        gradientLayer.frame = frame
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)        
        setupLayout()
    }
    
    
    fileprivate func setupImageIndexObserver() {
        cardViewModel.imageIndexObserver = { [weak self] image, index in
            self?.imageView.image = image
            self?.barStackView.arrangedSubviews.forEach({ (v) in
                v.backgroundColor = self?.barDeselectedColor
            })
            self?.barStackView.arrangedSubviews[index].backgroundColor = .white
        }
    }
    
    fileprivate func setupGradientLayer() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.6).cgColor]
        gradientLayer.locations = [0.2, 1]
        layer.addSublayer(gradientLayer)
    }
    
    fileprivate func setupLayout() {
//        self.alpha = 0
        clipsToBounds = true
        layer.cornerRadius = 15
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.fillSuperview()
        setupBarsStackView()
        setupGradientLayer()
        
        addSubview(informationLabel)
        informationLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
        informationLabel.textColor = .white
        informationLabel.numberOfLines = 0
        informationLabel.font = UIFont.systemFont(ofSize: 34, weight: .heavy)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        addGestureRecognizer(panGesture)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc fileprivate func handleTap(gesture: UITapGestureRecognizer) {        
        let tapLocation = gesture.location(in: nil)
        let shouldAdvanceNextPhoto = tapLocation.x > frame.width / 2 ? true : false
        if shouldAdvanceNextPhoto {
            cardViewModel.advanceToNexPhoto()
        } else {
            cardViewModel.goToPrevioushoto()
        }
    }
    
    fileprivate func setupBarsStackView() {
        addSubview(barStackView)
        barStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
        barStackView.spacing = 4
        barStackView.distribution = .fillEqually
    }
    
    
    @objc fileprivate func handlePan(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            superview?.subviews.forEach({ (cardView) in
                cardView.layer.removeAllAnimations()
            })
        case .changed:
            handleChangedState(sender)
        case .ended:
            HandleEndedState(sender)
        default:
            break
        }
    }
    
    fileprivate func handleChangedState(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: nil)
        transform = CGAffineTransform.init(translationX: translation.x, y: translation.y)
        let degrees: CGFloat = translation.x / 20
        let angle = degrees * .pi / 180
        transform = CGAffineTransform(translationX: translation.x, y: translation.y).rotated(by: angle)
    }
    
    fileprivate func HandleEndedState(_ sender: UIPanGestureRecognizer) {
        let translationDirection: CGFloat = sender.translation(in: nil).x > 0 ? 1 : -1
        let shouldDismissCard = abs(sender.translation(in: nil).x) > threshold
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            if shouldDismissCard {
                self.frame = CGRect(x: 600 * translationDirection, y: 0, width: self.frame.width, height: self.frame.height)
                
            } else {
                self.transform = .identity
            }
        }) { (_) in
            self.transform = .identity
            if shouldDismissCard {
                self.removeFromSuperview()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
