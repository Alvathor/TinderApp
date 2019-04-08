//
//  AgeRangeCell.swift
//  Tinder
//
//  Created by Juliano Alvarenga on 06/04/19.
//  Copyright © 2019 Juliano Alvarenga. All rights reserved.
//

import UIKit

class AgeRangeCell: UITableViewCell {
    
    let minLabel: UILabel = {
        let c = AgeRangeLabel()
        c.text = "Min 88"
        return c
    }()
    
    let maxLabel: UILabel = {
        let c = AgeRangeLabel()
        c.text = "Max 88"
        return c
    }()
    
    let minSlider: UISlider = {
        let c = UISlider()
        c.minimumValue = 18
        c.maximumValue = 100
        return c
    }()
    
    let maxSlider: UISlider = {
        let c = UISlider()
        c.minimumValue = 18
        c.maximumValue = 100
        return c
    }()
    
    class AgeRangeLabel: UILabel {
        override var intrinsicContentSize: CGSize {
            return .init(width: 80, height: 0)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let mainStackView = UIStackView.init(arrangedSubviews: [
           UIStackView.init(arrangedSubviews: [minLabel, minSlider]),
           UIStackView.init(arrangedSubviews: [maxLabel, maxSlider])
        ])
        mainStackView.axis = .vertical
        mainStackView.spacing = 16
        addSubview(mainStackView)
        mainStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets.init(top: 16, left: 16, bottom: 16, right: 16))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
