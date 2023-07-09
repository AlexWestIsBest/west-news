//
//  LocationManager.swift
//  WestNews
//
//  Created by Alex Westerlund on 6/30/23.
//

import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var permissionAlert = false
    @Published var hasLocationPermissions = false
    @AppStorage("latitude") var latitude: Double = 39.4305
    @AppStorage("longitude") var longitude: Double = -82.5388
    
    // Extracted from placemark
    @AppStorage("country") var country: String = "none"
    @AppStorage("countryCode") var countryCode: String = "none"
    @AppStorage("administrativeArea") var administrativeArea: String = "none" // State
    @AppStorage("subAdministrativeArea") var subAdministrativeArea: String = "none" // County
    @AppStorage("name") var name: String = "none" // First line of street address typically
    @AppStorage("postalCode") var postalCode: String = "none"

    private let locationManager = CLLocationManager()
    private var locationUpdateCompletion: (() -> Void)?
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocationUpdate(manuallyInitiated: Bool, completion: @escaping () -> Void) {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            permissionAlert = manuallyInitiated // If the user pressed "Refresh", shows popup. If alarm button requests location, no popup.
            completion()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            fatalError("New status introduced in CLLocationManager.authorizationStatus")
        }
        
        locationUpdateCompletion = completion
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // Start updating the location when the user grants permission
            hasLocationPermissions = true
            if locationUpdateCompletion != nil {
                locationManager.startUpdatingLocation()
            }
        case .denied, .restricted, .notDetermined:
            // Do nothing, permissionAlert is already set in requestLocationUpdate
            break
        @unknown default:
            fatalError("New status introduced in CLLocationManager.authorizationStatus")
        }

        // Call the completion closure now that authorization status has changed, but only if requestLocationUpdate has been called already.
        if locationUpdateCompletion != nil {
            locationUpdateCompletion?()
            locationUpdateCompletion = nil // Make sure to clear the completion closure to avoid retaining it unnecessarily
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            locationManager.stopUpdatingLocation() // We stop updating the location after we get the coordinates
            self.getPlacemarkInfo(for: location)

        }
        locationUpdateCompletion?()
        locationUpdateCompletion = nil
    }
    
    func getPlacemarkInfo(for location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let placemark = placemarks?.first {
                self.name = placemark.name ?? "none"
                self.administrativeArea = placemark.administrativeArea ?? "none"
                self.subAdministrativeArea = placemark.subAdministrativeArea ?? "none"
                self.postalCode = placemark.postalCode ?? "none"
                self.country = placemark.country ?? "none"
                self.countryCode = placemark.isoCountryCode ?? "none"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
