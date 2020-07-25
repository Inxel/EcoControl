//
//  ResetPasswordViewController.swift
//  Violations
//
//  Created by Артем Загоскин on 20/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import Firebase


// MARK: - Base

final class ResetPasswordViewController: UIViewController, ProgressHUDShowing {
    
    // MARK: Outlets
    
    @IBOutlet private weak var emailTextfield: AuthenticationTextField! {
        didSet {
            emailTextfield.backgroundColor = themeManager.current.background
            emailTextfield.textColor = themeManager.current.textfieldTextColor
            emailTextfield.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [.foregroundColor: themeManager.current.textfieldTextColor])
        }
    }
    @IBOutlet private weak var enterEmailLabel: UILabel! {
        didSet {
            enterEmailLabel.textColor = themeManager.current.textColor
        }
    }
    @IBOutlet private weak var sendButton: PrimaryButton!
    
    // MARK: Overridden Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
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
        addKeyboardObservers()
        view.backgroundColor = themeManager.current.background
    }
    
    deinit { removeKeyboardObservers() }
    
}


// MARK: - Actions

extension ResetPasswordViewController {
    
    @IBAction private func sendTapped(_ sender: PrimaryButton) {
        
        if let text = emailTextfield.text, !text.isEmpty {
            sender.startAnimation()
            
            Auth.auth().sendPasswordReset(withEmail: text) { error in
                if error != nil {
                    sender.stopAnimation(animationStyle: .shake) {
                        self.showProgressHUDError(with: error?.localizedDescription)
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
        
        dismissProgressHUD(after: 2)
    }
    
}


// MARK: - Keyboard Showing

extension ResetPasswordViewController: KeyboardShowing {
    
    func keyboardWillShow(keyboardHeight: CGFloat, with animationDuration: Double) {
        sendButton.transform = .init(translationX: .zero, y: -(keyboardHeight - safeAreaBottomInset))
    }
    
    func keyboardWillHide(with animationDuration: Double) {
        sendButton.transform = .identity
    }
    
}


// MARK: - Theme Manager Delegate

extension ResetPasswordViewController: ThemeManagerDelegate {
    
    func themeDidChange() {
        emailTextfield.backgroundColor = themeManager.current.background
        emailTextfield.textColor = themeManager.current.textfieldTextColor
        emailTextfield.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [.foregroundColor: themeManager.current.textfieldTextColor])
        enterEmailLabel.textColor = themeManager.current.textColor
        view.backgroundColor = themeManager.current.background
    }
    
}
