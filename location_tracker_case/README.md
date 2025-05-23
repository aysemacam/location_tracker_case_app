# Location Tracker iOS App

A project that tracks user location and visualizes it on the map with iOS application. It is developed using MVVM architecture.

## Features

- Splash screen with location permission handling
- Real-time location tracking on map
- Route visualization with polylines
- Custom annotation markers for tracked points
- Location data persistence
- Background location tracking
- Interactive map controls (start/stop tracking, reset, recenter)
- Address information for tracked locations

## Architecture

MVVM (Model-View-ViewModel) pattern kullanılmıştır:

- **Models**: Location data structures and business logic
- **Views**: UI components (ViewControllers and custom views)  
- **ViewModels**: Presentation logic and location data management
- **Managers**: Location services and data persistence

## Tech Stack

- **UIKit** - Programmatic UI implementation
- **SnapKit** - Auto Layout constraints
- **MapKit** - Map display and annotations
- **CoreLocation** - GPS tracking and location services
- **UserDefaults** - Local data persistence

## Project Structure

```
location_tracker_case/
├── App/
│   └── AppDelegate.swift
├── Scenes/
│   ├── Splash/
│   │   ├── SplashViewController.swift
│   │   └── SplashViewModel.swift
│   └── Map/
│       ├── MapViewController.swift
│       ├── MapViewModel.swift
│       ├── Views/
│       │   └── MapView.swift
│       └── Models/
│           └── LocationAnnotation.swift
├── Helpers/
│   ├── Extensions/
│   │   ├── UIColor+Extensions.swift
│   │   ├── UIFont+Extensions.swift
│   │   └── UIViewController+Extensions.swift
│   └── Managers/
│       ├── LocationManager.swift
│       ├── LocationError.swift
│       ├── LocationRepository.swift
│       └── GeocodingService.swift
├── Views/
│   ├── LocationBottomSheet.swift
│   └── ToastView.swift
└── Resources/
    ├── Constants.swift
    └── Assets.xcassets
```

## Installation & Setup

1. Clone the repository
2. Open `location_tracker_case.xcodeproj` in Xcode
3. Build and run on simulator or device

**Requirements:**
- iOS 14.0+
- Xcode 13.0+
- Swift 5.0+

## Usage

1. Launch app and grant location permissions
2. Tap "Start" to begin location tracking
3. Move around to see route visualization
4. Tap pins to view location details
5. Use "Reset" to clear tracking data
6. "Recenter" button focuses map on current location

## Testing

For development testing:
- Debug build includes "Simulate 100m" button for movement simulation
- Use Xcode Simulator location simulation features
- Test on physical device for accurate GPS behavior

## Key Implementation Details

- **Protocol-oriented design** for testability and modularity
- **Memory-safe** implementation with proper weak references
- **Error handling** with custom LocationError enum
- **Background location** support (requires "Always" permission)
- **Data persistence** for tracking history
- **Custom UI components** for enhanced user experience

## Future Enhancements

- [ ] Export tracking data (GPX format)
- [ ] Speed and distance calculations  
- [ ] Multiple route history
- [ ] Custom map styling options
- [ ] Search functionality
- [ ] Unit test coverage

---

**Platform:** iOS  
**Language:** Swift  
**Architecture:** MVVM 
