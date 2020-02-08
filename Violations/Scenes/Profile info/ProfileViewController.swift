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
        }
    }
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Properties
    
    private let themeManager: ThemeManager = .shared
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveMarkers()
        themeManager.delegate = self
        themeDidChange()
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
    
}


// MARK: - Theme Managert Delegate

extension ProfileViewController: ThemeManagerDelegate {
    
    func themeDidChange() {
        view.backgroundColor = themeManager.current.background
        infoLabel.textColor = themeManager.current.textColor
    }
    
}


//MARK: - Private API

extension ProfileViewController {
    
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
