//
//  UIViewController+DismissingKeyboard.swift
//  Violations
//
//  Created by Artyom Zagoskin on 25.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


extension UIViewController {
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
