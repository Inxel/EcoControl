//
//  UIApplication+SettingRootView.swift
//  Violations
//
//  Created by Artyom Zagoskin on 16.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


extension UIApplication {
    
    static private(set) var loginAnimation: UIView.AnimationOptions = .transitionFlipFromRight
    static private(set) var logoutAnimation: UIView.AnimationOptions = .transitionFlipFromLeft
    static private(set) var keyWindow: UIWindow? = shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
    
    static func setRootView(_ viewController: UIViewController,
                                   options: UIView.AnimationOptions = .transitionFlipFromRight,
                                   animated: Bool = true,
                                   duration: TimeInterval = 0.5,
                                   completion: DefaultHandler? = nil) {
        guard animated, let keyWindow = keyWindow else {
            UIApplication.keyWindow?.rootViewController = viewController
            return
        }
        
        UIView.transition(with: keyWindow, duration: duration, options: options, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            keyWindow.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
        }) { _ in
            completion?()
        }
    }
}
