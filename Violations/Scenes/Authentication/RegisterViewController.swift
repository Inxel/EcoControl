//
//  RegisterViewController.swift
//  Violations
//
//  Created by Артем Загоскин on 07/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import Firebase


// MARK: - Constants

private enum Constants {
    static var signUpViewHeight: CGFloat { 218 }
    static var defaultSignUpViewBottomConstraint: CGFloat { (UIScreen.main.bounds.height - signUpViewHeight) / 2 }
    static var keyboardOffset: CGFloat { 8 }
}


// MARK: - Base

final class RegisterViewController: UIViewController, UITextFieldDelegate, ProgressHUDShowing {
    
    // MARK: Outlets
    
    @IBOutlet private weak var emailTextfield: AuthenticationTextField! {
        didSet {
            styleOf(emailTextfield, "Email")
            emailTextfield.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    @IBOutlet private weak var passwordTextfield: AuthenticationTextField! {
        didSet {
            styleOf(passwordTextfield, "Password")
            passwordTextfield.layer.cornerRadius = 0
        }
    }
    
    @IBOutlet private weak var confirmPasswordTextfield: AuthenticationTextField! {
        didSet {
            styleOf(confirmPasswordTextfield, "Confirm password")
            confirmPasswordTextfield.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }

    @IBOutlet private weak var signUpViewHeight: NSLayoutConstraint! {
        didSet {
            signUpViewHeight.constant = Constants.signUpViewHeight
        }
    }
    @IBOutlet weak var signUpViewBottomConstraint: NSLayoutConstraint! {
        didSet {
            signUpViewBottomConstraint.constant = Constants.defaultSignUpViewBottomConstraint
        }
    }
    
    // MARK: Properties
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    private let themeManager: ThemeManager = .shared
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeManager.delegate = self
        addObservers()
        view.backgroundColor = themeManager.current.background
    }
    
    deinit { removeObservers() }

}


// MARK: - Actions

extension RegisterViewController {
    
    @IBAction private func registerButtonTapped(_ sender: PrimaryButton) {
        
        sender.startAnimation()
        
        guard
            let email = emailTextfield.text,
            let password = passwordTextfield.text,
            let confirmationPassword = confirmPasswordTextfield.text,
            !email.isEmpty,
            !password.isEmpty,
            !confirmationPassword.isEmpty
        else { sender.stopAnimation(animationStyle: .shake); return }

        guard password == confirmationPassword else {
            sender.stopAnimation(animationStyle: .shake)
            showProgressHUDError(with: "Password and confirmation password do not match")
            dismissProgressHUD()
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                
            if let error = error {
                sender.stopAnimation(animationStyle: .shake) {
                    self.showProgressHUDError(with: error.localizedDescription)
                    self.dismissProgressHUD()
                }
            } else {
                print("Registration Successful!")
                sender.stopAnimation(animationStyle: .normal, completion: nil)
                UIApplication.setRootView(TabBarController.instantiate(from: .Main), options: UIApplication.loginAnimation)
            }
        }
    }
    
}


// MARK: - Keyboard Showing

extension RegisterViewController: KeyboardShowing {
    
    func keyboardWillShow(keyboardHeight: CGFloat, with animationDuration: Double) {
        changeSignUpViewBottomConstraint(keyboardHeight: keyboardHeight, with: animationDuration)
    }
    
    func keyboardWillHide(with animationDuration: Double) {
        changeSignUpViewBottomConstraint(with: animationDuration)
    }
    
}


// MARK: - Theme Manager Delegate

extension RegisterViewController: ThemeManagerDelegate {
    
    func themeDidChange() {
        view.backgroundColor = themeManager.current.background
        styleOf(emailTextfield, "Email")
        styleOf(passwordTextfield, "Password")
        styleOf(confirmPasswordTextfield, "Confirm password")
    }
    
}


// MARK: - Private API

extension RegisterViewController {
    
    private func changeSignUpViewBottomConstraint(keyboardHeight: CGFloat = 0, with animationDuration: Double) {
        let keyboardHeightWithOffset = keyboardHeight + Constants.keyboardOffset
        
        if keyboardHeightWithOffset >= Constants.defaultSignUpViewBottomConstraint {
            signUpViewBottomConstraint.constant = keyboardHeightWithOffset
        } else {
            signUpViewBottomConstraint.constant = Constants.defaultSignUpViewBottomConstraint
        }
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func styleOf(_ textfield: UITextField, _ placeholder: String) {
        textfield.backgroundColor = themeManager.current.background
        textfield.textColor = themeManager.current.textfieldTextColor
        textfield.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: themeManager.current.textfieldTextColor])
    }
    
}
