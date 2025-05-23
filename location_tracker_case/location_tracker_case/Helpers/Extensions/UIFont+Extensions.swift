//
//  UIFont+Extensions.swift
//  location_tracker_case
//
//  Created by Aysema Çam on 22.05.2025.
//

import UIKit

extension UIFont {

    enum FredokaFontWeight: String {
        case regular = "Regular"
        case bold = "Bold"
        case semiBold = "SemiBold"
        case medium = "Medium"
        case light = "Light"
    }
    enum QuicksandWeight: String {
        case regular = "Regular"
        case bold = "Bold"
        case semiBold = "SemiBold"
        case medium = "Medium"
        case light = "Light"
    }

    static func fredoka(weight: FredokaFontWeight, size: Int) -> UIFont {
        let fontName = "Fredoka-\(weight.rawValue)"
        guard let font = UIFont(name: fontName, size: CGFloat(size)) else {
            fatalError("Font '\(fontName)' not found, pleas check info.plst.")
        }
        return font
    }
}
