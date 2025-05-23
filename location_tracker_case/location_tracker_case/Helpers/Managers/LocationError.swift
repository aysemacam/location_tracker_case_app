//
//  LocationError.swift
//  location_tracker_case
//
//  Created by Aysema Çam on 22.05.2025.
//

import Foundation

enum LocationError: Error {
    case permissionDenied
    case permissionRestricted
    case locationUnavailable
    case saveFailed
    case loadFailed
    case unknown(String)
    
    var localizedDescription: String {
        switch self {
        case .permissionDenied:
            return Constants.permissionDenied
        case .permissionRestricted:
            return Constants.permissionRestricted
        case .locationUnavailable:
            return Constants.locationUnavailable
        case .saveFailed:
            return Constants.saveFailed
        case .loadFailed:
            return Constants.loadFailed
        case .unknown(let message):
            return "\(Constants.locationError): \(message)"
        }
    }
    
    var userFriendlyMessage: String {
        switch self {
        case .permissionDenied:
            return Constants.permissionDeniedFriendlyMessage
        case .permissionRestricted:
            return Constants.permissionRestrictedFriendlyMessage
        case .locationUnavailable:
            return Constants.locationUnavailableFriendlyMessage
        case .saveFailed, .loadFailed:
            return Constants.saveFailedFriendlyMessage
        case .unknown:
            return Constants.unknownFriendlyMessage
        }
    }
} 
