//
//  CalloutView.swift
//  Violations
//
//  Created by Артем Загоскин on 01/05/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import SKPhotoBrowser
import FirebaseStorage
import RealmSwift
import MapKit
import Firebase


// MARK: - Constants

private enum Constants {
    static var user: User? { Auth.auth().currentUser }
}


// MARK: - Base

final class CalloutView: ViewControllerPannable, ProgressHUDShowing {
    
    // MARK: Outlets
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.backgroundColor = Theme.current.background
        }
    }
    
    @IBOutlet private weak var commentTextview: UITextView! {
        didSet {
            commentTextview.text = comment
            commentTextview.textColor = Theme.current.textColor
            commentTextview.backgroundColor = Theme.current.background
        }
    }
    
    @IBOutlet private weak var backgroundView: BackgroundView! {
        didSet {
            backgroundView.backgroundColor = Theme.current.background
        }
    }
    
    @IBOutlet private weak var underButtonView: UIView! {
        didSet {
            underButtonView.backgroundColor = Theme.current.background
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = titleOfMarker
            titleLabel.textColor = Theme.current.textColor
        }
    }
    
    // MARK: Properties
    
    private var realm = try! Realm()
    private var markersFromRealm: Results<SavedMarker>?
    private var isExist = false
    
    var reportType: ReportsType = .other
    var comment = ""
    var url = ""
    var amountOfPhotos: Int?
    var location: CLLocationCoordinate2D?
    var mark: CustomCallout?
    
    private var titleOfMarker: String { reportType.rawValue }
    
    private var images = [SKPhotoProtocol]()
    private var data = Data()
    
    private var numberOfPhotos: Int { amountOfPhotos ?? 0 }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        images = Array(repeating: SKPhoto.photoWithImage(#imageLiteral(resourceName: "loading")), count: numberOfPhotos)
        
        SKPhotoBrowserOptions.displayAction = false
        SKPhotoBrowserOptions.displayStatusbar = true
        SKPhotoBrowserOptions.displayCounterLabel = true
        SKPhotoBrowserOptions.displayBackAndForwardButton = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCollectionViewCell")
        
        markersFromRealm = realm.objects(SavedMarker.self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        commentTextview.setContentOffset(CGPoint.zero, animated: false)
    }

}


// MARK: - Actions

extension CalloutView {
    
    @IBAction private func dismissCallout(_ sender: UIButton) {
         dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func saveButtonTapped(_ sender: PrimaryButton) {
        guard let location = location else { return }
        showProgressHUD()
        let marker = SavedMarker()
        marker.title = titleOfMarker
        marker.comment = comment == "User didn't add comment" ? "" : comment
        marker.dateCreated = Date()
        marker.url = url
        marker.amountOfPhotos = numberOfPhotos
        marker.latitude = String(describing: location.latitude)
        marker.longitude = String(describing: location.longitude)
        
        markersFromRealm?.forEach {
            if $0.url == self.url {
                self.isExist = true
                return
            }
        }
        
        if !isExist {
            saveToRealm(marker)
            
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            saveMarker(coordinate, titleOfMarker, comment, url, numberOfPhotos)
        } else {
            showProgressHUDError(with: "You've already saved this marker")
        }
        
    }
    
    @IBAction private func showMore(_ sender: UIButton) {
        guard let location = location else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: #"Show on "Maps""#, style: .default, handler: { _ in
            self.mark = CustomCallout(reportType: self.reportType, comment: self.comment, coordinate: location, url: self.url, amountOfPhotos: String(self.numberOfPhotos))
            let launchOptions = [MKLaunchOptionsDirectionsModeKey:
                MKLaunchOptionsDirectionsModeDriving]
            self.mark?.mapItem().openInMaps(launchOptions: launchOptions)
        }))
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}


// MARK: - Private API

extension CalloutView {
    
    private func saveToRealm(_ marker: SavedMarker) {
        
        do {
            try realm.write {
                realm.add(marker)
                showProgressHUDSuccess(with: "Marker has been successfully saved")
            }
        } catch {
            print("Fuckin' error")
            showProgressHUDError(with: "Try later")
        }
        
    }
    
    private func saveMarker(_ coordinate: CLLocationCoordinate2D, _ title: String, _ comment: String, _ url: String, _ amountOfPhotos: Int) {
        guard let user = Constants.user, CheckInternet.connection() else { return }
        let markersDB = Database.database().reference().child("SavedMarkers/\(user.uid)")
        let markersDictionary = ["Sender": Auth.auth().currentUser?.email,
                                 "Title": title,
                                 "Comment": comment,
                                 "Latitude": String(coordinate.latitude),
                                 "Longitude": String(coordinate.longitude),
                                 "URL": url,
                                 "AmountOfPhotos": String(amountOfPhotos)]
    
        markersDB.childByAutoId().setValue(markersDictionary) {
            (error, reference) in
            
            if error != nil {
                print(error!)
            }
            else {
                print("Marker saved successfully!")
            }
        }
    }
    
}


//MARK: - CollectionView delegate methods


extension CalloutView: UICollectionViewDelegate, SKPhotoBrowserDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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


//MARK: - CollectionView datasource methods


extension CalloutView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { numberOfPhotos }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        
        cell.downloadImage(url, indexPath.item) { image in
            guard let image = image else { return }
            let photo = SKPhoto.photoWithImage(image)
            photo.shouldCachePhotoURLImage = true
            self.images[indexPath.item] = photo
        }
        
        return cell
    }
    
}


//MARK: - CollectionView layout methods


extension CalloutView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size.width - 40
        
        let cellSize = size / 2
        
        return CGSize(width: cellSize, height: cellSize)
    }
    
}
