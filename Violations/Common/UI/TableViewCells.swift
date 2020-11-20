//
//  TableViewCells.swift
//  Violations
//
//  Created by Artyom Zagoskin on 20.11.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


protocol CellDataProtocol: class {
    associatedtype DataSource
    associatedtype Delegate
    
    var delegate: Delegate? { get set }
    var indexPath: IndexPath? { get set }
    var dataSource: DataSource? { get set }
    
    init(dataSource: DataSource?, delegate: Delegate?)
    
    func getDataSource() -> DataSource?
    func set(dataSource: DataSource?)
    
    func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell
    func didSelectRow(in tableView: UITableView)
    func heightForRow(in tableView: UITableView, estimatedHeight: CGFloat?) -> CGFloat
}

extension CellDataProtocol {
    
    func getDataSource() -> DataSource? { dataSource }
    func set(dataSource: DataSource?) { self.dataSource = dataSource }
    func didSelectRow(in tableView: UITableView) {}
    func heightForRow(in tableView: UITableView, estimatedHeight: CGFloat?) -> CGFloat {
        if let height = estimatedHeight { return height }
        return UITableView.automaticDimension
    }
}


class CellDataProvider {
    
    // MARK: Private properties
    
    private let getData: () -> Any
    private let setData: (Any) -> Void
    private let cellForRowInTableView: (IndexPath, UITableView) -> UITableViewCell
    private let didSelectRowInTableView: (UITableView) -> Void
    private let heightForRowInTableView: (UITableView, CGFloat?) -> CGFloat
    
    // MARK: - Init
    
    init<CDP: CellDataProtocol>(_ cellData: CDP) {
        getData = cellData.getDataSource
        setData = { cellData.set(dataSource: $0 as? CDP.DataSource) }
        cellForRowInTableView = cellData.cellForRow(at:in:)
        didSelectRowInTableView = cellData.didSelectRow(in:)
        heightForRowInTableView = cellData.heightForRow(in:estimatedHeight:)
    }
}

extension CellDataProvider {
    func getDataSource<Data>() -> Data? { getData() as? Data }
    func setDataSource<Data>(dataSource: Data) { setData(dataSource) }
    func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell { cellForRowInTableView(indexPath, tableView) }
    func didSelectRow(in tableView: UITableView) { didSelectRowInTableView(tableView) }
    func heightForRow(in tableView: UITableView, estimatedHeight: CGFloat?) -> CGFloat { heightForRowInTableView(tableView, estimatedHeight) }
}
