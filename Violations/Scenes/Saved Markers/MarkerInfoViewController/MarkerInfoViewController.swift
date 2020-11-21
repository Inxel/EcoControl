//
//  MarkInfoViewController.swift
//  Violations
//
//  Created by Артем Загоскин on 14/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import FirebaseStorage
import SKPhotoBrowser
import MapKit


// MARK: - Base

final class MarkerInfoViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var closeButton: PrimaryButton!
    
    @IBOutlet private weak var closeButtonBottomConstraint: NSLayoutConstraint!
    
    // MARK: Properties
    
    private var items: [CellDataProvider] = []
    
    var marker: Marker?
    private let themeManager: ThemeManager = .shared
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeManager.delegate = self
        setUpUI()
    }
    
}

// MARK: - Private API

extension MarkerInfoViewController {
    
    private func setUpUI() {
        tableView.register(MarkerPhotosCell.self)
        tableView.register(MarkerDescriptionCell.self)
        tableView.contentInset.bottom = closeButton.frame.height + closeButtonBottomConstraint.constant * 2
        titleLabel.text = marker?.title
        dateLabel.text = marker?.date?.formattedDate(.long)
        items = [
            CellDataProvider(MarkerDescriptionCellProvider(dataSource: marker?.comment)),
            CellDataProvider(MarkerPhotosCellProvider(dataSource: marker, delegate: self))
        ]
        tableView.reloadData()
        themeDidChange()
    }
    
}


// MARK: - Actions

extension MarkerInfoViewController {
    
    @IBAction private func closeButtonTapped(_ sender: PrimaryButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func moreButtonTapped(_ sender: UIButton) {
        guard let marker = marker, let reportType = ReportsType(rawValue: marker.title) else { return }
        let customCallout = CustomCallout(reportType: reportType, comment: marker.comment, coordinate: marker.coordinate, photosPath: marker.photosPath, amountOfPhotos: marker.photosCount)
        
        chooseMap(marker: customCallout)
    }
    
}

// MARK: - UITableViewDataSource

extension MarkerInfoViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return items[indexPath.row].cellForRow(at: indexPath, in: tableView)
    }

}


// MARK: - Theme Manager Delegate

extension MarkerInfoViewController: ThemeManagerDelegate {
    
    func themeDidChange() {
        titleLabel.textColor = themeManager.current.textColor
        dateLabel.textColor = themeManager.current.textColor
        tableView.backgroundColor = themeManager.current.background
        view.backgroundColor = themeManager.current.background
        tableView.tableHeaderView?.backgroundColor = themeManager.current.background
        
        items.indices.forEach {
            switch tableView.cellForRow(at: IndexPath(row: $0, section: 0)) {
            case let cell as MarkerDescriptionCell:
                cell.changeTheme()
            case let cell as MarkerPhotosCell:
                cell.changeTheme()
            default:
                break
            }
        }
        
    }
    
}


// MARK: - ActionSheetShowing

extension MarkerInfoViewController: ActionSheetShowing {}


// MARK: - MarkerPhotosCellProviderDelegate

extension MarkerInfoViewController: MarkerPhotosCellProviderDelegate {
    
    func didTapOnPhoto(photos: [SKPhotoProtocol], index: Int) {
        let browser = SKPhotoBrowser(photos: photos, initialPageIndex: index)
        present(browser, animated: true, completion: nil)
    }
    
}
