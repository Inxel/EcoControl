//
//  CollectionViewItemsReordering.swift
//  Violations
//
//  Created by Artyom Zagoskin on 19.05.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


protocol CollectionViewItemsReordering: class {
    associatedtype Item
    
    var items: [Item] { get set }
}


extension CollectionViewItemsReordering {
    
    func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        if let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath, let insertionItem = item.dragItem.localObject as? Item {
            collectionView.performBatchUpdates({
                items.remove(at: sourceIndexPath.item)
                items.insert(insertionItem, at: destinationIndexPath.item)
                
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            }, completion: nil)
            
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
    }
    
}
