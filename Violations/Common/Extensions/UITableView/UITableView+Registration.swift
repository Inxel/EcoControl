//
//  UITableView+Registration.swift
//  Violations
//
//  Created by Artyom Zagoskin on 16.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


extension UITableView {
    
    func register<Cell: UITableViewCell>(_: Cell.Type) {
        register(Cell.nib, forCellReuseIdentifier: Cell.reuseID)
    }
    
    final func register<Cell: UITableViewCell>(cellTypes: [Cell.Type]) {
        cellTypes.forEach { register($0.self) }
    }
    
    func dequeueReusableCell<Cell: UITableViewCell>(for indexPath: IndexPath) -> Cell {
        guard let cell = dequeueReusableCell(withIdentifier: Cell.reuseID, for: indexPath) as? Cell else {
            fatalError("Could not dequeue cell with ID: \(Cell.reuseID)")
        }
        
        return cell
    }
    
}

extension UITableViewCell: NIBLoadableView, ReusableView {}
