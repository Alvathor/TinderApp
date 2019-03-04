//
//  CustomButton.swift
//  Tinder
//
//  Created by Juliano Alvarenga on 02/03/19.
//  Copyright © 2019 Juliano Alvarenga. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        layer.cornerRadius = 25
        titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
