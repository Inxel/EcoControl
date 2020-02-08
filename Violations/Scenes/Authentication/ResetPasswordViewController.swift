//
//  ResetPasswordViewController.swift
//  Violations
//
//  Created by Артем Загоскин on 20/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import Firebase


// MARK: - Constants

private enum Constants {
    static var sendButtonBottomConstraint: CGFloat { 20 }
    static var safeAreaInset: CGFloat {
        if #available(iOS 11.0, *) { return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0 }
        return 0
    }
}


// MARK: - Base

final class ResetPasswordViewController: UIViewController, ProgressHUDShowing {
    
    // MARK: Outlets
    
    @IBOutlet private weak var emailTextfield: AuthenticationTextField! {
        didSet {
            emailTextfield.backgroundColor = themeManager.current.background
            emailTextfield.textColor = themeManager.current.textfieldTextColor
            emailTextfield.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: themeManager.current.textfieldTextColor])
        }
    }
    
    @IBOutlet private weak var enterEmailLabel: UILabel! {
        didSet {
            enterEmailLabel.textColor = themeManager.current.textColor
        }
    }
    
    @IBOutlet weak var sendButtonBottomConstraint: NSLayoutConstraint!
    
    // MARK: Properties
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    private let themeManager: ThemeManager = .shared
    
    // MARK: Life Style
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeManager.delegate = self
        addObservers()
        view.backgroundColor = themeManager.current.background
    }
    
    deinit { removeObservers() }
    
}


// MARK: - Actions

extension ResetPasswordViewController {
    
    @IBAction private func sendTapped(_ sender: PrimaryButton) {
        
        if let text = emailTextfield.text, !text.isEmpty {
            sender.startAnimation()
            
            Auth.auth().sendPasswordReset(withEmail: text) { error in
                if error != nil {
                    sender.stopAnimation(animationStyle: .shake) {
                        self.showProgressHUDError(with: "Your email doesn't exist in EcoControl")
                        self.dismissProgressHUD()
                    }
                } else {
                    self.dismissKeyboard()
                    self.navigationController?.popToRootViewController(animated: true)
                    self.showProgressHUDSuccess(with: "Check your email!")
                }
                
            }
        } else {
            showProgressHUDError(with: "Please, enter email")
        }
        
        dismissProgressHUD()
    }
    
}


// MARK: - Keyboard Showing

extension ResetPasswordViewController: KeyboardShowing {
    
    func keyboardWillShow(keyboardHeight: CGFloat, with animationDuration: Double) {
        changeSendButtonBottomConstraint(keyboardHeight: keyboardHeight - Constants.safeAreaInset, with: animationDuration)
    }
    
    func keyboardWillHide(with animationDuration: Double) {
        changeSendButtonBottomConstraint(with: animationDuration)
    }
    
}


// MARK: - Theme Manager Delegate

extension ResetPasswordViewController: ThemeManagerDelegate {
    
    func themeDidChange() {
        emailTextfield.backgroundColor = themeManager.current.background
        emailTextfield.textColor = themeManager.current.textfieldTextColor
        emailTextfield.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: themeManager.current.textfieldTextColor])
        enterEmailLabel.textColor = themeManager.current.textColor
        view.backgroundColor = themeManager.current.background
    }
    
}


// MARK: - Private API

extension ResetPasswordViewController {
    
    private func changeSendButtonBottomConstraint(keyboardHeight: CGFloat = 0, with animationDuration: Double) {
        sendButtonBottomConstraint.constant = keyboardHeight + Constants.sendButtonBottomConstraint
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
}
