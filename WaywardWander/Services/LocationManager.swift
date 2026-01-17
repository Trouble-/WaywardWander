import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()

    @Published var currentLocation: CLLocation?
    @Published var heading: CLLocationDirection = 0
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    @Published var distanceToTarget: Double?
    @Published var bearingToTarget: Double?

    var targetLocation: CLLocation? {
        didSet {
            updateTargetMetrics()
        }
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.headingFilter = 1
    }

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    func stopUpdating() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }

    private func updateTargetMetrics() {
        guard let current = currentLocation, let target = targetLocation else {
            distanceToTarget = nil
            bearingToTarget = nil
            return
        }

        distanceToTarget = current.distance(from: target)
        bearingToTarget = calculateBearing(from: current, to: target)
    }

    private func calculateBearing(from source: CLLocation, to destination: CLLocation) -> Double {
        let lat1 = source.coordinate.latitude.degreesToRadians
        let lng1 = source.coordinate.longitude.degreesToRadians
        let lat2 = destination.coordinate.latitude.degreesToRadians
        let lng2 = destination.coordinate.longitude.degreesToRadians

        let dLng = lng2 - lng1

        let y = sin(dLng) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng)

        let bearing = atan2(y, x).radiansToDegrees

        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }

    func arrowRotation() -> Double {
        guard let bearing = bearingToTarget else { return 0 }
        let rotation = bearing - heading
        return rotation
    }

    func isWithinRadius(_ radius: Double) -> Bool {
        guard let distance = distanceToTarget else { return false }
        return distance <= radius
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        updateTargetMetrics()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy >= 0 {
            heading = newHeading.trueHeading
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdating()
        default:
            break
        }
    }
}

extension Double {
    var degreesToRadians: Double { self * .pi / 180 }
    var radiansToDegrees: Double { self * 180 / .pi }
}
