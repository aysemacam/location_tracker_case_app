//
//  Constants.swift
//  location_tracker_case
//
//  Created by Aysema Çam on 22.05.2025.
//

import Foundation

struct Constants{
    
    static let simulate100m = "Simulate 100m"
    static let trackingStarted = "Location tracking started"
    static let trackingStopped = "Location tracking stopped"
    static let error = "Error"
    static let ok = "OK"
    static let resetTracking = "Reset Tracking"
    static let resetTrackingMessage = "Are you sure you want to reset your tracking data? This action cannot be undone."
    static let cancel = "Cancel"
    static let reset = "Reset"
    static let recording = "Recording"
    static let start = "Start"
    static let noAddressFound = "No address found"
    static let unknownAddress = "Unknown address"
    static let locationInfo = "📍 Location Information"
    static let adress = "Adress:"
    static let coordinates = "Coordinates:"
    static let gettinAddressInfo = "Receiving address information.."
    static let trackedLocation = "Tracked Location"
    static let locationTracker = "Location Tracker"
    static let locationError = "Location Error"
    static let locationAccessRequired = "Location Access Required"

    static let permissionDenied = "Location permission denied. Please enable location access in Settings."
    static let permissionRestricted = "Location access is restricted on this device."
    static let locationUnavailable = "Unable to determine current location."
    static let saveFailed = "Failed to save location data."
    static let loadFailed = "Failed to load saved location data."
    
    static let permissionDeniedFriendlyMessage = "Please allow location access to use this feature"
    static let permissionRestrictedFriendlyMessage = "Location access is not available"
    static let locationUnavailableFriendlyMessage = "Cannot find your location"
    static let saveFailedFriendlyMessage = "Data operation failed"
    static let unknownFriendlyMessage = "Something went wrong"
 
}
