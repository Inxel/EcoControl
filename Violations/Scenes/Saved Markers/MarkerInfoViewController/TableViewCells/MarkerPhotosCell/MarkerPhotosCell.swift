//
//  MarkerPhotosCell.swift
//  Violations
//
//  Created by Artyom Zagoskin on 20.11.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import SKPhotoBrowser


// MARK: - Constants

private enum Constants {
    static let itemSpacing: CGFloat = 10
    static let horizontalInset: CGFloat = 20
}


// MARK: - Cell

final class MarkerPhotosCell: UITableViewCell {
    
    // MARK: - Outlets

    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet private weak var collectionViewHeight: NSLayoutConstraint!
    
    // MARK: - Properties
    
    private var marker: Marker?
    private weak var delegate: MarkerPhotosCellProviderDelegate?
    
    private var images: [SKPhotoProtocol] = []
    
    // MARK: - Base
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
        changeTheme()
    }
    
}


// MARK: - Public API

extension MarkerPhotosCell {
    
    func setUp(marker: Marker?, delegate: MarkerPhotosCellProviderDelegate?) {
        self.marker = marker
        self.delegate = delegate
        collectionViewHeight.constant = marker?.photosCount == 0 ? .zero : (collectionView.frame.width - Constants.itemSpacing) / 2
        images = Array(repeating: SKPhoto.photoWithImage(.init()), count: marker?.photosCount ?? .zero)
    }
    
    func changeTheme() {
        backgroundColor = ThemeManager.shared.current.background
        collectionView.backgroundColor = ThemeManager.shared.current.background
    }
    
}


// MARK: - Private API

extension MarkerPhotosCell {
    
    private func setUpUI() {
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.reuseID)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
}


// MARK: - UICollectionViewDataSource

extension MarkerPhotosCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { marker?.photosCount ?? 0 }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseID, for: indexPath) as! ImageCollectionViewCell
        cell.downloadImage(marker?.photosPath ?? "", indexPath.item) { [weak self] image in
            guard let image = image else { return }
            let photo = SKPhoto.photoWithImage(image)
            photo.shouldCachePhotoURLImage = true
            self?.images[indexPath.item] = photo
        }
        return cell
    }
    
}


// MARK: - CollectionView Delegate Flow Layout

extension MarkerPhotosCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let size = collectionView.frame.size.height
        return .init(width: size, height: size)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return Constants.itemSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return Constants.itemSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return .init(top: 0, left: Constants.horizontalInset, bottom: 0, right: Constants.horizontalInset)
    }
    
}


// MARK: - UICollectionViewDelegate

extension MarkerPhotosCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didTapOnPhoto(photos: images, index: indexPath.item)
    }
    
}
