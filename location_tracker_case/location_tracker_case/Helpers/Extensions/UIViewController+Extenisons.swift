//
//  UIViewController+Extenisons.swift
//  location_tracker_case
//
//  Created by Aysema Çam on 22.05.2025.
//

import Foundation
import UIKit
import SnapKit

extension UIViewController {
    func showToast(message: String, isSuccess: Bool = true, duration: TimeInterval = 2.0) {
        let toastView = ToastView(message: message, isSuccess: isSuccess)
        view.addSubview(toastView)
        
        toastView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-90)
            make.width.lessThanOrEqualTo(view.snp.width).multipliedBy(0.8)
            make.height.greaterThanOrEqualTo(40)
        }
        
        UIView.animate(withDuration: 0.2) {
            toastView.alpha = 1
            toastView.transform = CGAffineTransform(translationX: 0, y: -5)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: 0.2, animations: {
                toastView.alpha = 0
                toastView.transform = CGAffineTransform(translationX: 0, y: 5)
            }, completion: { _ in
                toastView.removeFromSuperview()
            })
        }
    }
}
