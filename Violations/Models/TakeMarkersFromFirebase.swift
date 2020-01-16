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
    
    static func downloadMarkers(child: String, completion: @escaping Handler<[String: String]>) {
        let markerDB = Database.database().reference().child(child)
        var snapshotValue: [String : String]?
        
        markerDB.observe(.childAdded) { snapshot in
            snapshotValue = snapshot.value as? Dictionary<String,String>
            
            completion(snapshotValue!)
        }
    }
}
