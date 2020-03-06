//
//  StatusBarAppearance.swift
//  Violations
//
//  Created by Artyom Zagoskin on 06.03.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


extension UITabBarController {
    
    open override var childForStatusBarStyle: UIViewController? {
        selectedViewController?.childForStatusBarStyle ?? selectedViewController
    }
    
}


extension UINavigationController {
    
    open override var childForStatusBarStyle: UIViewController? {
        topViewController?.childForStatusBarStyle ?? topViewController
    }
    
}

