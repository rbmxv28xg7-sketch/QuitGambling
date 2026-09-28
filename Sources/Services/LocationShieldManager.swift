import SwiftUI
import CoreLocation
import UserNotifications
import SwiftData

/// Manages location-based geofencing and dwell-time detection for trigger zones with zero trigger-word psychology.
@Observable
@MainActor
final class LocationShieldManager: NSObject, CLLocationManagerDelegate {

    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var currentLocation: CLLocation? = nil
    var activeZonesCount: Int = 0

    private let locationManager = CLLocationManager()
    private var pendingDwellTasks: [String: Task<Void, Never>] = [:]

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.authorizationStatus = locationManager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
            locationManager.requestLocation()
        }
    }

    func requestPermissions() {
        let status = locationManager.authorizationStatus
        self.authorizationStatus = status
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
            locationManager.requestLocation()
        }
    }

    func requestAlwaysPermission() {
        locationManager.requestAlwaysAuthorization()
    }

    /// Explicitly request and return the current user GPS coordinate, waiting if necessary.
    func requestAndFetchLocation() async -> CLLocation? {
        let status = locationManager.authorizationStatus
        self.authorizationStatus = status

        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }

        locationManager.startUpdatingLocation()
        locationManager.requestLocation()

        if let loc = currentLocation {
            return loc
        }

        // Wait up to 3 seconds for a fresh GPS fix
        for _ in 0..<30 {
            try? await Task.sleep(for: .milliseconds(100))
            if let loc = currentLocation {
                return loc
            }
        }
        return locationManager.location
    }

    // MARK: - Synchronize Geofences with SwiftData Zones

    func syncZones(_ zones: [TriggerZone]) {
        let activeZones = zones.filter { $0.isActive }
        self.activeZonesCount = activeZones.count

        // Stop monitoring regions no longer present
        let currentMonitored = locationManager.monitoredRegions
        for region in currentMonitored {
            if !activeZones.contains(where: { $0.id.uuidString == region.identifier }) {
                locationManager.stopMonitoring(for: region)
            }
        }

        // Start monitoring active zones (iOS limit: up to 20 regions)
        for zone in activeZones.prefix(20) {
            let center = CLLocationCoordinate2D(latitude: zone.latitude, longitude: zone.longitude)
            let region = CLCircularRegion(
                center: center,
                radius: zone.radiusMeters,
                identifier: zone.id.uuidString
            )
            region.notifyOnEntry = true
            region.notifyOnExit = true
            locationManager.startMonitoring(for: region)
        }
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                self.locationManager.startUpdatingLocation()
                self.locationManager.requestLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.currentLocation = location
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handled silently to avoid crashes on temporary location errors
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let regionId = region.identifier
        Task { @MainActor in
            self.handleRegionEntry(regionId: regionId)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let regionId = region.identifier
        Task { @MainActor in
            self.handleRegionExit(regionId: regionId)
        }
    }

    // MARK: - Dwell Time Logic (Anti-Pink-Elephant Protection)

    private func handleRegionEntry(regionId: String) {
        // Cancel existing task if any
        pendingDwellTasks[regionId]?.cancel()

        // Start dwell task (e.g. wait 3 minutes before taking any action)
        let task = Task {
            // Wait default 3 minutes (180 seconds)
            try? await Task.sleep(for: .seconds(180))
            guard !Task.isCancelled else { return }

            // If user is still here after 3 minutes:
            await self.triggerProtectionAction(regionId: regionId)
        }
        pendingDwellTasks[regionId] = task
    }

    private func handleRegionExit(regionId: String) {
        // User left before dwell timer expired (e.g. was in a bus, driving, or walking past) -> Cancel silently!
        if let task = pendingDwellTasks[regionId] {
            task.cancel()
            pendingDwellTasks.removeValue(forKey: regionId)
        }
    }

    private func triggerProtectionAction(regionId: String) async {
        // Send a discrete, empowering mindfulness check-in with ZERO trigger words
        let content = UNMutableNotificationContent()
        content.title = "Mindful Moment"
        content.body = "Take 5 seconds for a deep breath. How are you feeling right now?"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "dwell_\(regionId)_\(Date.now.timeIntervalSince1970)",
            content: content,
            trigger: nil // deliver immediately
        )

        try? await UNUserNotificationCenter.current().add(request)
    }
}
