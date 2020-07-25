//
//  UIAlertAction+Color.swift
//  Violations
//
//  Created by Artyom Zagoskin on 25.07.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


extension UIAlertAction {
    
    func changeColor(to color: UIColor?) {
        guard let color = color else { return }
        setValue(color, forKey: "titleTextColor")
    }
    
}
