//
//  NavigationController.swift
//  Violations
//
//  Created by Артем Загоскин on 12/05/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit


final class NavigationViewController: UINavigationController {

    // MARK: Properties
    
    private var themeManager: ThemeManager { .shared }
    
    // MARK: - Overridden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeManager.changeTheme(isLightTheme: traitCollection.userInterfaceStyle == .light)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        themeManager.changeTheme(isLightTheme: traitCollection.userInterfaceStyle == .light)
    }
    
}
