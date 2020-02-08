//
//  ThemeManager.swift
//  Violations
//
//  Created by Artyom Zagoskin on 08.02.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import Foundation


protocol ThemeManagerDelegate {
    func themeDidChange()
}


final class ThemeManager {
    
    // MARK: Singleton
    
    static var shared = ThemeManager()
    private init() {}
    
    @Multicast var delegate: ThemeManagerDelegate
    
    private var isLightTheme: Bool = true {
        didSet {
            $delegate.invoke { $0.themeDidChange() }
        }
    }
    
    var current: ThemeProtocol { isLightTheme ? LightTheme() : DarkTheme() }
}


// MARK: - Public API

extension ThemeManager {
    
    func changeTheme(isLightTheme: Bool) {
        self.isLightTheme = isLightTheme
    }
    
}
