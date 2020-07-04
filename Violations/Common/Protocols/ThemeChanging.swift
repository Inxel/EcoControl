//
//  ThemeChanging.swift
//  Violations
//
//  Created by Artyom Zagoskin on 04.07.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import Foundation


@objc protocol ThemeChanging {
    func themeDidChange()
}

extension ThemeChanging {
    
    func addThemeChangingObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
    }
    
    func removeThemeChangingObservers() {
        NotificationCenter.default.removeObserver(self, name: .themeDidChange, object: nil)
    }
    
}
