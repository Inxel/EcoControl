//
//  ProfileViewController.swift
//  Violations
//
//  Created by Артем Загоскин on 07/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import Firebase


final class ProfileViewController: UIViewController, ProgressHUDShowing {
    
    // MARK: Outlets
    
    @IBOutlet private weak var logoutButton: PrimaryButton! {
        didSet {
            logoutButton.layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        }
    }
    
    @IBOutlet private weak var infoLabel: UILabel! {
        didSet {
            infoLabel.text = ""
            infoLabel.textColor = Theme.current.textColor
        }
    }
    
    @IBOutlet private weak var themeLabel: UILabel! {
        didSet {
            themeLabel.textColor = Theme.current.textColor
        }
    }
    @IBOutlet private weak var themeSwitcher: UISwitch! {
        didSet {
            themeSwitcher.isOn = !Theme.isLightTheme
        }
    }
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveMarkers()
        
        applyTheme()
    }
    
}


// MARK: - Actions

extension ProfileViewController {
    
    @IBAction private func logoutPressed(_ sender: PrimaryButton) {
        sender.startAnimation()
        do {
            try Auth.auth().signOut()
            UIApplication.setRootView(NavigationViewController.instantiate(from: .Login), options: UIApplication.logoutAnimation)
        }
        catch {
            sender.stopAnimation(animationStyle: .shake) {
                self.showProgressHUDError(with: "Something went wrong")
                self.dismissProgressHUD()
            }
        }

    }
    
    @IBAction private func changeTheme(_ sender: UISwitch) {
        Theme.isLightTheme = !sender.isOn
        
        applyTheme()
    }
    
}


//MARK: - Private API

extension ProfileViewController {
    
    private func applyTheme() {
        view.backgroundColor = Theme.current.background
        themeLabel.textColor = Theme.current.textColor
        infoLabel.textColor = Theme.current.textColor
        self.tabBarController?.tabBar.barTintColor = Theme.current.tabBarColor
        self.tabBarController?.tabBar.unselectedItemTintColor = Theme.current.tabBarTintColor
    }
    
    private func retrieveMarkers() {
        let user = Auth.auth().currentUser
        var numberOfMarkers = 0
        
        TakeMarkersFromFirebase.downloadMarkers(child: "Markers") {snapshotValue in
            let sender = snapshotValue["Sender"]!
            if sender == user?.email {
                numberOfMarkers += 1
            }
            self.activityIndicator.stopAnimating()
            self.infoLabel.text = self.getInfoLabelText(with: numberOfMarkers)
        }
    }
    
    private func getInfoLabelText(with numberOfMarkers: Int) -> String {
        switch numberOfMarkers {
        case 0:
            return "You haven't reported any violations yet"
        case 1:
            return "You marked 1 violation!\nThanks for help!"
        default:
            return "You marked \(numberOfMarkers) violations!\nThanks for help!"
        }
    }
    
}
