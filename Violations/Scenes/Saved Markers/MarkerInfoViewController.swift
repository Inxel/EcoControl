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


// MARK: - Constants

private enum Constants {
    static var textColor: UIColor { Theme.current.textColor }
    static var backgroundColor: UIColor { Theme.current.background }
}


// MARK: - Base

final class MarkerInfoViewController: ViewControllerPannable {

    // MARK: Outlets
    
    @IBOutlet private weak var report: UILabel! {
        didSet {
            report.text = marker?.title
            report.textColor = Constants.textColor
        }
    }
    
    @IBOutlet private weak var date: UILabel! {
        didSet {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm   dd.MM.yy"
            date.text = formatter.string(from: marker?.date ?? Date())
            date.textColor = Constants.textColor
        }
    }
    
    @IBOutlet private weak var comment: UITextView! {
        didSet {
            comment.text = marker?.comment
            comment.textColor = Constants.textColor
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCollectionViewCell")
            collectionView.backgroundColor = Constants.backgroundColor
        }
    }
    
    // MARK: Properties
    
    var marker: Marker?
    
    private var images: [SKPhotoProtocol] = []
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        images = Array(repeating: SKPhoto.photoWithImage(#imageLiteral(resourceName: "loading")), count: marker?.amountOfPhotos ?? .zero)
        
        SKPhotoBrowserOptions.displayAction = false
        SKPhotoBrowserOptions.displayStatusbar = true
        SKPhotoBrowserOptions.displayCounterLabel = true
        SKPhotoBrowserOptions.displayBackAndForwardButton = true

        view.backgroundColor = Constants.backgroundColor
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell

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
        
        return CGSize(width: cellSize, height: cellSize)
    }
    
}


// MARK: - ActionSheetShowing

extension MarkerInfoViewController: ActionSheetShowing {}
