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
            collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.reuseID)
        }
    }
    
    @IBOutlet private weak var commentTextview: UITextView! {
        didSet {
            commentTextview.text = comment
        }
    }
    
    @IBOutlet private weak var backgroundView: BackgroundView!
    @IBOutlet private weak var underButtonView: UIView!
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = markerTitle
        }
    }
    
    // MARK: Properties
    
    private var realm = try! Realm()
    private var markersFromRealm: Results<SavedMarker>?
    
    private var reportType: ReportsType { marker?.reportType ?? .other }
    private var markerTitle: String { marker?.title ?? "" }
    private var comment: String { marker?.comment ?? "" }
    private var url: String { marker?.url ?? "" }
    private var amountOfPhotos: Int? {
        guard let marker = marker else { return .init() }
        return Int(marker.amountOfPhotos)
    }
    private var location: CLLocationCoordinate2D? { marker?.coordinate }
    
    var marker: CustomCallout?
    
    private var images: [SKPhotoProtocol] = []
    
    private var numberOfPhotos: Int { amountOfPhotos ?? 0 }
    
    private let themeManager: ThemeManager = .shared
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeManager.delegate = self
        themeDidChange()
        images = Array(repeating: SKPhoto.photoWithImage(.loading), count: numberOfPhotos)
        
        SKPhotoBrowserOptions.displayAction = false
        SKPhotoBrowserOptions.displayStatusbar = true
        SKPhotoBrowserOptions.displayCounterLabel = true
        SKPhotoBrowserOptions.displayBackAndForwardButton = true
        
        markersFromRealm = realm.objects(SavedMarker.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        makePresentationViewTranslucent(with: 0.3)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        makePresentationViewTranslucent(with: .zero)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        commentTextview.setContentOffset(.zero, animated: false)
    }

}


// MARK: - Actions

extension CalloutView: ActionSheetShowing {
    
    @IBAction private func dismissCallout(_ sender: UIButton) {
         dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func saveButtonTapped(_ sender: PrimaryButton) {
        guard let location = location else { return }
        showProgressHUD()
        let marker = SavedMarker()
        marker.title = markerTitle
        marker.comment = comment == "User didn't add comment" ? "" : comment
        marker.date = Date()
        marker.url = url
        marker.amountOfPhotos = numberOfPhotos
        marker.latitude = String(location.latitude)
        marker.longitude = String(location.longitude)
        
        if !(markersFromRealm?.contains(where: { $0.url == url }) ?? false) {
            saveToRealm(marker)
            
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            saveMarker(coordinate, markerTitle, comment, url, numberOfPhotos)
        } else {
            showProgressHUDError(with: "You've already saved this marker")
        }
        
    }
    
    @IBAction private func showMore(_ sender: UIButton) {
        chooseMap(marker: marker)
    }
    
}


// MARK: - Theme Manager Delegate

extension CalloutView: ThemeManagerDelegate {
    
    func themeDidChange() {
        collectionView.backgroundColor = themeManager.current.background
        commentTextview.textColor = themeManager.current.textColor
        commentTextview.backgroundColor = themeManager.current.background
        backgroundView.backgroundColor = themeManager.current.background
        underButtonView.backgroundColor = themeManager.current.background
        titleLabel.textColor = themeManager.current.textColor
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
    
    private func makePresentationViewTranslucent(with alpha: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.presentationController?.containerView?.backgroundColor = .init(red: 0, green: 0, blue: 0, alpha: alpha)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize { .init(width: UIScreen.main.bounds.size.width / 2 - 5, height: 200) }
    
}


//MARK: - CollectionView datasource methods


extension CalloutView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { numberOfPhotos }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseID, for: indexPath) as! ImageCollectionViewCell
        
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
