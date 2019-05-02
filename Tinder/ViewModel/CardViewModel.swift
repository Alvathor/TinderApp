//
//  CardViewModel.swift
//  Tinder
//
//  Created by Juliano Alvarenga on 26/02/19.
//  Copyright © 2019 Juliano Alvarenga. All rights reserved.
//

import SDWebImage

protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}

class CardViewModel {
    let uid: String
    let imageNames: [String]
    let attributedString: NSAttributedString
    let textAligment: NSTextAlignment
    var imageIndexObserver: ((String?, Int) -> ())?
    
    fileprivate var imageIndex = 0 {
        didSet {
            let imageUrl = imageNames[imageIndex]
            imageIndexObserver?(imageUrl, imageIndex)
        }
    }    
        
    init(uid: String, _imageNames: [String], _attributedString: NSAttributedString, _textAligment: NSTextAlignment) {
        self.uid = uid
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

