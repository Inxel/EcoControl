//
//  SavedMarkersTableViewController.swift
//  Violations
//
//  Created by Artyom Zagoskin on 23.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


// MARK: - Base

final class SavedMarkersTableViewController: MarkersInnerViewController {
    
    // MARK: Outlets
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.contentInset.top = 50
            tableView.contentInset.bottom = 50
            tableView.register(MarkerInfoCell.self)
        }
    }
    @IBOutlet private weak var emptyLabel: UILabel!

    // MARK: - Overriden API
    
    override func markersDidUpdate() {
        super.markersDidUpdate()
        emptyLabel.isHidden = !markers.isEmpty
    }

    override func getMarkers() {
        let addedMarkers = realm.objects(SavedMarker.self).sorted(byKeyPath: "date", ascending: true)

        markers = addedMarkers.map { Marker(marker: $0) }
    }
    
    override func reloadTableView() {
        tableView.reloadData()
    }
    
}


// MARK: - Initiate

extension SavedMarkersTableViewController {
    
    class func initiate(delegate: MarkersTableViewControllerDelegate? = nil) -> UIViewController {
        let storyboard = UIStoryboard(name: "SavedMarkersTableViewController", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: SavedMarkersTableViewController.self)) as! SavedMarkersTableViewController
        viewController.delegate = delegate
        
        return viewController
    }
    
}
