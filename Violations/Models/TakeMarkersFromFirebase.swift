//
//  TakeMarkersFromFirebase.swift
//  Violations
//
//  Created by Артем Загоскин on 09/05/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import Firebase

struct TakeMarkersFromFirebase {
    
    static func downloadMarkers(child: String, completion: @escaping Handler<[String: AnyObject]>) {
        let markerDB = Database.database().reference().child(child)
        
        markerDB.observe(.childAdded) { snapshot in
            let snapshotValue = snapshot.value as? [String: AnyObject] ?? [:]
            
            completion(snapshotValue)
        }
    }
}
