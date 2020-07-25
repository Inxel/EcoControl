//
//  UICollectionView+Registration.swift
//  Violations
//
//  Created by Artyom Zagoskin on 16.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


extension UICollectionView {
        
    final func register<Cell: UICollectionViewCell>(_: Cell.Type) where Cell: DequeueableCell {
        register(Cell.nib, forCellWithReuseIdentifier: Cell.reuseID)
    }
    
    final func register<Cell: UICollectionViewCell>(cellTypes: [Cell.Type]) where Cell: DequeueableCell {
        cellTypes.forEach { register($0.self) }
    }
    
    final func dequeueReusableCell<Cell: UICollectionViewCell>(for indexPath: IndexPath) -> Cell where Cell: ReusableView {
        guard let cell = dequeueReusableCell(withReuseIdentifier: Cell.reuseID, for: indexPath) as? Cell else {
            fatalError("Could not dequeue cell with ID: \(Cell.reuseID)")
        }
        
        return cell
    }
        
}
