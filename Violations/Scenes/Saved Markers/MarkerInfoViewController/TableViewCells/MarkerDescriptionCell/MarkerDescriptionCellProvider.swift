//
//  MarkerDescriptionCellProvider.swift
//  Violations
//
//  Created by Artyom Zagoskin on 20.11.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


// MARK: - Delegate

protocol MarkerDescriptionCellDelegate: class {}


// MARK: - Cell Provider

final class MarkerDescriptionCellProvider: CellDataProtocol {
    
    typealias DataSource = String
    typealias Delegate = MarkerDescriptionCellDelegate
    
    weak var delegate: MarkerDescriptionCellDelegate?
    var indexPath: IndexPath?
    var dataSource: String?
    
    init(dataSource: String?, delegate: MarkerDescriptionCellDelegate? = nil) {
        self.dataSource = dataSource
        self.delegate = delegate
    }
    
    func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as MarkerDescriptionCell
        cell.setUp(with: dataSource)
        return cell
    }
    
}
