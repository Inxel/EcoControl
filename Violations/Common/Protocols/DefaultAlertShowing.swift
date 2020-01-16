//
//  AlertShowing.swift
//  Violations
//
//  Created by Artyom Zagoskin on 16.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


protocol DefaultAlertShowing: class {
    func showAlert(title: String?, message: String?, defaultButtonTitle: String, cancelButtonTitle: String?, alertHandler: Handler<UIAlertAction>?)
}


extension DefaultAlertShowing where Self: UIViewController {
    
    func showAlert(title: String? = nil, message: String? = nil, defaultButtonTitle: String, cancelButtonTitle: String? = nil, alertHandler: Handler<UIAlertAction>? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: defaultButtonTitle, style: .default, handler: alertHandler))
        
        if cancelButtonTitle != nil {
            alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: nil))
        }
        
        present(alert, animated: true)
    }
    
}

