//
//  CardViewModel.swift
//  Tinder
//
//  Created by Juliano Alvarenga on 26/02/19.
//  Copyright © 2019 Juliano Alvarenga. All rights reserved.
//

import UIKit
import SDWebImage

protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}

class CardViewModel {
    let imageNames: [String]
    let attributedString: NSAttributedString
    let textAligment: NSTextAlignment
    var imageIndexObserver: ((UIImage?, Int) -> ())?    
    
    fileprivate var imageIndex = 0 {
        didSet {
            let imageName = URL(string: imageNames[imageIndex])
            
            let image = UIImageView()
            image.sd_setImage(with: imageName)
            imageIndexObserver?(image.image, imageIndex)
        }
    }
    
    
        
    init(_imageNames: [String], _attributedString: NSAttributedString, _textAligment: NSTextAlignment) {
        self.imageNames = _imageNames
        self.attributedString = _attributedString
        self.textAligment = _textAligment
    }    
    
    func advanceToNexPhoto() {
        imageIndex = min(imageIndex + 1, imageNames.count - 1)
    }
    
    func goToPrevioushoto() {
        imageIndex = max(0, imageIndex - 1)
    }
}

