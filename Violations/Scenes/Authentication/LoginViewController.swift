//
//  ViewController.swift
//  Violations
//
//  Created by Артем Загоскин on 07/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import Firebase


// MARK: - Constants

private enum Constants {
    static var signInViewHeight: CGFloat { 170 }
    static var defaultSignInViewBottomConstraint: CGFloat { (UIScreen.main.bounds.height - signInViewHeight) / 2 }
    static var keyboardOffset: CGFloat { 8 }
}


// MARK: - Base

final class LoginViewController: UIViewController, DefaultAlertShowing {
    
    // MARK: Outlets
    
    @IBOutlet private weak var emailTextfield: AuthenticationTextField! {
        didSet {
            emailTextfield.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    @IBOutlet private weak var passwordTextfield: AuthenticationTextField! {
        didSet {
            passwordTextfield.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    @IBOutlet private weak var signInViewHeight: NSLayoutConstraint! {
        didSet {
            signInViewHeight.constant = Constants.signInViewHeight
        }
    }
    @IBOutlet private weak var signInViewBottomConstraint: NSLayoutConstraint! {
        didSet {
            signInViewBottomConstraint.constant = Constants.defaultSignInViewBottomConstraint
        }
    }
    
    // MARK: Overriden Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    // MARK: Properties
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    private let themeManager: ThemeManager = .shared
    
    private var email: String?
    private var password: String?
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeManager.delegate = self
        themeDidChange()
        addObservers()
    }
    
    deinit { removeObservers() }
    
}


// MARK: - Actions

extension LoginViewController {
    
    @IBAction private func loginButtonTapped(_ sender: PrimaryButton) {
        if !CheckInternet.connection() {
            showAlert(message: "Internet connection issues", defaultButtonTitle: "ОK")
        } else {
            signIn(sender)
        }
    }
    
}


// MARK: - Theme Manager Delegate

extension LoginViewController: ThemeManagerDelegate {
    
    func themeDidChange() {
        changeStyleOf(emailTextfield, "Email")
        changeStyleOf(passwordTextfield, "Password")
        view.backgroundColor = themeManager.current.background
    }
    
}


//MARK: - Keyboard Showing

extension LoginViewController: UITextFieldDelegate, KeyboardShowing {
    
    func keyboardWillShow(keyboardHeight: CGFloat, with animationDuration: Double) {
        changeSignInViewBottomConstraint(keyboardHeight: keyboardHeight, with: animationDuration)
    }
    
    func keyboardWillHide(with animationDuration: Double) {
        changeSignInViewBottomConstraint(with: animationDuration)
    }

}


// MARK: - TextField Delegate

extension LoginViewController {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done {
            textField.resignFirstResponder()
        } else if textField == emailTextfield {
            passwordTextfield.becomeFirstResponder()
        }
        
        return true
    }
    
}


// MARK: - Private API

extension LoginViewController {
    
    private func changeSignInViewBottomConstraint(keyboardHeight: CGFloat = 0, with animationDuration: Double) {
        let keyboardHeightWithOffset = keyboardHeight + Constants.keyboardOffset
        
        if keyboardHeightWithOffset >= Constants.defaultSignInViewBottomConstraint {
            signInViewBottomConstraint.constant = keyboardHeightWithOffset
        } else {
            signInViewBottomConstraint.constant = Constants.defaultSignInViewBottomConstraint
        }
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    private func signIn(_ sender: PrimaryButton) {
        sender.startAnimation()
        guard
            let email = emailTextfield.text,
            let password = passwordTextfield.text
            else { sender.stopAnimation(animationStyle: .shake, completion: nil); return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
        
            if error != nil {
                sender.stopAnimation(animationStyle: .shake, completion: nil)
            } else {
                print("Log in successful!")
                sender.stopAnimation(animationStyle: .normal)
        
                UIApplication.setRootView(TabBarController.instantiate(from: .Main), options: UIApplication.loginAnimation)
            }
        
        }
    }
    
    private func changeStyleOf(_ textfield: UITextField, _ placeholder: String) {
        textfield.backgroundColor = themeManager.current.background
        textfield.textColor = themeManager.current.textfieldTextColor
        textfield.attributedPlaceholder = .init(string: placeholder, attributes: [.foregroundColor: themeManager.current.textfieldTextColor])
    }
    
}
