//
//  TabBarController.swift
//  Violations
//
//  Created by Артем Загоскин on 07/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit


final class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        tabBar.barTintColor = Theme.current.background
        tabBar.unselectedItemTintColor = Theme.current.tabBarTintColor
    }
    
}
