//
//  SplashViewController.swift
//  location_tracker_case
//
//  Created by Aysema Çam on 21.05.2025.
//

import UIKit
import SnapKit

final class SplashViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .appIcon
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.locationTracker
        label.textAlignment = .center
        label.textColor = .splashTitleColor
        label.font = UIFont.fredoka(weight: .semiBold, size: 22)
        return label
    }()
    

    
    // MARK: - Properties
    private let viewModel = SplashViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.checkLocationPermission()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .mainBackColor
        
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
            make.width.height.equalTo(120)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
     
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
    }
}

// MARK: - SplashViewModelDelegate
extension SplashViewController: SplashViewModelDelegate {
    func navigateToMapScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            let mapViewController = MapViewController()
            self?.navigationController?.pushViewController(mapViewController, animated: true)
        }
    }
    
    func showLocationError(_ error: LocationError) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: Constants.locationAccessRequired,
                message: error.userFriendlyMessage,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: Constants.ok, style: .default))
            self?.present(alert, animated: true)
        }
    }
} 
