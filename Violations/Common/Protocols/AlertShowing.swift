//
//  AlertShowing.swift
//  Violations
//
//  Created by Artyom Zagoskin on 16.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


protocol AlertShowing: class {}


extension AlertShowing where Self: UIViewController {
    
    func showAlert(title: String? = nil, message: String? = nil, defaultButtonTitle: String? = nil, defaultButtonColor: UIColor? = nil, cancelButtonTitle: String? = nil, cancelButtonColor: UIColor? = nil, alertHandler: Handler<UIAlertAction>? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let defaultButtonTitle = defaultButtonTitle {
            let action = UIAlertAction(title: defaultButtonTitle, style: .default, handler: alertHandler)
            action.changeColor(to: defaultButtonColor)
            
            alert.addAction(action)
        }
        
        if let cancelButtonTitle = cancelButtonTitle {
            let action = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: nil)
            action.changeColor(to: cancelButtonColor)
            
            alert.addAction(action)
        }
        
        present(alert, animated: true)
    }
    
}

