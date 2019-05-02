//
//  Advertiser.swift
//  Tinder
//
//  Created by Juliano Alvarenga on 26/02/19.
//  Copyright © 2019 Juliano Alvarenga. All rights reserved.
//

import UIKit

struct Advertiser: ProducesCardViewModel {
    let title: String
    let brandName: String
    let posterPhotoName: String
    
    func toCardViewModel() -> CardViewModel {
        let attributedString = NSMutableAttributedString(string: title, attributes: [.font: UIFont.systemFont(ofSize: 34, weight: .heavy)])
        attributedString.append(NSAttributedString(string: "\n" + brandName, attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .bold)]))

        return CardViewModel(uid: "", _imageNames: [posterPhotoName], _attributedString: attributedString, _textAligment: .center)
    }
}
