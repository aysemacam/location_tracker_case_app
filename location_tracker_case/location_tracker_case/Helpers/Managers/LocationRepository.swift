//
//  LocationRepository.swift
//  location_tracker_case
//
//  Created by Aysema Çam on 22.05.2025.
//

import Foundation
import CoreLocation

protocol LocationRepositoryProtocol {
    func saveLocations(_ locations: [CLLocation])
    func loadSavedLocations() -> [CLLocation]
    func clearLocations()
}

final class UserDefaultsLocationRepository: LocationRepositoryProtocol {
    private let userDefaults: UserDefaults
    private let locationsKey = "trackedLocations"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func saveLocations(_ locations: [CLLocation]) {
        let locationDicts = locations.map { location -> [String: Double] in
            return [
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude,
                "timestamp": location.timestamp.timeIntervalSince1970
            ]
        }
        
        userDefaults.set(locationDicts, forKey: locationsKey)
    }
    
    func loadSavedLocations() -> [CLLocation] {
        guard let locationDicts = userDefaults.array(forKey: locationsKey) as? [[String: Double]] else {
            return []
        }
        
        return locationDicts.compactMap { dict -> CLLocation? in
            guard let latitude = dict["latitude"],
                  let longitude = dict["longitude"],
                  let timestamp = dict["timestamp"] else {
                return nil
            }
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let date = Date(timeIntervalSince1970: timestamp)
            return CLLocation(coordinate: coordinate, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: date)
        }
    }
    
    func clearLocations() {
        userDefaults.removeObject(forKey: locationsKey)
    }
} 
