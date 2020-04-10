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
    
    private var themeManager: ThemeManager { .shared }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeManager.delegate = self
        self.delegate = self
        if themeManager.useSystemTheme {
            themeManager.changeTheme(isLightTheme: traitCollection.isLightInterface)
        } else {
            themeManager.changeTheme(isLightTheme: themeManager.isLightTheme)
        }
        
    }
    
    // MARK: Overriden API
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard themeManager.useSystemTheme else { return }
        themeManager.changeTheme(isLightTheme: traitCollection.isLightInterface)
    }
    
}


// MARK: - Theme Manager Delegate

extension TabBarController: ThemeManagerDelegate {
    
    func themeDidChange() {
        tabBar.barTintColor = themeManager.current.background
        tabBar.unselectedItemTintColor = themeManager.current.tabBarTintColor
    }
    
}
