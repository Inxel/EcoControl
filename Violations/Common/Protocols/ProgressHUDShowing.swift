//
//  ProgressHUDShowing.swift
//  Violations
//
//  Created by Artyom Zagoskin on 16.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import SVProgressHUD


protocol ProgressHUDShowing {}


extension ProgressHUDShowing where Self: UIViewController {
    
    func showProgressHUD() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show()
    }
    
    func showProgressHUDSuccess(with status: String?) {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.showSuccess(withStatus: status)
    }
    
    func showProgressHUDError(with status: String?) {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.showError(withStatus: status)
    }
    
    func dismissProgressHUD(after secondsCount: Double = 1.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsCount) {
            SVProgressHUD.dismiss()
        }
    }
    
}
