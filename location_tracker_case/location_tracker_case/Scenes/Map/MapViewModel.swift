//
//  MapViewModel.swift
//  location_tracker_case
//
//  Created by Aysema Çam on 21.05.2025.
//

import CoreLocation
import MapKit

protocol MapViewModelDelegate: AnyObject {
    func didUpdateUserLocation(_ location: CLLocation)
    func didFailToUpdateLocation(with error: String)
    func didUpdateTrackedLocations(_ locations: [LocationAnnotation])
    func didToggleTracking(isTracking: Bool)
    func didUpdateRoute(coordinates: [CLLocationCoordinate2D])
    func showResetConfirmationAlert(onConfirm: @escaping () -> Void)
    func showErrorAlert(title: String, message: String)
}

final class MapViewModel {
    
    weak var delegate: MapViewModelDelegate?
    private let locationManager: LocationManagerProtocol
    private var trackingAnnotations: [LocationAnnotation] = []
    
    var isTracking: Bool {
        return locationManager.isTracking
    }
    
    var userLocation: CLLocation? {
        return locationManager.currentLocation
    }
    
    init(locationManager: LocationManagerProtocol = LocationManager.shared) {
        self.locationManager = locationManager
        setupLocationTracking()
        loadExistingTrackingData()
    }
    
    private func setupLocationTracking() {
        locationManager.didUpdateLocation = { [weak self] location in
            self?.delegate?.didUpdateUserLocation(location)
        }
        
        locationManager.didAddNewLocationToTrack = { [weak self] location in
            self?.addAnnotationForLocation(location)
            self?.updateRoutePolyline()
        }
        
        locationManager.didFailWithError = { [weak self] error in
            self?.handleLocationError(error)
        }
    }
    
    private func handleLocationError(_ error: LocationError) {
        delegate?.showErrorAlert(
            title: Constants.locationError,
            message: error.userFriendlyMessage
        )
    }
    
    private func loadExistingTrackingData() {
        for location in locationManager.trackedLocations {
            addAnnotationForLocation(location, shouldNotify: false)
        }
        
        if !trackingAnnotations.isEmpty {
            delegate?.didUpdateTrackedLocations(trackingAnnotations)
            updateRoutePolyline()
        }
    }
    
    private func addAnnotationForLocation(_ location: CLLocation, shouldNotify: Bool = true) {
        let annotation = LocationAnnotation(
            coordinate: location.coordinate,
            title: Constants.trackedLocation,
            subtitle: location.timestamp.formatted(date: .abbreviated, time: .shortened)
        )
        
        trackingAnnotations.append(annotation)
        
        if shouldNotify {
            delegate?.didUpdateTrackedLocations([annotation])
        }
    }
    
    private func updateRoutePolyline() {
        let coordinates = getRouteCoordinates()
        delegate?.didUpdateRoute(coordinates: coordinates)
    }
    
    func getRouteCoordinates() -> [CLLocationCoordinate2D] {
        return locationManager.trackedLocations.map { $0.coordinate }
    }
    
    func startLocationTracking() {
        locationManager.requestLocationPermission()
        locationManager.startLocationTracking()
        delegate?.didToggleTracking(isTracking: true)
    }
    
    func stopLocationTracking() {
        locationManager.stopLocationTracking()
        delegate?.didToggleTracking(isTracking: false)
    }
    
    func requestResetTracking() {
        delegate?.showResetConfirmationAlert { [weak self] in
            self?.executeResetTracking()
        }
    }
    
    private func executeResetTracking() {
        locationManager.resetTrackedLocations()
        trackingAnnotations.removeAll()
        
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.didUpdateTrackedLocations([])
            self?.delegate?.didUpdateRoute(coordinates: [])
        }
    }
    
    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    func getInitialRegion() -> MKCoordinateRegion? {
        guard let location = userLocation else { return nil }
        
        let region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        return region
    }
    
    func getAllAnnotations() -> [LocationAnnotation] {
        return trackingAnnotations
    }
    
    #if DEBUG
    func simulateTestMovement() {
        let randomDirection = Double.random(in: 1.0...90.0)
        locationManager.simulateMovement(meters: 100, direction: randomDirection)
    }
    #endif
}
