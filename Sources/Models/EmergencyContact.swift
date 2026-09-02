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
        customMessage: String = "Hey, ich verspüre gerade starken Spieldruck und bräuchte kurz Unterstützung oder Ablenkung. Hast du kurz Zeit für mich?"
    ) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.relationship = relationship
        self.customMessage = customMessage
        self.createdAt = .now
    }
}
