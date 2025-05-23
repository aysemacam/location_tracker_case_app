//
//  SplashViewModel.swift
//  location_tracker_case
//
//  Created by Aysema Çam on 21.05.2025.
//


import Foundation
import CoreLocation

protocol SplashViewModelDelegate: AnyObject {
    func navigateToMapScreen()
    func showLocationError(_ error: LocationError)
}

final class SplashViewModel {
    weak var delegate: SplashViewModelDelegate?
    private let locationManager: LocationManagerProtocol
    
    init(locationManager: LocationManagerProtocol = LocationManager.shared) {
        self.locationManager = locationManager
    }
    
    func checkLocationPermission() {
        locationManager.didChangeAuthorizationStatus = { [weak self] status in
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self?.locationManager.startUpdatingLocation()
                self?.delegate?.navigateToMapScreen()
            case .denied, .restricted:
                break
            case .notDetermined:
                self?.locationManager.requestLocationPermission()
            @unknown default:
                break
            }
        }
        
        locationManager.didFailWithError = { [weak self] error in
            self?.delegate?.showLocationError(error)
        }
        
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
            delegate?.navigateToMapScreen()
        } else if status == .notDetermined {
            locationManager.requestLocationPermission()
        }
    }
} 
