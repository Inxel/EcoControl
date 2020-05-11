//
//  ThemeManager.swift
//  Violations
//
//  Created by Artyom Zagoskin on 08.02.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


protocol ThemeManagerDelegate {
    func themeDidChange()
}


final class ThemeManager {
    
    // MARK: Singleton
    
    static var shared = ThemeManager()
    private init() {}
    
    @Multicast var delegate: ThemeManagerDelegate
    
    @UserDefault("isLightTheme", true) private(set) var isLightTheme: Bool {
        didSet {
            $delegate.invoke { $0.themeDidChange() }
        }
    }
    @UserDefault("useSystemTheme", true) private(set) var useSystemTheme: Bool
    
    var preferredStatusBarStyle: UIStatusBarStyle { isLightTheme ? .darkContent : .lightContent }
    var current: ThemeProtocol { isLightTheme ? LightTheme() : DarkTheme() }
}


// MARK: - Public API

extension ThemeManager {
    
    func changeTheme(isLightTheme: Bool) {
        self.isLightTheme = isLightTheme
    }
    
    func changeThemeSource(useSystemTheme: Bool, systemThemeIsLight: Bool) {
        self.useSystemTheme = useSystemTheme
        changeTheme(isLightTheme: systemThemeIsLight)
    }
    
}
