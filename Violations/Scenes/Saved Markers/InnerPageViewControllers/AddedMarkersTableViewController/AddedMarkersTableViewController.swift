//
//  AddedMarkersTableViewController.swift
//  Violations
//
//  Created by Artyom Zagoskin on 23.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


// MARK: - Base

final class AddedMarkersTableViewController: MarkersInnerViewController {
    
    // MARK: Outlets
    
    @IBOutlet private weak var emptyLabel: UILabel!
    
    // MARK: Overridden API
    
    override func markersDidUpdate() {
        super.markersDidUpdate()
        emptyLabel.isHidden = !markers.isEmpty
    }

    override func getMarkers() {
        let addedMarkers = realm.objects(UserMarker.self).sorted(byKeyPath: "date", ascending: true)

        markers = addedMarkers.map { Marker(marker: $0) }
    }
    
}


// MARK: - Initiate

extension AddedMarkersTableViewController {
    
    class func initiate(delegate: MarkersTableViewControllerDelegate? = nil) -> UIViewController? {
        guard let viewController = instance() as? AddedMarkersTableViewController else { return nil }
        viewController.delegate = delegate
        
        return viewController
    }
    
}
