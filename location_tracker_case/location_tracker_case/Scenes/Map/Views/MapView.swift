//
//  MapView.swift
//  location_tracker_case
//
//  Created by Aysema Çam on 21.05.2025.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewDelegate: AnyObject {
    func didTapRecenterButton()
    func didTapTrackingButton()
    func didTapResetButton()
}

final class MapView: UIView {
    
    // MARK: - UI Components
    private(set) lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }()
    
    private lazy var recenterButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.backgroundColor = .recenterButtonBackColor
        button.tintColor = .recenterButtonTintColor
        button.layer.cornerRadius = 22
        button.layer.shadowColor = UIColor.shadowColor.cgColor
        button.layer.shadowOffset = CGSize(width: 1, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 3
        button.addTarget(self, action: #selector(recenterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var recordingView: UIView = {
        let view = UIView()
        view.backgroundColor = .startButtonBackColor
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.shadowColor.cgColor
        view.layer.shadowOffset = CGSize(width: 1, height: 2)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 3
        view.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(trackingButtonTapped))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    private lazy var recordingLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.recording
        label.textColor = .startButtonTintColor
        label.font = .fredoka(weight: .medium, size: 16)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var dotsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .startButtonTintColor
        label.font = .fredoka(weight: .medium, size: 16)
        return label
    }()
    
    private lazy var trackingButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.start, for: .normal)
        button.backgroundColor = .startButtonBackColor
        button.setTitleColor(.startButtonTintColor, for: .normal)
        button.titleLabel?.font = .fredoka(weight: .medium, size: 16)
        button.layer.cornerRadius = 8
        button.layer.shadowColor = UIColor.shadowColor.cgColor
        button.layer.shadowOffset = CGSize(width: 1, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 3
        button.addTarget(self, action: #selector(trackingButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.reset, for: .normal)
        button.backgroundColor = .resetButtonBackColor
        button.setTitleColor(.resetButtonTintColor, for: .normal)
        button.titleLabel?.font = .fredoka(weight: .medium, size: 16)
        button.layer.cornerRadius = 8
        button.layer.shadowColor = UIColor.shadowColor.cgColor
        button.layer.shadowOffset = CGSize(width: 1, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 3
        button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    weak var delegate: MapViewDelegate?
    var isTracking: Bool = false {
        didSet {
            updateTrackingButtonAppearance()
            if isTracking {
                startDotAnimation()
            } else {
                stopDotAnimation()
            }
        }
    }
    
    var mapType: MKMapType = .standard {
        didSet {
            mapView.mapType = mapType
        }
    }
    
    var showCompass: Bool =  false {
        didSet {
            mapView.showsCompass = showCompass
        }
    }
    
    var showScale: Bool = false {
        didSet {
            mapView.showsScale = showScale
        }
    }
    
    var showTraffic: Bool = false {
        didSet {
            mapView.showsTraffic = showTraffic
        }
    }
    
    private var dotAnimationTimer: Timer?
    private var dotCount = 0
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .mainBackColor
        addSubview(mapView)
        addSubview(recenterButton)
        
        recordingView.addSubview(recordingLabel)
        recordingView.addSubview(dotsLabel)
        
        addSubview(trackingButton)
        addSubview(recordingView)
        addSubview(resetButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        recordingLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        dotsLabel.snp.makeConstraints { make in
            make.left.equalTo(recordingLabel.snp.right).offset(2)
            make.centerY.equalToSuperview()
        }
        
        trackingButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.left.equalToSuperview().inset(20)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.width.equalTo(resetButton.snp.width)
        }
        
        recordingView.snp.makeConstraints { make in
            make.edges.equalTo(trackingButton)
        }
        
        resetButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.right.equalToSuperview().inset(20)
            make.left.equalTo(trackingButton.snp.right).offset(10)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
        
        recenterButton.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.right.equalToSuperview().inset(20)
            make.bottom.equalTo(resetButton.snp.top).offset(-15)
        }
    }
    
    private func updateTrackingButtonAppearance() {
        if isTracking {
            trackingButton.isHidden = true
            recordingView.isHidden = false
        } else {
            trackingButton.isHidden = false
            recordingView.isHidden = true
        }
    }
    
    private func startDotAnimation() {
        dotCount = 0
        dotAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.dotCount = (self.dotCount % 3) + 1
            let dots = String(repeating: ".", count: self.dotCount)
            self.updateTrackingTitle(dots: dots)
        }
    }
    
    private func stopDotAnimation() {
        dotAnimationTimer?.invalidate()
        dotAnimationTimer = nil
        dotsLabel.text = ""
    }
    
    private func updateTrackingTitle(dots: String) {
        dotsLabel.text = dots
    }
    
    // MARK: - Actions
    @objc private func recenterButtonTapped() {
        delegate?.didTapRecenterButton()
    }
    
    @objc private func trackingButtonTapped() {
        delegate?.didTapTrackingButton()
    }
    
    @objc private func resetButtonTapped() {
        delegate?.didTapResetButton()
    }
    
    // MARK: - Public Methods
    func setMapViewDelegate(_ delegate: MKMapViewDelegate) {
        mapView.delegate = delegate
    }
    
    func updateUserLocation(location: CLLocation) {
        if isTracking {
            centerToLocation(location)
        }
    }
    
    func setInitialRegion(_ region: MKCoordinateRegion) {
        mapView.setRegion(region, animated: true)
    }
    
    func centerToLocation(_ location: CLLocation) {
        let region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        mapView.setRegion(region, animated: true)
    }
    
    func addAnnotation(_ annotation: MKAnnotation) {
        mapView.addAnnotation(annotation)
    }
    
    func addAnnotations(_ annotations: [MKAnnotation]) {
        mapView.addAnnotations(annotations)
    }
    
    func removeAnnotation(_ annotation: MKAnnotation) {
        mapView.removeAnnotation(annotation)
    }
    
    func removeAllAnnotations() {
        let annotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(annotations)
    }
    
    func addPolyline(coordinates: [CLLocationCoordinate2D]) {
        if coordinates.count > 1 {
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            mapView.addOverlay(polyline)
        }
    }
    
    func removeAllOverlays() {
        mapView.removeOverlays(mapView.overlays)
    }
    
    func centerToCoordinate(_ coordinate: CLLocationCoordinate2D, animated: Bool = true) {
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
        
        mapView.setRegion(region, animated: animated)
    }
}
