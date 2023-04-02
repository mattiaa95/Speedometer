import Foundation
import CoreLocation
import Combine
import MapKit
import SwiftUI
class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    let objectWillChange = PassthroughSubject<Void, Never>()
    let green: Color = Color(red: 0, green: 1, blue: 0, opacity: 1)
    let red: Color = Color(red: 1, green: 0, blue: 0, opacity: 1)
    @Published var speedMph: String = "???" {
        willSet { objectWillChange.send() }
    }
    @Published var speedKmh: String = "???" {
        willSet { objectWillChange.send() }
    }
    @Published var speedColor: Color = .purple {
        willSet { objectWillChange.send() }
    }
    @Published var speedAccuracyMph: String = "???" {
        willSet { objectWillChange.send() }
    }
    @Published var speedAccuracyKmh: String = "???" {
        willSet { objectWillChange.send() }
    }
    @Published var averageSpeedMph: String = "???" {
        willSet { objectWillChange.send() }
    }
    @Published var averageSpeedKmh: String = "???" {
        willSet { objectWillChange.send() }
    }
    @Published var degrees: Double = .zero {
        willSet {
            objectWillChange.send()
        }
    }
    private var startTime: Date?
    private var previousLocation: CLLocation?
    private var distance: Double = 0
    private var speedsMph: [Double] = []
    private var speedsKmh: [Double] = []
    
    override init() {
        super.init()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.startUpdatingLocation()
    }
    
    func resetValues() {
        startTime = nil
        previousLocation = nil
        distance = 0
        speedsMph = []
        speedsKmh = []
        speedMph = "???"
        speedKmh = "???"
        averageSpeedMph = "???"
        averageSpeedKmh = "???"
        degrees = -1
    }
}
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if (location.speedAccuracy >= 0) {
            let sMph: Double = 2.23694 * location.speed
            let sKmh: Double = location.speed * 3.6
            speedMph = String(format: "%.0f", sMph)
            speedKmh = String(format: "%.0f", sKmh)
            speedColor = interpolate(color1: green, color2: red, fraction: sMph / 100)
            let accuracyMph: Double = 2.23694 * location.speedAccuracy // Error en millas por hora
            let accuracyKmh: Double = accuracyMph * 1.60934 // Error en kilómetros por hora
            speedAccuracyMph = String(format: "%.1f", accuracyMph)
            speedAccuracyKmh = String(format: "%.1f", accuracyKmh)
            
            if let previousLocation = previousLocation {
                distance += location.distance(from: previousLocation)
                let timeInterval = location.timestamp.timeIntervalSince(previousLocation.timestamp)
                let speedMph = 2.23694 * distance / timeInterval
                let speedKmh = 3.6 * distance / timeInterval
                speedsMph.append(speedMph)
                speedsKmh.append(speedKmh)
                let averageSpeedMph = speedsMph.reduce(0, +) / Double(speedsMph.count)
                let averageSpeedKmh = speedsKmh.reduce(0, +) / Double(speedsKmh.count)
                self.averageSpeedMph = String(format: "%.0f", averageSpeedMph)
                self.averageSpeedKmh = String(format: "%.0f", averageSpeedKmh)
            }
            
            previousLocation = location
            if startTime == nil {
                startTime = Date()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        degrees = -1 * newHeading.magneticHeading
    }
}
