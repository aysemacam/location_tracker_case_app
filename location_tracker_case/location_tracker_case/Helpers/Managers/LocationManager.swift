//
//  LocationManager.swift
//  location_tracker_case
//
//  Created by Aysema Çam on 21.05.2025.
//

import UIKit
import CoreLocation

protocol LocationManagerProtocol: AnyObject {
    var currentLocation: CLLocation? { get }
    var isTracking: Bool { get }
    var trackedLocations: [CLLocation] { get }
    
    var didUpdateLocation: ((CLLocation) -> Void)? { get set }
    var didChangeAuthorizationStatus: ((CLAuthorizationStatus) -> Void)? { get set }
    var didAddNewLocationToTrack: ((CLLocation) -> Void)? { get set }
    var didFailWithError: ((LocationError) -> Void)? { get set }
    
    func requestLocationPermission()
    func startLocationTracking()
    func stopLocationTracking()
    func startUpdatingLocation()
    func stopUpdatingLocation()
    func resetTrackedLocations()
    
    #if DEBUG
    func simulateMovement(meters: Double, direction: Double)
    #endif
}

final class LocationManager: NSObject, LocationManagerProtocol {
    static let shared = LocationManager()
    
    private var locationManager: CLLocationManager
    private let repository: LocationRepositoryProtocol
    
    var currentLocation: CLLocation?
    var isTracking: Bool = false
    var lastTrackedLocation: CLLocation?
    var trackedLocations: [CLLocation] = []
    
    var didUpdateLocation: ((CLLocation) -> Void)?
    var didChangeAuthorizationStatus: ((CLAuthorizationStatus) -> Void)?
    var didAddNewLocationToTrack: ((CLLocation) -> Void)?
    var didFailWithError: ((LocationError) -> Void)?

    private let minimumDistanceThreshold: CLLocationDistance = 1
    
    init(repository: LocationRepositoryProtocol = UserDefaultsLocationRepository()) {
        self.repository = repository
        locationManager = CLLocationManager()
        super.init()
        configureLocationManager()
        loadSavedLocations()
    }
    
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.showsBackgroundLocationIndicator = true
    }
    
    func requestLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startLocationTracking() {
        isTracking = true
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationTracking() {
        isTracking = false
        locationManager.stopUpdatingLocation()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func resetTrackedLocations() {
        trackedLocations.removeAll()
        lastTrackedLocation = nil
        repository.clearLocations()
    }
    
    private func saveTrackedLocations() {
        do {
            repository.saveLocations(trackedLocations)
        } catch {
            didFailWithError?(.saveFailed)
        }
    }
    
    private func loadSavedLocations() {
        do {
            trackedLocations = repository.loadSavedLocations()
            lastTrackedLocation = trackedLocations.last
        } catch {
            didFailWithError?(.loadFailed)
        }
    }
    
    // MARK: - Testing Helpers
    #if DEBUG
    func simulateMovement(meters: Double, direction: Double = 0) {
        guard let currentLoc = currentLocation else { return }
        
        let earthRadius = 6371000.0
        let directionRad = direction * .pi / 180
        let lat1 = currentLoc.coordinate.latitude * .pi / 180
        let lon1 = currentLoc.coordinate.longitude * .pi / 180
        let lat2 = asin(sin(lat1) * cos(meters/earthRadius) + cos(lat1) * sin(meters/earthRadius) * cos(directionRad))
        let lon2 = lon1 + atan2(sin(directionRad) * sin(meters/earthRadius) * cos(lat1), cos(meters/earthRadius) - sin(lat1) * sin(lat2))
        let newLat = lat2 * 180 / .pi
        let newLon = lon2 * 180 / .pi
        let newCoordinate = CLLocationCoordinate2D(latitude: newLat, longitude: newLon)
        let simulatedLocation = CLLocation(
            coordinate: newCoordinate,
            altitude: currentLoc.altitude,
            horizontalAccuracy: currentLoc.horizontalAccuracy,
            verticalAccuracy: currentLoc.verticalAccuracy,
            timestamp: Date()
        )
        
        currentLocation = simulatedLocation
        didUpdateLocation?(simulatedLocation)
        
        if isTracking {
            if lastTrackedLocation == nil || simulatedLocation.distance(from: lastTrackedLocation!) >= minimumDistanceThreshold {
                trackedLocations.append(simulatedLocation)
                lastTrackedLocation = simulatedLocation
                didAddNewLocationToTrack?(simulatedLocation)
                saveTrackedLocations()
            }
        }
    }
    #endif
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        didUpdateLocation?(location)
        
        if isTracking {
            if lastTrackedLocation == nil || location.distance(from: lastTrackedLocation!) >= minimumDistanceThreshold {
                trackedLocations.append(location)
                lastTrackedLocation = location
                didAddNewLocationToTrack?(location)
                saveTrackedLocations()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        didChangeAuthorizationStatus?(status)
        
        switch status {
        case .denied:
            didFailWithError?(.permissionDenied)
        case .restricted:
            didFailWithError?(.permissionRestricted)
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdatingLocation()
        case .notDetermined:
            break
        @unknown default:
            didFailWithError?(.unknown("Unknown authorization status"))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let locationError: LocationError
        
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                locationError = .permissionDenied
            case .locationUnknown:
                locationError = .locationUnavailable
            default:
                locationError = .unknown(clError.localizedDescription)
            }
        } else {
            locationError = .unknown(error.localizedDescription)
        }
        
        didFailWithError?(locationError)
    }
} 
