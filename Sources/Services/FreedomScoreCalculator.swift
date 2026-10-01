import Foundation
import SwiftData

/// Service calculating the daily holistic Freedom Score (0–100%) inspired by Opal's Focus Score.
enum FreedomScoreCalculator {

    /// Calculates a comprehensive Freedom Score between 0 and 100 based on user activity and consistency.
    static func calculateScore(
        daysClean: Int,
        hasPledgedToday: Bool,
        cravingLogs: [CravingLog],
        journalEntries: [JournalEntry],
        selfAssessmentResults: [SelfAssessmentResult]
    ) -> (score: Int, grade: String, summary: String) {
        var points: Double = 0.0

        // 1. Sobriety Streak (Up to 40 points)
        if daysClean >= 365 {
            points += 40.0
        } else if daysClean >= 90 {
            points += 35.0
        } else if daysClean >= 30 {
            points += 30.0
        } else if daysClean >= 7 {
            points += 20.0
        } else if daysClean >= 1 {
            points += Double(daysClean) * 2.5
        }

        // 2. Daily Pledge (+25 points)
        if hasPledgedToday {
            points += 25.0
        }

        // 3. Craving Resilience (+20 points)
        let recentLogs = cravingLogs.filter { $0.date >= Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now }
        if recentLogs.isEmpty {
            // No cravings in 7 days = full resilience score
            points += 20.0
        } else {
            let relapses = recentLogs.filter { $0.wasRelapse }.count
            let managed = recentLogs.filter { !$0.wasRelapse }.count
            if relapses == 0 && managed > 0 {
                points += 20.0 // Heroic craving management!
            } else if relapses == 0 {
                points += 15.0
            } else {
                points += 5.0
            }
        }

        // 4. Mindfulness & Journaling (+15 points)
        let recentJournals = journalEntries.filter { $0.date >= Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now }
        if recentJournals.count >= 3 {
            points += 15.0
        } else if !recentJournals.isEmpty {
            points += 10.0
        }

        let finalScore = min(max(Int(points.rounded()), 5), 100)

        let grade: String
        let summary: String

        switch finalScore {
        case 90...100:
            grade = "Diamond Freedom"
            summary = "Outstanding! You lead your life with maximal clarity and empowerment."
        case 75...89:
            grade = "Emerald Clarity"
            summary = "Very strong! Your protection is active and your habits solidify every day."
        case 50...74:
            grade = "Growing Strength"
            summary = "Solid progress. Complete your daily pledge to elevate your score."
        default:
            grade = "Fresh Start"
            summary = "Every day is a new opportunity. Use the SOS tools and stay true to your pledge."
        }

        return (finalScore, grade, summary)
    }
}
