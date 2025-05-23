//
//  ToastView.swift
//  location_tracker_case
//
//  Created by Aysema Çam on 21.05.2025.
//

import UIKit
import SnapKit

final class ToastView: UIView {
    
    // MARK: - UI Components
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .bannerTintColor
        label.textAlignment = .center
        label.font = .fredoka(weight: .medium, size: 14)
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Initializers
    init(message: String, isSuccess: Bool) {
        super.init(frame: .zero)
        messageLabel.text = message
        backgroundColor = isSuccess ? .bannerBackColor.withAlphaComponent(0.9) : .systemRed.withAlphaComponent(0.9)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        layer.cornerRadius = 8
        clipsToBounds = true
        alpha = 0
        
        addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }
} 
