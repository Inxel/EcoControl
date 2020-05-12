//
//  UIViewController+Initiate.swift
//  Violations
//
//  Created by Artyom Zagoskin on 16.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


extension UIViewController {
    
    static func instance() -> UIViewController {
        var name = storyboardID
        if let index = name.firstIndex(where: { !$0.isNumber && !$0.isLetter }) {
            name = String(name[..<index])
        }
        
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: name)
        return viewController
    }
    
    class var storyboardID: String {
        return "\(self)"
    }
    
    static func instantiate(from: AppStoryboard) -> Self {
        return from.viewController(viewControllerClass: self)
    }
    
}
