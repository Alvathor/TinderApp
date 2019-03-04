//
//  User.swift
//  Tinder
//
//  Created by Juliano Alvarenga on 03/02/19.
//  Copyright © 2019 Juliano Alvarenga. All rights reserved.
//

import UIKit

struct User: ProducesCardViewModel  {
    let name: String
    let age: Int
    let profession: String
    let imageNames: [String]
    
    func toCardViewModel() -> CardViewModel {
        let attributexText = NSMutableAttributedString(string: name, attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .heavy)])
        attributexText.append(NSAttributedString(string: " \(age)", attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .regular)]))
        attributexText.append(NSAttributedString(string: "\n\(profession)", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .regular)]))
        
        return CardViewModel(_imageNames: imageNames, _attributedString: attributexText, _textAligment: .left)
    }
}


