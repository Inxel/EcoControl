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
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.contentInset.top = 50
            tableView.contentInset.bottom = 50
            tableView.register(MarkerInfoCell.self)
        }
    }
    @IBOutlet private weak var emptyLabel: UILabel!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeManager.delegate = self
    }
    
    // MARK: - Overriden API
    
    override func markersDidUpdate() {
        emptyLabel.isHidden = !markers.isEmpty
        tableView.reloadData()
    }

    override func getMarkers() {
        let addedMarkers = realm.objects(UserMarker.self).sorted(byKeyPath: "date", ascending: true)

        markers = addedMarkers.map { Marker(marker: $0) }
    }
    
}


// MARK: - Initiate

extension AddedMarkersTableViewController {
    
    class func initiate(delegate: MarkersTableViewControllerDelegate? = nil) -> UIViewController {
        let storyboard = UIStoryboard(name: "AddedMarkersTableViewController", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: AddedMarkersTableViewController.self)) as! AddedMarkersTableViewController
        viewController.delegate = delegate
        
        return viewController
    }
    
}


// MARK: - Theme Manager Delegate

extension AddedMarkersTableViewController: ThemeManagerDelegate {
    
    func themeDidChange() {
        tableView.reloadData()
    }
    
}
