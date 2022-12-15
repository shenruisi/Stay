//
//  RoundedBorderView.swift
//  Stay
//
//  Created by Jin on 2022/11/27.
//

import UIKit

class RoundedBorderView: UIView {

    let borderColor: UIColor
    
    init(radius: CGFloat = 10, borderColor: UIColor = FCStyle.borderColor, borderWidth: CGFloat = 1, backgroundColor: UIColor = FCStyle.secondaryPopup) {
        self.borderColor = borderColor
        super.init(frame: .zero)
        
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = radius
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func tintColorDidChange() {
        self.layer.borderColor = borderColor.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
