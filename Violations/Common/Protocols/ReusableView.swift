//
//  ReusableView.swift
//  Violations
//
//  Created by Artyom Zagoskin on 16.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


protocol ReusableView: class {}


extension ReusableView where Self: UIView {
    static var reuseID: String { return .init(describing: self) }
}
