//
//  Bindable.swift
//  Tinder
//
//  Created by Juliano Alvarenga on 04/03/19.
//  Copyright © 2019 Juliano Alvarenga. All rights reserved.
//

import Foundation

class Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }
    
    var observer: ((T?) -> ())?
    
    func bind(observer: @escaping (T?) -> ()) {
        self.observer = observer
    }
}
