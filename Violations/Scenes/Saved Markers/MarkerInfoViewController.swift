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
    
    @IBOutlet private weak var report: UILabel! {
        didSet {
            report.text = marker?.title
        }
    }
    
    @IBOutlet private weak var date: UILabel! {
        didSet {
            date.text = marker?.date?.formattedDate(.long)
        }
    }
    
    @IBOutlet private weak var comment: UITextView! {
        didSet {
            comment.text = marker?.comment
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.reuseID)
        }
    }
    
    // MARK: Properties
    
    var marker: Marker?
    
    private var images: [SKPhotoProtocol] = []
    
    private let themeManager: ThemeManager = .shared
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        images = Array(repeating: SKPhoto.photoWithImage(.init()), count: marker?.amountOfPhotos ?? .zero)
        
        themeManager.delegate = self
        themeDidChange()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        comment.setContentOffset(CGPoint.zero, animated: false)
    }
    
}


// MARK: - Actions

extension MarkerInfoViewController {
    
    @IBAction private func closeButtonTapped(_ sender: PrimaryButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func moreButtonTapped(_ sender: UIButton) {
        guard let marker = marker, let reportType = ReportsType(rawValue: marker.title) else { return }
        let customCallout = CustomCallout(reportType: reportType, comment: marker.comment, coordinate: marker.coordinate, url: marker.url, amountOfPhotos: String(marker.amountOfPhotos))
        
        chooseMap(marker: customCallout)
    }
    
}


// MARK: - Theme Manager Delegate

extension MarkerInfoViewController: ThemeManagerDelegate {
    
    func themeDidChange() {
        report.textColor = themeManager.current.textColor
        date.textColor = themeManager.current.textColor
        comment.textColor = themeManager.current.textColor
        collectionView.backgroundColor = themeManager.current.background
        view.backgroundColor = themeManager.current.background
    }
    
}


// MARK: - CollectionView Delegate, SKPhotoBrowser Delegate

extension MarkerInfoViewController: UICollectionViewDelegate, SKPhotoBrowserDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let browser = SKPhotoBrowser(photos: images, initialPageIndex: indexPath.item)
        browser.delegate = self
        
        present(browser, animated: true, completion: nil)
    }
    
}


// MARK: - CollectionView Data Source

extension MarkerInfoViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { marker?.amountOfPhotos ?? .zero }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseID, for: indexPath) as! ImageCollectionViewCell

        cell.downloadImage(marker?.url ?? "", indexPath.item) { image in
            guard let image = image else { return }
            let photo = SKPhoto.photoWithImage(image)
            photo.shouldCachePhotoURLImage = true
            self.images[indexPath.item] = photo
        }
        
        return cell
    }
    
}


// MARK: - CollectionView Delegate Flow Layout

extension MarkerInfoViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size.width - 40
        let cellSize = size / 2
        
        return .init(width: cellSize, height: cellSize)
    }
    
}


// MARK: - ActionSheetShowing

extension MarkerInfoViewController: ActionSheetShowing {}
