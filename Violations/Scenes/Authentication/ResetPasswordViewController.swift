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
            emailTextfield.backgroundColor = Theme.current.background
            emailTextfield.textColor = Theme.current.textfieldTextColor
            emailTextfield.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: Theme.current.textfieldTextColor])
        }
    }
    
    @IBOutlet private weak var enterEmailLabel: UILabel! {
        didSet {
            enterEmailLabel.textColor = Theme.current.textColor
        }
    }
    
    @IBOutlet weak var sendButtonBottomConstraint: NSLayoutConstraint!
    
    // MARK: Properties
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    // MARK: Life Style
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.current.background
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
        
    }
    
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


// MARK: - Private API

extension ResetPasswordViewController {
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func changeSendButtonBottomConstraint(keyboardHeight: CGFloat = 0, with animationDuration: Double) {
        sendButtonBottomConstraint.constant = keyboardHeight + Constants.sendButtonBottomConstraint
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
}
