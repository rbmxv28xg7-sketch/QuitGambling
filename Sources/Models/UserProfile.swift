import Foundation
import SwiftData

@Model
final class UserProfile {
    var sobrietyStartDate: Date = Date.now
    var dailyGamblingSpend: Double = 0
    var preferredLanguage: String = "de"
    var hasCompletedOnboarding: Bool = false
    var pledgedToday: Bool = false
    var lastPledgeDate: Date?

    init(sobrietyStartDate: Date = .now, dailyGamblingSpend: Double = 0, preferredLanguage: String = "de") {
        self.sobrietyStartDate = sobrietyStartDate
        self.dailyGamblingSpend = dailyGamblingSpend
        self.preferredLanguage = preferredLanguage
    }
}
