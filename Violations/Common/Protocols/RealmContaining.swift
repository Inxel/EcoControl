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
    func showError()
    func showSuccess()
}


extension RealmContaining where Self: UIViewController {
    
    var realm: Realm {
        get {
            do {
                let realm = try Realm()
                return realm
            }
            catch {
                print("Something wrong during connecting to realm")
            }
            
            return self.realm
        }
    }
    
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
    
    func getFromRealm<T: Object>(_ object: T.Type, sortingKeyPath: String? = nil, ascending: Bool = true) -> Results<T> {
        if let sortingKeyPath = sortingKeyPath {
            return realm.objects(object.self).sorted(byKeyPath: sortingKeyPath, ascending: ascending)
        } else {
            return realm.objects(object.self)
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
