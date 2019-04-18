//
//  UserDetailsController.swift
//  Tinder
//
//  Created by Juliano Alvarenga on 06/04/19.
//  Copyright © 2019 Juliano Alvarenga. All rights reserved.
//

import UIKit

class UserDetailsController: UIViewController {
    
    lazy var scrollView: UIScrollView = {
        let c = UIScrollView()
        c.alwaysBounceVertical = true
        c.contentInsetAdjustmentBehavior = .never
        c.delegate = self
        return c
    }()
    
    let imageView: UIImageView = {
        let c = UIImageView(image: #imageLiteral(resourceName: "jane2"))
        c.contentMode = .scaleAspectFill
        c.clipsToBounds = true
        return c
    }()
    
    let swipingPhotosController = SwipingPhotosController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    lazy var swipingView = swipingPhotosController.view!
    
    let infoLabel: UILabel = {
        let c = UILabel()
        c.text = "User name 30\nDoctor\nSome bio text down bellow"
        c.numberOfLines = 0
        return c
    }()
    
    let dismissButton: UIButton = {
        let c = UIButton()
        c.setImage(#imageLiteral(resourceName: "dismiss_down_arrow").withRenderingMode(.alwaysOriginal), for: .normal)
        c.addTarget(self, action: #selector(handleTabDismiss), for: .touchUpInside)
        return c
    }()
    
    var cardViewModel: CardViewModel! {
        didSet {
            infoLabel.attributedText = cardViewModel.attributedString
            swipingPhotosController.cardViewModel = cardViewModel
        }
    }
    
    lazy var dislikeButton = self.creatingButtons(image: #imageLiteral(resourceName: "dismiss_circle").withRenderingMode(.alwaysOriginal), selector: #selector(handleDislike))
    lazy var superLikeButton = self.creatingButtons(image: #imageLiteral(resourceName: "super_like_circle").withRenderingMode(.alwaysOriginal), selector: #selector(handleDislike))
    lazy var likeButton = self.creatingButtons(image: #imageLiteral(resourceName: "like_circle").withRenderingMode(.alwaysOriginal), selector: #selector(handleDislike))
    
    
    @objc fileprivate func handleDislike() {
        print("dislike")
    }
    
    fileprivate func creatingButtons(image: UIImage, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupVisualBlurEffectView()
        setupBottomControlls()
    }
    
    fileprivate func setupBottomControlls() {
        let stackview = UIStackView(arrangedSubviews: [dislikeButton, superLikeButton, likeButton])
        stackview.distribution = .fillEqually
        stackview.spacing = -32
        view.addSubview(stackview)
        stackview.anchor(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil, padding: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 300, height: 80))
        stackview.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    fileprivate func setupVisualBlurEffectView() {
        let blurEffect = UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(visualEffectView)
        visualEffectView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.fillSuperview()
        
        
        scrollView.addSubview(swipingView)
        
        scrollView.addSubview(infoLabel)
        infoLabel.anchor(top: swipingView.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: scrollView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 16, right: 16))
        scrollView.addSubview(dismissButton)
        
        dismissButton.anchor(top: swipingView.bottomAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: -25, left: 0, bottom: 0, right: 25), size: .init(width: 50, height: 50))
    }
    
    fileprivate let extraSwipingHeight: CGFloat = 80
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        swipingView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width + extraSwipingHeight)
    }

    @objc fileprivate func handleTabDismiss() {
        dismiss(animated: true)
    }
}

extension UserDetailsController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let changeY = -scrollView.contentOffset.y
        let width = view.frame.width + changeY * 2
        if changeY > 0 {
            swipingView.frame = CGRect(x: -changeY, y: -changeY, width: width, height: width)
        }
    }
}
