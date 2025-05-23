//
//  GecodingService.swift
//  location_tracker_case
//
//  Created by Aysema Çam on 22.05.2025.
//

import Foundation
import CoreLocation

protocol GecodingServiceDelegate: AnyObject {
    func didGetAddress(_ address: String, for coordinate: CLLocationCoordinate2D)
    func didFailToGetAddress(for coordinate: CLLocationCoordinate2D, error: String)
}

final class GecodingService {
    static let shared = GecodingService()
    
    private let geocoder = CLGeocoder()
    weak var delegate: GecodingServiceDelegate?
    
    private init() {}
    
    func getAddress(for coordinate: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil)
                    self?.delegate?.didFailToGetAddress(for: coordinate, error: error.localizedDescription)
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    completion(nil)
                    self?.delegate?.didFailToGetAddress(for: coordinate, error: Constants.noAddressFound)
                    return
                }
                
                let address = self?.formatAddress(from: placemark) ?? Constants.unknownAddress
                completion(address)
                self?.delegate?.didGetAddress(address, for: coordinate)
            }
        }
    }
    
    private func formatAddress(from placemark: CLPlacemark) -> String {
        var addressComponents: [String] = []
        
        if let name = placemark.name {
            addressComponents.append(name)
        }
        
        if let thoroughfare = placemark.thoroughfare {
            addressComponents.append(thoroughfare)
        }
        
        if let subThoroughfare = placemark.subThoroughfare {
            if let lastComponent = addressComponents.last,
               !lastComponent.contains(subThoroughfare) {
                addressComponents.append(subThoroughfare)
            }
        }
        
        if let locality = placemark.locality {
            addressComponents.append(locality)
        }
        
        if let administrativeArea = placemark.administrativeArea {
            addressComponents.append(administrativeArea)
        }
        
        if let country = placemark.country {
            addressComponents.append(country)
        }
        
        return addressComponents.isEmpty ? Constants.unknownAddress : addressComponents.joined(separator: ", ")
    }
} 
