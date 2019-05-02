//
//  SendMessageButton.swift
//  Tinder
//
//  Created by Juliano Alvarenga on 27/04/19.
//  Copyright © 2019 Juliano Alvarenga. All rights reserved.
//

import UIKit

class SendMessageButton: UIButton {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        layer.cornerRadius = rect.height / 2
        clipsToBounds = true
        titleLabel?.textColor = .white
        let gradientLayer = CAGradientLayer()
        let leftColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        let rightColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        gradientLayer.colors = [leftColor.cgColor, rightColor.cgColor]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 0.5)
        self.layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.frame = rect
    }

}
