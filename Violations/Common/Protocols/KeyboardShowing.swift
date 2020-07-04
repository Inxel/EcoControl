//
//  KeyboardShowing.swift
//  Violations
//
//  Created by Artyom Zagoskin on 16.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


protocol KeyboardShowing {
    var tapRecognizer: UITapGestureRecognizer { get set }
    func keyboardWillShow(keyboardHeight: CGFloat, with animationDuration: Double)
    func keyboardWillHide(with animationDuration: Double)
}


extension KeyboardShowing where Self: UIViewController {
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] notification in
            guard let self = self, let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let animationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
            
            self.keyboardWillShow(keyboardHeight: keyboardSize.height, with: animationDuration)
            self.view.addGestureRecognizer(self.tapRecognizer)
        }
        
        /// Keyboard will hide notification observer
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] notification in
            guard let self = self, let animationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
            
            self.keyboardWillHide(with: animationDuration)
            self.view.removeGestureRecognizer(self.tapRecognizer)
        }
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(keyboardHeight: CGFloat, with animationDuration: Double) {}
    func keyboardWillHide(with animationDuration: Double) {}

}

