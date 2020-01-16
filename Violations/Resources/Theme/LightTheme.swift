//
//  LightTheme.swift
//  Violations
//
//  Created by Артем Загоскин on 22/06/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit

final class LightTheme: ThemeProtocol {
    var accent: UIColor = UIColor(named: "Accent")!
    var background: UIColor = UIColor(named: "Background")!
    var tabBarColor: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    var tabBarTintColor: UIColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    var textColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    var tableViewBackground: UIColor = #colorLiteral(red: 0, green: 0.5647058824, blue: 0.431372549, alpha: 1)
    var cellBackground: UIColor = .white
    var textfieldTextColor: UIColor = #colorLiteral(red: 0, green: 0.5647058824, blue: 0.431372549, alpha: 1)
    var trackingButton: UIColor = #colorLiteral(red: 0, green: 0.5647058824, blue: 0.431372549, alpha: 1)
}
