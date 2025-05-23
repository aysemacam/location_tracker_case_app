//
//  MapViewController.swift
//  location_tracker_case
//
//  Created by Aysema Çam on 21.05.2025.
//

import UIKit
import CoreLocation
import MapKit

final class MapViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var mapView: MapView = {
        let view = MapView()
        view.mapType = .standard
        view.showCompass = true
        view.showScale = true
        view.showTraffic = false
        return view
    }()
    
    // MARK: - Properties
    private let viewModel = MapViewModel()
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegates()
        setupViewModel()
    }
    
    // MARK: - Setup Functions
    private func setupUI() {
        view.backgroundColor = .mainBackColor
        view.addSubview(mapView)
        setupConstraints()
        
#if DEBUG
        addTestButton()
#endif
    }
    
#if DEBUG
    private func addTestButton() {
        let testButton = UIButton(type: .system)
        testButton.setTitle(Constants.simulate100m, for: .normal)
        testButton.backgroundColor = .simülateButtonBackColor
        testButton.setTitleColor(.simülateButtonTintColor, for: .normal)
        testButton.titleLabel?.font = .fredoka(weight: .medium, size: 15)
        testButton.layer.cornerRadius = 8
        testButton.addTarget(self, action: #selector(simulateMovement), for: .touchUpInside)
        
        view.addSubview(testButton)
        testButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(150)
        }
    }
    
    @objc private func simulateMovement() {
        viewModel.simulateTestMovement()
    }
#endif
    
    private func setupDelegates() {
        viewModel.delegate = self
        mapView.delegate = self
        mapView.setMapViewDelegate(self)
    }
    
    private func setupViewModel() {
        mapView.isTracking = viewModel.isTracking
        
        if let initialRegion = viewModel.getInitialRegion() {
            mapView.setInitialRegion(initialRegion)
        }
        
        viewModel.startLocationUpdates()
        
        let existingAnnotations = viewModel.getAllAnnotations()
        if !existingAnnotations.isEmpty {
            mapView.addAnnotations(existingAnnotations)
            
            let routeCoordinates = viewModel.getRouteCoordinates()
            mapView.addPolyline(coordinates: routeCoordinates)
        }
    }
    
    private func setupConstraints() {
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - MapViewModelDelegate
extension MapViewController: MapViewModelDelegate {
    func didUpdateUserLocation(_ location: CLLocation) {
        mapView.updateUserLocation(location: location)
    }
    
    func didFailToUpdateLocation(with error: String) {
        showToast(message: error, isSuccess: false, duration: 3.0)
    }
    
    func didUpdateTrackedLocations(_ locations: [LocationAnnotation]) {
        if locations.isEmpty {
            mapView.removeAllAnnotations()
        } else {
            mapView.addAnnotations(locations)
        }
    }
    
    func didToggleTracking(isTracking: Bool) {
        mapView.isTracking = isTracking
        
        let message = isTracking ? Constants.trackingStarted : Constants.trackingStopped
        showToast(message: message, isSuccess: true)
    }
    
    func didUpdateRoute(coordinates: [CLLocationCoordinate2D]) {
        mapView.removeAllOverlays()
        
        if !coordinates.isEmpty {
            mapView.addPolyline(coordinates: coordinates)
        }
    }
    
    func showResetConfirmationAlert(onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(
            title: Constants.resetTracking,
            message: Constants.resetTrackingMessage,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: Constants.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: Constants.reset, style: .destructive) { _ in
            onConfirm()
        })
        
        present(alert, animated: true)
    }
    
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: Constants.ok, style: .default))
        present(alert, animated: true)
    }
}

// MARK: - MapviewDelegate
extension MapViewController: MapViewDelegate {
    func didTapRecenterButton() {
        if let userLocation = viewModel.userLocation {
            mapView.centerToLocation(userLocation)
        }
    }
    
    func didTapTrackingButton() {
        if viewModel.isTracking {
            viewModel.stopLocationTracking()
        } else {
            viewModel.startLocationTracking()
        }
    }
    
    func didTapResetButton() {
        viewModel.requestResetTracking()
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        if let locationAnnotation = annotation as? LocationAnnotation {
            let identifier = "LocationPin"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: locationAnnotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = locationAnnotation
            }
            
            if let markerView = annotationView as? MKMarkerAnnotationView {
                markerView.markerTintColor = .pinTintColor
                markerView.glyphImage = UIImage(systemName: "mappin")
            }
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        guard let locationAnnotation = view.annotation as? LocationAnnotation else { return }
        self.mapView.centerToCoordinate(locationAnnotation.coordinate, animated: true)
        let bottomSheet = LocationBottomSheet()
        bottomSheet.show(on: self.view, for: locationAnnotation)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .routeTintColor.withAlphaComponent(0.7)
            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

