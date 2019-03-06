//
//  HomeButtonControllStackView.swift
//  Tinder
//
//  Created by Juliano Alvarenga on 02/02/19.
//  Copyright © 2019 Juliano Alvarenga. All rights reserved.
//

import UIKit

class HomeButtonControllStackView: UIStackView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        distribution = .fillEqually
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        let bottomSubviews = [#imageLiteral(resourceName: "refresh_circle"), #imageLiteral(resourceName: "dismiss_circle"), #imageLiteral(resourceName: "super_like_circle"), #imageLiteral(resourceName: "like_circle"), #imageLiteral(resourceName: "boost_circle")].map { (img) -> UIView in
            let bt = UIButton(type: .system)
            bt.setImage(img.withRenderingMode(.alwaysOriginal), for: .normal)            
            return bt
        }
        
        bottomSubviews.forEach { (v) in
            addArrangedSubview(v)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
