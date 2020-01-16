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

class MarkerInfoViewController: ViewControllerPannable {

    var savedMarker: SavedMarker?
    var userMarker: UserMarker?
    var ifSavedSegment: Bool?
    
    @IBOutlet weak var report: UILabel! {
        didSet {
            report.text = ifSavedSegment! ? savedMarker?.title : userMarker?.title
            report.lineBreakMode = .byWordWrapping
            report.numberOfLines = 0
            changeColorOf(report)
        }
    }
    
    @IBOutlet weak var date: UILabel! {
        didSet {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm   dd.MM.yy"
            date.text = "Saved at \(formatter.string(from: (ifSavedSegment! ? savedMarker?.dateCreated : userMarker?.dateCreated)!))"
            changeColorOf(date)
        }
    }
    
    @IBOutlet weak var comment: UITextView! {
        didSet {
            comment.text = ifSavedSegment! ? savedMarker?.comment : userMarker?.comment
            comment.textColor = Theme.current.textColor
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.backgroundColor = Theme.current.background
        }
    }
    
    private var mark: CustomCallout?
    private var images = [SKPhotoProtocol]()
    private var data = Data()
    private var location: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        images = Array(repeating: SKPhoto.photoWithImage(#imageLiteral(resourceName: "loading")), count: ifSavedSegment! ? savedMarker!.amountOfPhotos : userMarker!.amountOfPhotos)
        
        SKPhotoBrowserOptions.displayAction = false
        SKPhotoBrowserOptions.displayStatusbar = true
        SKPhotoBrowserOptions.displayCounterLabel = true
        SKPhotoBrowserOptions.displayBackAndForwardButton = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCollectionViewCell")
        
        view.backgroundColor = Theme.current.background
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        comment.setContentOffset(CGPoint.zero, animated: false)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        transformStringToLocation()
        
        createActionSheet()
    }
    
}


extension MarkerInfoViewController: UICollectionViewDelegate, SKPhotoBrowserDelegate {
    
    @objc(collectionView:didSelectItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let browser = SKPhotoBrowser(photos: images, initialPageIndex: indexPath.item)
        browser.delegate = self
        
        present(browser, animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGSize(width: UIScreen.main.bounds.size.width / 2 - 5, height: 300)
        } else {
            return CGSize(width: UIScreen.main.bounds.size.width / 2 - 5, height: 200)
        }
    }
    
}


extension MarkerInfoViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ifSavedSegment! ? savedMarker!.amountOfPhotos : userMarker!.amountOfPhotos
    }
    
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell

        cell.downloadImage(ifSavedSegment! ? savedMarker!.url : userMarker!.url, indexPath.item) { image in
            let photo = SKPhoto.photoWithImage(image!)
            photo.shouldCachePhotoURLImage = true
            self.images[indexPath.item] = photo
        }
        
        return cell
    }
    
}


extension MarkerInfoViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size.width - 40
        
        let cellSize = size / 2
        
        return CGSize(width: cellSize, height: cellSize)
    }
    
}

//MARK: - "More" tapped methods

extension MarkerInfoViewController {
    
    func createActionSheet() {
        
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: #"Show on "Maps""#, style: .default, handler: { _ in
//            self.mark = CustomCallout(title: self.report.text!, comment: self.comment.text ?? "", coordinate: self.location!, url: self.ifSavedSegment! ? self.savedMarker!.url : self.userMarker!.url, amountOfPhotos: String(describing: self.ifSavedSegment! ? self.savedMarker!.amountOfPhotos : self.userMarker!.amountOfPhotos))
//            let launchOptions = [MKLaunchOptionsDirectionsModeKey:
//                MKLaunchOptionsDirectionsModeDriving]
//            self.mark!.mapItem().openInMaps(launchOptions: launchOptions)
//        }))
//        
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        cancel.setValue(UIColor.red, forKey: "titleTextColor")
//        
//        alert.addAction(cancel)
//        
//        self.present(alert, animated: true, completion: nil)
        
    }
    
    func transformStringToLocation() {
        
        if let latitude = ifSavedSegment! ? savedMarker!.latitude : userMarker!.latitude, let longitude = ifSavedSegment! ? savedMarker!.longitude : userMarker!.longitude {
            let lat = Double(latitude)
            let lon = Double(longitude)
            
            location = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
        }
    }
    
}


//MARK: - Change theme

extension MarkerInfoViewController {
    func changeColorOf(_ label: UILabel) {
        label.textColor = Theme.current.textColor
    }
}
