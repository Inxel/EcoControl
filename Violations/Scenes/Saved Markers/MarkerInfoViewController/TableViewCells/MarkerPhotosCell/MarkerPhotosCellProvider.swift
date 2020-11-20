//
//  MarkerPhotosCellProvider.swift
//  Violations
//
//  Created by Artyom Zagoskin on 20.11.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import SKPhotoBrowser


// MARK: - Delegate

protocol MarkerPhotosCellProviderDelegate: class {
    func didTapOnPhoto(photos: [SKPhotoProtocol], index: Int)
}

extension MarkerPhotosCellProviderDelegate where Self: UIViewController {
    
    func didTapOnPhoto(photos: [SKPhotoProtocol], index: Int) {
        let browser = SKPhotoBrowser(photos: photos, initialPageIndex: index)
        present(browser, animated: true, completion: nil)
    }
    
}


// MARK: - Cell Provider

final class MarkerPhotosCellProvider: CellDataProtocol {
    
    typealias DataSource = Marker
    typealias Delegate = MarkerPhotosCellProviderDelegate
    
    weak var delegate: MarkerPhotosCellProviderDelegate?
    var indexPath: IndexPath?
    var dataSource: Marker?
    
    init(dataSource: Marker?, delegate: MarkerPhotosCellProviderDelegate?) {
        self.dataSource = dataSource
        self.delegate = delegate
    }
    
    func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as MarkerPhotosCell
        cell.setUp(marker: dataSource, delegate: delegate)
        return cell
    }
    
}

