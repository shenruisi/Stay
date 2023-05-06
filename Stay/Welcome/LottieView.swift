//
//  CongratulationsLottieView.swift
//  Stay
//
//  Created by ris on 2023/5/5.
//

import UIKit
import Lottie


@objcMembers class LottieView: UIView {
    let lottieView = LottieAnimationView()
    init(animationName: String){
        super.init(frame: CGRectZero)
        let animation = LottieAnimation.named(animationName)
        lottieView.animation = animation
        self.addSubview(lottieView)
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        lottieView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true;
        lottieView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true;
        lottieView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true;
        lottieView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true;
    }
    
    func play(){
        lottieView.play()
    }
    
    func stop(){
        lottieView.stop()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
