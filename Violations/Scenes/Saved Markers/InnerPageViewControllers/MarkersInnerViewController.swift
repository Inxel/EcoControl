//
//  MarkersInnerViewController.swift
//  Violations
//
//  Created by Artyom Zagoskin on 14.02.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


// MARK: - Base

class MarkersInnerViewController<MarkersType: MarkerObject>: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    
    final weak var delegate: MarkersTableViewControllerDelegate?
    final let themeManager: ThemeManager = .shared
    
    final var markers: [Marker] = [] {
        didSet {
            markersDidUpdate()
        }
    }
    
    final private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.contentInset.top = 50
        tableView.contentInset.bottom = 50
        tableView.register(MarkerInfoCell.self)
        tableView.separatorStyle = .none
        tableView.bounds = view.bounds
        tableView.center = view.center
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        
        return tableView
    }()
    
    // MARK: Life Cycle
    
    final override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMarkers()
    }
    
    final override func viewDidLoad() {
        super.viewDidLoad()
        themeManager.delegate = self
    }
    
    // MARK: Table View Data Source
    
    final func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { markers.count }
    
    final func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as MarkerInfoCell
        
        let marker = markers[indexPath.row]
        cell.setUp(title: marker.title, comment: marker.comment, date: marker.date, themeProtocol: themeManager.current)
        
        return cell
    }
    
    // MARK: Table View Delegate
    
    final func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.1) {
            if let cell = tableView.cellForRow(at: indexPath) as? MarkerInfoCell {
                cell.changeBackgroundSize(transform: .init(scaleX: 0.85, y: 0.85))
            }
        }
    }
    
    final func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3) {
            if let cell = tableView.cellForRow(at: indexPath) as? MarkerInfoCell {
                cell.changeBackgroundSize(transform: .identity)
            }
        }
    }
    
    final func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didTap(on: markers[indexPath.row])
    }

    // MARK: Should be overridden
    
    func markersDidUpdate() {
        tableView.reloadData()
    }
    
}


// MARK: - Theme Manager Delegate

extension MarkersInnerViewController: ThemeManagerDelegate {
    
    final func themeDidChange() {
        tableView.reloadData()
    }
    
}


// MARK: - Private API

extension MarkersInnerViewController: RealmContaining {
    
    private func getMarkers() {
        markers = getFromRealm(MarkersType.self, sortingKeyPath: "date").map { Marker(marker: $0) }
    }
    
}
