//
//  TableViewCellProvider.swift
//  Violations
//
//  Created by Artyom Zagoskin on 08.09.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


class TableViewCellProvider<DataSource, Delegate, Cell: UITableViewCell> {
    var delegate: Delegate
    var dataSource: DataSource
    var tableView: UITableView
    var indexPath: IndexPath?
    
    init(dataSource: DataSource, delegate: Delegate, tableView: UITableView) {
        self.dataSource = dataSource
        self.delegate = delegate
        self.tableView = tableView
    }
    
    func getDataSource() -> DataSource { dataSource }
    func set(dataSource: DataSource) { self.dataSource = dataSource }
    func cellForRow(at indexPath: IndexPath) -> Cell {
        self.indexPath = indexPath
        let cell = tableView.dequeueReusableCell(for: indexPath) as Cell
        return cell
    }
    func didSelectRow() {}
}
