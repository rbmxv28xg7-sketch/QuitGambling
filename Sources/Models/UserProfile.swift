import Foundation
import SwiftData

/// Represents the historical gambling frequency and spending pattern of the user.
enum SpendPattern: String, Codable, CaseIterable, Identifiable {
    case monthly = "monthly"
    case weekly = "weekly"
    case daily = "daily"
    case manualOnly = "manualOnly"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .monthly: return "Monthly (Binge / Paycheck)".loc
        case .weekly: return "Weekly (Weekends)".loc
        case .daily: return "Daily".loc
        case .manualOnly: return "Manual Only ($0 Base)".loc
        }
    }

    var shortTitle: String {
        switch self {
        case .monthly: return "Month".loc
        case .weekly: return "Week".loc
        case .daily: return "Day".loc
        case .manualOnly: return "Manual".loc
        }
    }

    func dailyEquivalent(amount: Double) -> Double {
        switch self {
        case .monthly:
            return amount / 30.416
        case .weekly:
            return amount / 7.0
        case .daily:
            return amount
        case .manualOnly:
            return 0.0
        }
    }
}

@Model
final class UserProfile {
    var sobrietyStartDate: Date = Date.now
    var dailyGamblingSpend: Double = 0
    var preferredLanguage: String = "en"
    var hasCompletedOnboarding: Bool = false
    var pledgedToday: Bool = false
    var lastPledgeDate: Date?
    var spendPatternRaw: String = "monthly"
    var estimatedBaseAmount: Double = 0

    var spendPattern: SpendPattern {
        get { SpendPattern(rawValue: spendPatternRaw) ?? .monthly }
        set {
            spendPatternRaw = newValue.rawValue
            recalculateDailySpend()
        }
    }

    func recalculateDailySpend() {
        if spendPattern == .manualOnly {
            dailyGamblingSpend = 0
        } else if estimatedBaseAmount > 0 {
            dailyGamblingSpend = spendPattern.dailyEquivalent(amount: estimatedBaseAmount)
        }
    }

    init(
        sobrietyStartDate: Date = .now,
        dailyGamblingSpend: Double = 0,
        preferredLanguage: String = "de",
        spendPatternRaw: String = "monthly",
        estimatedBaseAmount: Double = 0
    ) {
        self.sobrietyStartDate = sobrietyStartDate
        self.dailyGamblingSpend = dailyGamblingSpend
        self.preferredLanguage = preferredLanguage
        self.spendPatternRaw = spendPatternRaw
        self.estimatedBaseAmount = estimatedBaseAmount
    }
}
