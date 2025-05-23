//
//  LocationAnnotation.swift
//  location_tracker_case
//
//  Created by Aysema Çam on 21.05.2025.
//

import MapKit

final class LocationAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var address: String?
    
    let id: String
    var data: [String: Any]?
    
    init(
        id: String = UUID().uuidString,
        coordinate: CLLocationCoordinate2D,
        title: String? = nil,
        subtitle: String? = nil,
        address: String? = nil,
        data: [String: Any]? = nil
    ) {
        self.id = id
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.address = address
        self.data = data
        super.init()
    }
}
