//
//  Theme.swift
//  Violations
//
//  Created by Артем Загоскин on 22/06/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit

final class Theme {
    static var current: ThemeProtocol { isLightTheme ? LightTheme() : DarkTheme() }
    
    @UserDefault("LightTheme", true) static var isLightTheme: Bool
}
