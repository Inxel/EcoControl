//
//  ViewController.swift
//  Violations
//
//  Created by Артем Загоскин on 09/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ChangeDataViewController: UIViewController {
    
    var data = ""
    private var user = Auth.auth().currentUser
    private var credintial: AuthCredential?
    
    @IBOutlet weak var screenLabel: UILabel! {
        didSet {
            screenLabel.text = "Change \(data)"
        }
    }
    
    @IBOutlet weak var oldDataTextfield: UITextField! {
        didSet {
            oldDataTextfield.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            propertiesOf(oldDataTextfield)
            oldDataTextfield.placeholder = "Current password"
            oldDataTextfield.keyboardType = .default
            oldDataTextfield.isSecureTextEntry = true
        }
    }

    @IBOutlet weak var newDataTextfield: UITextField! {
        didSet {
            newDataTextfield.placeholder = "New \(data)"
            newDataTextfield.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            propertiesOf(newDataTextfield)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.setDefaultStyle(.dark)
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        SVProgressHUD.show()
        let eMail = EmailAuthProvider.credential(withEmail: (user?.email)!, password: oldDataTextfield.text!)
        
        Auth.auth().currentUser?.reauthenticateAndRetrieveData(with: eMail) { (AuthDataResult, Error) in
            if Error != nil {
                SVProgressHUD.showError(withStatus: "Error")
            } else {
                if self.data == "email" {
                    self.updateEmail()
                } else {
                    self.updatePassword()
                }
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func propertiesOf(_ textfield: UITextField) {
        textfield.clipsToBounds = true
        textfield.layer.cornerRadius = 15
        textfield.layer.borderWidth = 1
        textfield.layer.borderColor = #colorLiteral(red: 0, green: 0.5590047836, blue: 0.007364124991, alpha: 1)
        if data == "password" {
            textfield.keyboardType = .default
            textfield.isSecureTextEntry = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        oldDataTextfield.endEditing(true)
        newDataTextfield.endEditing(true)
    }
}



extension ChangeDataViewController {
    
    func updateEmail() {
        user?.updateEmail(to: newDataTextfield.text!) { error in
            if error != nil {
                print(error!)
                SVProgressHUD.showError(withStatus: "Error")
            } else {
                print("CHANGED EMAIL")
                let uid = Auth.auth().currentUser!.uid
                let thisUserRef = Database.database().reference().child("users").child(uid)
                let thisUserEmailRef = thisUserRef.child("email")
                thisUserEmailRef.setValue(self.newDataTextfield.text!)
                self.user = Auth.auth().currentUser
                SVProgressHUD.showSuccess(withStatus: "Successful")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func updatePassword() {
        user?.updatePassword(to: newDataTextfield.text!) { (error) in
            if error != nil {
                print(error!)
                SVProgressHUD.showError(withStatus: "Error")
            } else {
                print("CHANGED PASSWORD")
                let uid = Auth.auth().currentUser!.uid
                let thisUserRef = Database.database().reference().child("users").child(uid)
                let thisUserPasswordRef = thisUserRef.child("password")
                thisUserPasswordRef.setValue(self.newDataTextfield.text!)
                SVProgressHUD.showSuccess(withStatus: "Successful")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

}
