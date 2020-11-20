//
//  SavedMarkersTableViewController.swift
//  Violations
//
//  Created by Artyom Zagoskin on 23.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


// MARK: - Base

final class SavedMarkersTableViewController: MarkersInnerViewController<SavedMarker> {
    
    // MARK: Outlets

    @IBOutlet private weak var emptyLabel: UILabel!

    // MARK: Overridden API
    
    override func markersDidUpdate() {
        super.markersDidUpdate()
        emptyLabel.isHidden = !markers.isEmpty
    }
    
}


// MARK: - Initiate

extension SavedMarkersTableViewController {
    
    class func initiate(delegate: MarkersTableViewControllerDelegate? = nil) -> UIViewController? {
        guard let viewController = instance() as? SavedMarkersTableViewController else { return nil }
        viewController.delegate = delegate
        
        return viewController
    }
    
}
