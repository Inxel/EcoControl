//
//  LoadingLayer.swift
//  Violations
//
//  Created by Artyom Zagoskin on 12.04.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


final class LoadingLayer: CAShapeLayer {
    
    convenience init(withBounds bounds: CGRect) {
        self.init()
        let circlePath = UIBezierPath(ovalIn: bounds.insetBy(dx: bounds.width * 0.25, dy: bounds.height * 0.25))
        path = circlePath.cgPath
        fillColor = UIColor.clear.cgColor
        strokeColor = UIColor.loadingCircle.cgColor
        lineWidth = 2

        let startAnimation = CABasicAnimation(keyPath: "strokeStart")
        startAnimation.fromValue = -0.5
        startAnimation.toValue = 1

        let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
        endAnimation.fromValue = 0
        endAnimation.toValue = 1
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [startAnimation, endAnimation]
        animationGroup.duration = 2
        animationGroup.repeatCount = .infinity
        
        add(animationGroup, forKey: nil)
    }
    
}
