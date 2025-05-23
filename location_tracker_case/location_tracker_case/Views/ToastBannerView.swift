//
//  ToastBannerView.swift
//  location_tracker_case
//
//  Created by Aysema Çam on 21.05.2025.
//

import UIKit
import SnapKit

final class ToastBannerView: UIView {
    
    // MARK: - Types
    enum ToastType {
        case success
        case error
        case info
        
        var backgroundColor: UIColor {
            switch self {
            case .success:
                return .bannerBackColor.withAlphaComponent(0.8)
            case .error:
                return .systemRed.withAlphaComponent(0.8)
            case .info:
                return .systemBlue.withAlphaComponent(0.8)
            }
        }
    }
    
    // MARK: - Properties
    private let message: String
    private let type: ToastType
    private let duration: TimeInterval
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = message
        label.textColor = .bannerTintColor
        label.textAlignment = .center
        label.font = .fredoka(weight: .medium, size: 14)
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initializers
    init(message: String, type: ToastType = .info, duration: TimeInterval = 2.0) {
        self.message = message
        self.type = type
        self.duration = duration
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = type.backgroundColor
        layer.cornerRadius = 8
        clipsToBounds = true
        alpha = 0
        
        addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }
    
    // MARK: - Public Methods
    func show(on parentView: UIView) {
        parentView.addSubview(self)
        
        snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(parentView.safeAreaLayoutGuide.snp.top).offset(10)
            make.width.lessThanOrEqualTo(parentView.snp.width).multipliedBy(0.8)
            make.height.greaterThanOrEqualTo(40)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            self.transform = CGAffineTransform(translationX: 0, y: 5)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 0
                self.transform = CGAffineTransform(translationX: 0, y: -5)
            }, completion: { _ in
                self.removeFromSuperview()
            })
        }
    }
} 
