//
//  MarkersManager.swift
//  Violations
//
//  Created by Artyom Zagoskin on 16.01.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import Foundation
import Firebase


// MARK: - Protocols

protocol MarkersManagerDelegate {
    func markersDidUpdate(markers: [Marker], type: MarkersType)
}


// MARK: - Auxiliary Types

enum MarkersType {
    case all
    case saved
    case user
}


// MARK: - Base

final class MarkersManager {
    
    // MARK: Singleton
    
    static var shared = MarkersManager()
    private init() {}
    
    // MARK: Properties
    
    @Multicast var delegate: MarkersManagerDelegate?
    
    private(set) var markers: [Marker] = []
    private(set) var savedMarkers: [Marker] = []
    private(set) var userMarkers: [Marker] = []
    
}


// MARK: - Public API

extension MarkersManager {
    
    func update(markers: [Marker], type: MarkersType) {
        switch type {
        case .all:
            self.markers = markers
        case .saved:
            savedMarkers = markers
        case .user:
            userMarkers = markers
        }
        
        $delegate.invoke { $0?.markersDidUpdate(markers: markers, type: type) }
    }
    
}
