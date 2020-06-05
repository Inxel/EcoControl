//
//  RealmContaining.swift
//  Violations
//
//  Created by Artyom Zagoskin on 05.06.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import RealmSwift


protocol RealmContaining {
    var realm: Realm { get set }
    func showError()
    func showSuccess()
}


extension RealmContaining where Self: UIViewController {
    
    func saveToRealm(_ object: Object) {
        
        do {
            try realm.write {
                realm.add(object)
                showSuccess()
            }
        } catch {
            showError()
        }
        
    }
    
    func showError() {}
    
    func showSuccess() {}
    
}

extension RealmContaining where Self: UIViewController, Self: ProgressHUDShowing {
    
    func showError() {
        showProgressHUDError(with: "Error during saving to database")
    }
    
}
