//
//  SavedMarkersTableViewController.swift
//  Violations
//
//  Created by Artyom Zagoskin on 23.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import RealmSwift


// MARK: - Base

final class SavedMarkersTableViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.contentInset.top = 50
            tableView.contentInset.bottom = 50
            tableView.register(MarkerInfoCell.self)
        }
    }
    
    // MARK: Properties
    
    private let realm = try! Realm()
    private var markers: [Marker] = []
    
    private weak var delegate: MarkersTableViewControllerDelegate?
    private let themeManager: ThemeManager = .shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeManager.delegate = self
    }
    
    // MARK: Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMarkers()
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


// MARK: - Table View Data Source

extension SavedMarkersTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { markers.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as MarkerInfoCell
        
        let marker = markers[indexPath.row]
        cell.setUp(title: marker.title, comment: marker.comment, date: marker.date, themeProtocol: themeManager.current)
        
        return cell
    }
    
}


// MARK: - Table View Delegate

extension SavedMarkersTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.1) {
            if let cell = tableView.cellForRow(at: indexPath) as? MarkerInfoCell {
            cell.background.transform = .init(scaleX: 0.85, y: 0.85)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3) {
            if let cell = tableView.cellForRow(at: indexPath) as? MarkerInfoCell {
                cell.background.transform = .identity
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didTap(on: markers[indexPath.row])
    }
    
}


// MARK: - Theme Manager Delegate

extension SavedMarkersTableViewController: ThemeManagerDelegate {
    
    func themeDidChange() {
        tableView.reloadData()
    }
    
}


// MARK: - Private API

extension SavedMarkersTableViewController {
    
    private func getMarkers() {
        let savedMarkers = realm.objects(SavedMarker.self).sorted(byKeyPath: "date", ascending: true)
        
        markers = savedMarkers.map { Marker(marker: $0) }
        
        tableView.reloadData()
    }
    
}
