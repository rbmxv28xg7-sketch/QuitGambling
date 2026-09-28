import Foundation
import SwiftData

/// Model representing a personal trusted emergency contact (e.g., partner, friend, therapist).
@Model
final class EmergencyContact: Identifiable {
    var name: String = ""
    var phoneNumber: String = ""
    var relationship: String = ""
    var customMessage: String = ""
    var createdAt: Date = Date.now

    init(
        name: String = "",
        phoneNumber: String = "",
        relationship: String = "",
        customMessage: String = "Hey, I'm experiencing a strong urge right now and could really use some support or a brief distraction. Do you have a quick moment to talk?"
    ) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.relationship = relationship
        self.customMessage = customMessage
        self.createdAt = .now
    }
}
