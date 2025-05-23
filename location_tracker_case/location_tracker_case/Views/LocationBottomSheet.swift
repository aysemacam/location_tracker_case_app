//
//  LocationBottomSheet.swift
//  location_tracker_case
//
//  Created by Aysema Çam on 23.05.2025.
//

import UIKit
import SnapKit
import CoreLocation

final class LocationBottomSheet: UIView {
    
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainBackColor
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.shadowColor.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 10
        return view
    }()
    
    private lazy var handleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.locationInfo
        label.font = .fredoka(weight: .semiBold, size: 18)
        label.textColor = .locationInfoTitleColor
        label.textAlignment = .left
        return label
    }()
    
    private lazy var addressTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.adress
        label.font = .fredoka(weight: .medium, size: 14)
        label.textColor = .locationInfoSubTitleColor
        label.textAlignment = .left
        return label
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.font = .fredoka(weight: .regular, size: 16)
        label.textColor = .locationInfoTextColor
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private lazy var coordinatesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.coordinates
        label.font = .fredoka(weight: .medium, size: 14)
        label.textColor = .locationInfoSubTitleColor
        label.textAlignment = .left
        return label
    }()
    
    private lazy var coordinatesLabel: UILabel = {
        let label = UILabel()
        label.font = .fredoka(weight: .regular, size: 14)
        label.textColor = .locationInfoTextColor
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .locationInfoTitleColor
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .lightGray
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private var bottomConstraint: Constraint?
    private let sheetHeight: CGFloat = 200
    
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
        backgroundColor = UIColor.clear
        
        addSubview(containerView)
        containerView.addSubview(handleView)
        containerView.addSubview(closeButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(addressTitleLabel)
        containerView.addSubview(addressLabel)
        containerView.addSubview(coordinatesTitleLabel)
        containerView.addSubview(coordinatesLabel)
        containerView.addSubview(loadingIndicator)
        
        setupConstraints()
        setupGestures()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(sheetHeight)
            self.bottomConstraint = make.bottom.equalToSuperview().offset(sheetHeight).constraint
        }
        
        handleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(5)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(closeButton.snp.left).offset(-8)
        }
        
        addressTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(addressTitleLabel.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(20)
        }
        
        coordinatesTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
        }
        
        coordinatesLabel.snp.makeConstraints { make in
            make.top.equalTo(coordinatesTitleLabel.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.centerY.equalTo(addressLabel)
            make.left.equalTo(addressLabel)
        }
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        containerView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        hide()
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        let containerFrame = containerView.frame
        
        if !containerFrame.contains(location) {
            hide()
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)
        
        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                bottomConstraint?.update(offset: translation.y)
                layoutIfNeeded()
            }
        case .ended:
            if translation.y > 50 || velocity.y > 500 {
                hide()
            } else {
                bottomConstraint?.update(offset: 0)
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                    self.layoutIfNeeded()
                })
            }
        default:
            break
        }
    }
    
    // MARK: - Public Methods
    func show(on parentView: UIView, for annotation: LocationAnnotation) {
        parentView.addSubview(self)
        
        snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        layoutIfNeeded()
        
        bottomConstraint?.update(offset: 0)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.layoutIfNeeded()
        })
        
        displayLocationInfo(for: annotation)
    }
    
    func hide() {
        
        bottomConstraint?.update(offset: sheetHeight)
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
    
    private func displayLocationInfo(for annotation: LocationAnnotation) {
        let coordinateText = String(format: "%.6f, %.6f",
                                    annotation.coordinate.latitude,
                                    annotation.coordinate.longitude)
        coordinatesLabel.text = coordinateText
        
        if let address = annotation.address, !address.isEmpty {
            addressLabel.text = address
            loadingIndicator.stopAnimating()
        } else {
            addressLabel.text = Constants.gettinAddressInfo
            loadingIndicator.startAnimating()
            
            GecodingService.shared.getAddress(for: annotation.coordinate) { [weak self] address in
                DispatchQueue.main.async {
                    self?.loadingIndicator.stopAnimating()
                    if let address = address {
                        self?.addressLabel.text = address
                        annotation.address = address
                    } else {
                        self?.addressLabel.text = Constants.noAddressFound
                    }
                }
            }
        }
    }
}
