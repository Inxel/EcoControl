//
//  Color+CustomInits.swift
//  Violations
//
//  Created by Artyom Zagoskin on 10.04.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


extension UIColor {
    
    convenience init(r: Int, g: Int, b: Int, a: CGFloat) {
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: a)
    }
    
}
