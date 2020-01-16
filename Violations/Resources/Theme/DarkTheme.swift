//
//  DarkTheme.swift
//  Violations
//
//  Created by Артем Загоскин on 22/06/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit

final class DarkTheme: ThemeProtocol {
    var accent: UIColor = UIColor(named: "Background")!
    var background: UIColor = UIColor(named: "Accent")!
    var tabBarColor: UIColor = #colorLiteral(red: 0.2290914655, green: 0.2301582694, blue: 0.2327426076, alpha: 1)
    var tabBarTintColor: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    var textColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var tableViewBackground: UIColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
    var cellBackground: UIColor = #colorLiteral(red: 0, green: 0.5647058824, blue: 0.431372549, alpha: 1)
    var textfieldTextColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var trackingButton: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
}
