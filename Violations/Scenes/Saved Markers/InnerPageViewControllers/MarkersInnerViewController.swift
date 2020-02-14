//
//  MarkersInnerViewController.swift
//  Violations
//
//  Created by Artyom Zagoskin on 14.02.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import RealmSwift


// MARK: - Base

class MarkersInnerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    
    let realm = try! Realm()
    
    weak var delegate: MarkersTableViewControllerDelegate?
    let themeManager: ThemeManager = .shared
    
    var markers: [Marker] = [] {
        didSet {
            markersDidUpdate()
        }
    }
    
    // MARK: Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMarkers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeManager.delegate = self
    }
    
    // MARK: Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { markers.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as MarkerInfoCell
        
        let marker = markers[indexPath.row]
        cell.setUp(title: marker.title, comment: marker.comment, date: marker.date, themeProtocol: themeManager.current)
        
        return cell
    }
    
    // MARK: Table View Delegate
    
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
    
    
    func markersDidUpdate() {
        reloadTableView()
    }
    
    func getMarkers() {}
    
    func reloadTableView() {}
    
}


// MARK: - Theme Manager Delegate

extension MarkersInnerViewController: ThemeManagerDelegate {
    
    func themeDidChange() {
        reloadTableView()
    }
    
}
