//
//  ActionSheetShowing.swift
//  Violations
//
//  Created by Artyom Zagoskin on 24.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import MapKit


protocol ActionSheetShowing {}


extension ActionSheetShowing where Self: UIViewController {
    
    func chooseMap(marker: CustomCallout?) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(.init(title: #"Show on "Maps""#, style: .default, handler: { _ in
            
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            marker?.mapItem().openInMaps(launchOptions: launchOptions)
        }))
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
}
