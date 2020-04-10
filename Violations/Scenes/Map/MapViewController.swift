//
//  MapViewController.swift
//  Violations
//
//  Created by Артем Загоскин on 07/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import TransitionButton
import SwiftyJSON
import RealmSwift


// MARK: - Constants

private enum Constants {
    static var weatherURL: String { "http://api.openweathermap.org/data/2.5/weather?appid=\(weatherAppID)" }
    static var weatherAppID: String { "e72ca729af228beabd5d20e3b7749713" }
    static var user: User? { Auth.auth().currentUser }
}


// MARK: - Base

final class MapViewController: CustomTransitionViewController, ProgressHUDShowing {
    
    // MARK: Outlets
    
    @IBOutlet private weak var mapView: MKMapView!
    
    @IBOutlet private weak var addByTapBottomConstraint: NSLayoutConstraint! {
        didSet {
            addByTapBottomConstraint.constant = -30
        }
    }
    @IBOutlet private weak var addToLocationBottomConstraint: NSLayoutConstraint! {
        didSet {
            addToLocationBottomConstraint.constant = -30
        }
    }
    
    @IBOutlet private weak var viewForShadow: UIView! {
        didSet {
            viewForShadow.layer.cornerRadius = viewForShadow.frame.height / 2
            viewForShadow.layer.shadowOffset = CGSize(width: -2, height: 2)
            viewForShadow.layer.shadowOpacity = 0.6
            viewForShadow.layer.shadowRadius = 2
        }
    }
    
    @IBOutlet private weak var addAnotation: UIButton! {
        didSet {
            addAnotation.layer.cornerRadius = addAnotation.frame.height / 2
        }
    }
    
    @IBOutlet private weak var weatherView: UITextView! {
        didSet {
            weatherView.layer.cornerRadius = 5
            weatherView.textContainerInset = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
        }
    }
    
    @IBOutlet private weak var addByTapButton: PrimaryButton! {
        didSet {
            addByTapButton.alpha = 0
        }
    }
    @IBOutlet private weak var addToLocationButton: PrimaryButton! {
        didSet {
            addToLocationButton.alpha = 0
        }
    }
    
    // MARK: Properties
    
    private lazy var gestureRecognizer: UIGestureRecognizer = {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tapRecognizer.delegate = self
        return tapRecognizer
    }()
    
    private var realm = try! Realm()
    
    private var annotations: [CustomCallout] = []
    
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    private var tappedCoordinates: CGPoint?
    private var userLocationButton: MKUserTrackingButton?
    
    private var canAddAnnotation: Bool = false
    private var addAnnotationTapped: Bool = false
    private var showAddButtons: Bool = false
    private var addToLocationTapped: Bool = false
    
    private let themeManager: ThemeManager = .shared
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        mapView.delegate = self
    
        themeManager.delegate = self
        themeDidChange()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        mapView.addGestureRecognizer(gestureRecognizer)
        
        // Check for Location Services
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        setupUserTrackingButton()
        
        retrieveMarkers()
        
        if !CheckInternet.connection() {
            showAlert(message: "Internet connection issues", defaultButtonTitle: "OK")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUserTrackingButton()
    }

}


// MARK: - Actions

extension MapViewController {
    
    @IBAction private func addAnnotationTapped(_ sender: UIButton) {
        addAnnotationTapped.toggle()
        showAddButtons = canAddAnnotation ? showAddButtons : !showAddButtons
        canAddAnnotation = false
        addAnnotationAnimate()
    }
    
    @IBAction private func addByTapButtonTapped(_ sender: PrimaryButton) {
        canAddAnnotation = true
        showAddButtons = false
        addToLocationTapped = false
        addAnnotationAnimate()
    }
    
    @IBAction private func addToLocationButtonTapped(_ sender: PrimaryButton) {
        performSegue(withIdentifier: "createMarkDetail", sender: Any?.self)
        
        addToLocationTapped = true
        showAddButtons = false
        addAnnotationTapped = false
        addAnnotationAnimate()
    }
    
}


// MARK: - Location methods

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
                mapView.setRegion(viewRegion, animated: true)
            }
        }
        
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            
            self.locationManager.stopUpdatingLocation()
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
//            let latitude = String(location.coordinate.latitude)
//            let longitude = String(location.coordinate.longitude)
//
//            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : Constants.weatherAppID]
            
//            getWeatherData(url: Constants.weatherURL, parameters: params)
            getWeather(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        }
    }
    
}


// MARK: - Private API

extension MapViewController: DefaultAlertShowing {
    
    private func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func setupUserTrackingButton() {
        view.subviews.filter { $0 is MKUserTrackingButton }.first?.removeFromSuperview()
        mapView.showsCompass = false

        let button = MKUserTrackingButton(mapView: mapView)
        button.layer.borderColor = UIColor.clear.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.backgroundColor = themeManager.current.background.cgColor
        button.tintColor = themeManager.current.trackingButton
        view.addSubview(button)
        
        let scale = MKScaleView(mapView: mapView)
        scale.legendAlignment = .trailing
        scale.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scale)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.topAnchor, constant: self.view.frame.height / 2),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
        ])
    }
    
}


//MARK: - Gesture Recognizer

extension MapViewController: UIGestureRecognizerDelegate {
    
    @objc private func handleTap(_ gestureReconizer: UILongPressGestureRecognizer) {
        if canAddAnnotation {
            performSegue(withIdentifier: "createMarkDetail", sender: Any?.self)
            
            tappedCoordinates = gestureReconizer.location(in: mapView)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createMarkDetail" {
            
            let destinationVC = segue.destination as! MarkDetailViewController
            
            destinationVC.delegate = self
        }
    }
    
}


// MARK: - Tapped Button Delegate

extension MapViewController: TappedButtonDelegate {
    
    func userTappedButton(button: MarkDetailViewController.ButtonType, title: String? = nil, comment: String? = nil, url: String? = nil, amountOfPhotos: String? = nil) {
        
        addToLocationTapped = false
        
        guard
            button == .save,
            let title = title,
            let comment = comment,
            let url = url,
            let amountOfPhotos = amountOfPhotos
        else { return }
        
        var coordinates: CLLocationCoordinate2D = .init()
        
        if addToLocationTapped {
            guard let userLocation = currentLocation?.coordinate else {
                showProgressHUDError(with: "Connection issues")
                addToLocationTapped = false
                return
            }
            coordinates = userLocation
        } else if let tappedCoordinates = tappedCoordinates {
            coordinates = mapView.convert(tappedCoordinates, toCoordinateFrom: mapView)
        }
        
        addAnnotationTapped = false
        canAddAnnotation = false
        addToLocationTapped = false
        
        addAnnotationAnimate()
        
        guard let numberOfPhotos = Int(amountOfPhotos) else { return }
        
        let marker = UserMarker()
        marker.title = title
        marker.comment = comment
        marker.date = Date()
        marker.url = url
        marker.amountOfPhotos = numberOfPhotos
        marker.latitude = String(describing: coordinates.latitude)
        marker.longitude = String(describing: coordinates.longitude)
        saveToRealm(marker)
        saveMarkerToFirebase(coordinates, title, comment, url, numberOfPhotos)
        
    }
    
}


//MARK: - Private API

extension MapViewController {
    
    private func addAnnotationAnimate() {
        UIView.animate(withDuration: 0.2) {
            self.addAnotation.transform = CGAffineTransform(rotationAngle: !self.addAnnotationTapped ? CGFloat(Double.pi * 2) : CGFloat(Double.pi / 4))
            self.addByTapBottomConstraint.constant = self.showAddButtons ? 20 : -30
            self.addToLocationBottomConstraint.constant = self.showAddButtons ? 20 : -30
            self.addByTapButton.alpha = self.showAddButtons ? 1 : 0
            self.addToLocationButton.alpha = self.showAddButtons ? 1 : 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func changeColorOf(_ button: UIButton) {
        button.backgroundColor = themeManager.current.tableViewBackground
    }
    
}


// MARK: - Theme Manager Delegate

extension MapViewController: ThemeManagerDelegate {
    
    func themeDidChange() {
        weatherView.textColor = themeManager.current.textColor
        weatherView.backgroundColor = themeManager.current.background
        viewForShadow.backgroundColor = themeManager.current.tableViewBackground
        changeColorOf(addAnotation)
        changeColorOf(addByTapButton)
        changeColorOf(addToLocationButton)
        setupUserTrackingButton()
    }
    
}


//MARK: - Firebase methods

extension MapViewController {
    
    private func saveMarkerToFirebase(_ coordinate: CLLocationCoordinate2D, _ title: String, _ comment: String, _ url: String, _ amountOfPhotos: Int) {
        let markersDB = Database.database().reference().child("Markers")
        let markersDictionary = ["Sender": Constants.user?.email,
                                 "Title": title,
                                 "Comment": comment,
                                 "Latitude": String(coordinate.latitude),
                                 "Longitude": String(coordinate.longitude),
                                 "URL": url,
                                 "AmountOfPhotos": String(amountOfPhotos)]
    
        markersDB.childByAutoId().setValue(markersDictionary) {
            (error, reference) in
            
            if let error = error {
                print(error)
            }
            else {
                print("Marker saved successfully!")
            }
        }
    }
    
    private func retrieveMarkers() {
        
        TakeMarkersFromFirebase.downloadMarkers(child: "Markers") { snapshotValue in
            let title = snapshotValue["Title"]!
            let comment = snapshotValue["Comment"]!
            let latitude = snapshotValue["Latitude"]!
            let longitude = snapshotValue["Longitude"]!
            let url = snapshotValue["URL"]!
            let amountOfPhotos = snapshotValue["AmountOfPhotos"]!
            
            guard let lat = Double(latitude), let lon = Double(longitude) else { return }
            
            let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            let reportType = ReportsType(rawValue: title)
            
            // Add marker on map
            
            let viewModel = CustomCallout(reportType: reportType, comment: comment, coordinate: coordinates, url: url, amountOfPhotos: amountOfPhotos)
            
            self.annotations.append(viewModel)
            
            self.mapView.addAnnotations(self.annotations)
        }
    }

}


// MARK: MapView Delegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? CustomCallout else { return nil }
        
        let identifier = "marker"
        var view: MKMarkerAnnotationView

        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = false
            
            view.clusteringIdentifier = "AnnotationViewIdentifier"
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard
            let annotation = view.annotation as? CustomCallout,
            let calloutVC = CalloutView.instance() as? CalloutView
        else { return }
        
        calloutVC.marker = annotation
        
        present(calloutVC, animated: true)
        
        mapView.deselectAnnotation(view.annotation, animated: true)
    }
}


//MARK: - Weather Requesting

extension MapViewController {
    
    private func getWeather(lat: Double, lng: Double) {
        guard let url = URL(string: "\(Constants.weatherURL)&lat=\(lat)&lon=\(lng)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            
            if let data = data {
                let weatherJSON = JSON(data)
                
                self.updateWeatherData(json: weatherJSON)
            } else {
                print("Error getting weather: \(String(describing: error?.localizedDescription))")
            }
            
        }.resume()
        
    }
    
    private func updateWeatherData(json : JSON) {
        
        let tempResult = json["main"]["temp"].doubleValue
        
        let temperature = Int(tempResult - 273.15)
        let condition = json["weather"][0]["id"].intValue
        
        let weatherData = WeatherData(temperature: temperature, condition: condition)
        
        DispatchQueue.main.async {
            self.weatherView.text = weatherData.weather
            self.weatherView.isHidden = false
        }
        
    }
    
}


//MARK: - Realm methods

extension MapViewController {
    
    private func saveToRealm(_ marker: UserMarker) {
        
        do {
            try realm.write {
                realm.add(marker)
            }
        } catch {
            showAlert(message: "Something went wrong", defaultButtonTitle: "OK")
        }
        
    }
    
}
