//
//  CollectionViewItemsReordering.swift
//  Violations
//
//  Created by Artyom Zagoskin on 19.05.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit


// MARK: - Base

protocol CollectionViewItemsReordering: class {
    associatedtype Item: NSItemProviderWriting
    
    var items: [Item] { get set }
}


// MARK: - Public API

extension CollectionViewItemsReordering where Self: CollectionViewDragAndDropDelegate {
    
    func dragDidBegin(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = items[indexPath.item]
        let provider = NSItemProvider(object: item)
        let dragItem = UIDragItem(itemProvider: provider)
        dragItem.localObject = item
        
        return [dragItem]
    }
    
    func itemPositionDidChange(
        _ collectionView: UICollectionView,
        dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        
        if collectionView.hasActiveDrag {
            return .init(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        
        return .init(operation: .forbidden)
    }
    
    func integrateDroppedItem(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let lastItemInFirstSection = collectionView.numberOfItems(inSection: 0)
        let destinationIndexPath: IndexPath = coordinator.destinationIndexPath ?? .init(item: lastItemInFirstSection - 1, section: 0)
        
        if coordinator.proposal.operation == .move {
            reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
        }
    }
    
}


// MARK: - Private API

extension CollectionViewItemsReordering {
    
    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
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
