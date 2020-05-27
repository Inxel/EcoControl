//
//  CustomCallout.swift
//  Violations
//
//  Created by Артем Загоскин on 18/04/2019.
//  Copyright © 2019 Tyoma Zagoskin. All rights reserved.
//

import UIKit
import MapKit
import Contacts


final class CustomCallout: NSObject, MKAnnotation {

    var reportType: ReportsType
    var comment: String
    var coordinate: CLLocationCoordinate2D
    var photosPath: String
    var photosCount: Int
    
    var title: String? { reportType.rawValue }
    
    init(reportType: ReportsType?, comment: String?, coordinate: CLLocationCoordinate2D, url: String, amountOfPhotos: Int) {
        self.reportType = reportType ?? .other
        self.comment = comment ?? "User didin't add comment"
        self.coordinate = coordinate
        self.photosPath = url
        self.photosCount = amountOfPhotos
    }
    
    func mapItem() -> MKMapItem {  // open annotation on maps
        guard let title = title else { return .init() }
        let addressDict = [CNPostalAddressStreetKey: title]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
    
}
