//
//  Marker.swift
//  Violations
//
//  Created by Artyom Zagoskin on 24.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import Foundation
import MapKit
import Contacts


struct Marker {
    let title: String
    let comment: String
    let photosPath: String
    let photosCount: Int
    let date: Date?
    let latitude: String?
    let longitude: String?
    
    var coordinate: CLLocationCoordinate2D {
        guard
            let lat = latitude,
            let lng = longitude,
            let latitude = Double(lat),
            let longitude = Double(lng)
        else { return .init() }

        return .init(latitude: latitude, longitude: longitude)
    }
    
    init(marker: MarkerObject) {
        title = marker.title
        comment = marker.comment
        photosPath = marker.photosPath
        photosCount = marker.photosCount
        date = marker.date
        latitude = marker.latitude
        longitude = marker.longitude
    }
    
}
