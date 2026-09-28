import Foundation
import SwiftData

/// SwiftData model representing a physical trigger zone (e.g. gambling hall or casino perimeter).
@Model
final class TriggerZone {
    var id: UUID = UUID()
    var name: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var radiusMeters: Double = 150.0
    var dwellTimeMinutes: Int = 3
    var isSilentShieldOnly: Bool = true
    var isActive: Bool = true
    var createdAt: Date = Date.now

    init(
        name: String,
        latitude: Double,
        longitude: Double,
        radiusMeters: Double = 150.0,
        dwellTimeMinutes: Int = 3,
        isSilentShieldOnly: Bool = true,
        isActive: Bool = true
    ) {
        self.id = UUID()
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.radiusMeters = radiusMeters
        self.dwellTimeMinutes = dwellTimeMinutes
        self.isSilentShieldOnly = isSilentShieldOnly
        self.isActive = isActive
        self.createdAt = .now
    }
}
