//
//  UIColor+Extensions.swift
//  location_tracker_case
//
//  Created by Aysema Çam on 21.05.2025.
//

import UIKit

extension UIColor {
    static let splashTitleColor = UIColor(lightHex: "#3D337B", darkHex: "#ECE3FA")

    static let recenterButtonTintColor = UIColor(lightHex: "#874FFF", darkHex: "#FFFFFF")
    static let recenterButtonBackColor = UIColor(lightHex: "#FFFFFF", darkHex: "#874FFF")
    static let simülateButtonTintColor = UIColor(lightHex: "#FFFFFF", darkHex: "#FFFFFF")
    static let simülateButtonBackColor = UIColor(lightHex: "#874FFF", darkHex: "#874FFF")
    static let startButtonBackColor = UIColor(lightHex: "#FFFFFF", darkHex: "#ECE3FA")
    static let startButtonTintColor = UIColor(lightHex: "#874FFF", darkHex: "#874FFF")
    static let resetButtonBackColor = UIColor(lightHex: "#FFFFFF", darkHex: "#ECE3FA")
    static let resetButtonTintColor = UIColor(lightHex: "#E34A4A", darkHex: "#E34A4A")
    static let bannerTintColor = UIColor(lightHex: "#FFFFFF", darkHex: "#FFFFFF")
    static let bannerBackColor = UIColor(lightHex: "#874FFF", darkHex: "#874FFF")
    static let pinTintColor = UIColor(lightHex: "#874FFF", darkHex: "#874FFF")
    static let routeTintColor = UIColor(lightHex: "#9D8ABB", darkHex: "#DACFEB")
    static let shadowColor = UIColor(lightHex: "#000000", darkHex: "#000000")
    static let mainBackColor = UIColor(lightHex: "#FFFFFF", darkHex: "#161721")
    static let whiteColor = UIColor(lightHex: "#FFFFFF", darkHex: "#FFFFFF")
    static let blackColor = UIColor(lightHex: "#000000", darkHex: "#000000")
    static let locationInfoTitleColor = UIColor(lightHex: "#874FFF", darkHex: "#DACFEB")
    static let locationInfoSubTitleColor = UIColor(lightHex: "#9B9B9B", darkHex: "#929090")
    static let locationInfoTextColor = UIColor(lightHex: "#000000", darkHex: "#FFFFFF")
    
    convenience init(lightHex: String, darkHex: String) {
        let lightColor = UIColor(hex: lightHex)
        let darkColor = UIColor(hex: darkHex)
        
        self.init { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? darkColor : lightColor
        }
    }
    
    private convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
