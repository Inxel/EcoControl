//
//  ProfileViewController.swift
//  Violations
//
//  Created by Артем Загоскин on 07/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ProfileViewController: UIViewController {

    private var numberOfMarkers = 0
    private var user = Auth.auth().currentUser
    
    @IBOutlet weak var logoutButton: PrimaryButton! {
        didSet {
            logoutButton.layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        }
    }
    
    @IBOutlet weak var infoLabel: UILabel! {
        didSet {
            infoLabel.text = ""
            infoLabel.textColor = Theme.current.textColor
        }
    }
    
    @IBOutlet weak var themeLabel: UILabel! {
        didSet {
            themeLabel.textColor = Theme.current.textColor
        }
    }
    @IBOutlet weak var themeSwitcher: UISwitch! {
        didSet {
            if UserDefaults.standard.object(forKey: "LightTheme") != nil {
                themeSwitcher.isOn = !UserDefaults.standard.bool(forKey: "LightTheme")
            }
        }
    }
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.setDefaultStyle(.dark)
        retrieveMarkers()
        
        applyTheme()
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        logoutButton.startAnimation()
        do {
            try Auth.auth().signOut()
        UIApplication.setRootView(NavigationViewController.instantiate(from: .Login), options: UIApplication.logoutAnimation)

        }
        catch {
            logoutButton.stopAnimation(animationStyle: .shake) {
                SVProgressHUD.showError(withStatus: "Something went wrong")
                self.dismissProgressHud()
            }
        }

    }
    
    @IBAction func changeTheme(_ sender: UISwitch) {
        Theme.current = sender.isOn ? DarkTheme() : LightTheme()
        
        UserDefaults.standard.set(!sender.isOn, forKey: "LightTheme")
        
        applyTheme()
    }
    
    func retrieveMarkers() {
        
        TakeMarkersFromFirebase.downloadMarkers(child: "Markers") {snapshotValue in
            let sender = snapshotValue["Sender"]!
            if sender == self.user?.email {
                self.numberOfMarkers += 1
            }
            self.activityIndicator.stopAnimating()
            self.infoLabel.text = self.numberOfMarkersInfo()
        }
    }
    
    func numberOfMarkersInfo() -> String {
        switch self.numberOfMarkers {
        case 0:
            return "You haven't reported any violations yet"
        case 1:
            return "You marked 1 violation!\nThanks for help!"
        default:
            return "You marked \(self.numberOfMarkers) violations!\nThanks for help!"
        }
    }
}


//MARK: - Show error with SVProgressHUD

extension ProfileViewController {
    
    func dismissProgressHud() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            SVProgressHUD.dismiss()
        }
    }
    
}


//MARK: - Change theme

extension ProfileViewController {
    func applyTheme() {
        view.backgroundColor = Theme.current.background
        themeLabel.textColor = Theme.current.textColor
        infoLabel.textColor = Theme.current.textColor
        self.tabBarController?.tabBar.barTintColor = Theme.current.tabBarColor
        self.tabBarController?.tabBar.unselectedItemTintColor = Theme.current.tabBarTintColor
    }
}
