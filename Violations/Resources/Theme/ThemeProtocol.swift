//
//  ThemeProtocol.swift
//  Violations
//
//  Created by Артем Загоскин on 22/06/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit

protocol ThemeProtocol {
    var background: UIColor { get }
    var tabBarColor: UIColor { get }
    var tabBarTintColor: UIColor { get }
    var textColor: UIColor { get }
    var tableViewBackground: UIColor { get }
    var cellBackground: UIColor { get }
    var textfieldTextColor: UIColor { get }
    var trackingButton: UIColor { get }
}
