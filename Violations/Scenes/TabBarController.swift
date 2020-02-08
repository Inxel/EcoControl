//
//  TabBarController.swift
//  Violations
//
//  Created by Артем Загоскин on 07/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit


final class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: Properties
    
    private let themeManager: ThemeManager = .shared
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeManager.delegate = self
        themeManager.changeTheme(isLightTheme: traitCollection.userInterfaceStyle == .light)
//        themeManager.isLightTheme = traitCollection.userInterfaceStyle == .light
        self.delegate = self
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        themeManager.changeTheme(isLightTheme: traitCollection.userInterfaceStyle == .light)
    }
    
}


// MARK: - Theme Manager Delegate

extension TabBarController: ThemeManagerDelegate {
    
    func themeDidChange() {
        tabBar.barTintColor = themeManager.current.background
        tabBar.unselectedItemTintColor = themeManager.current.tabBarTintColor
    }
    
}
