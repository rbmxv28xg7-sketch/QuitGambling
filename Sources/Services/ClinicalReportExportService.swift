import SwiftUI
import SwiftData

/// Service responsible for compiling, formatting, and exporting clinical recovery reports
/// suitable for addiction therapists, psychiatrists, general practitioners, and debt counselors.
@MainActor
final class ClinicalReportExportService {
    static let shared = ClinicalReportExportService()

    private init() {}

    // MARK: - Clinical Text Report

    /// Generates a standardized clinical summary report in plain text.
    func generateClinicalReport(
        profile: UserProfile?,
        cravingLogs: [CravingLog],
        preventedLosses: [PreventedLossEntry],
        assessmentResults: [SelfAssessmentResult],
        journalEntries: [JournalEntry]
    ) -> String {
        let prefs = AppPreferences.shared
        let now = Date.now
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        let dateOnlyFormatter = DateFormatter()
        dateOnlyFormatter.dateStyle = .long
        dateOnlyFormatter.timeStyle = .none

        let calendar = Calendar.current
        let startDate = profile?.sobrietyStartDate ?? now
        let totalSeconds = max(0, Int(now.timeIntervalSince(startDate)))
        let daysClean = totalSeconds / 86400
        let hoursClean = (totalSeconds % 86400) / 3600

        // Financial calculations
        let dailySpend = profile?.dailyGamblingSpend ?? 0
        let baselineSavings = (Double(daysClean) * dailySpend) + (Double(totalSeconds % 86400) / 86400.0 * dailySpend)
        let acuteLossesTotal = preventedLosses.reduce(0.0) { $0 + $1.amount }
        let netPreservedCapital = baselineSavings + acuteLossesTotal

        // Relapses
        let relapses = cravingLogs.filter { $0.wasRelapse }.sorted(by: { $0.date > $1.date })
        let urgesResisted = cravingLogs.filter { !$0.wasRelapse }

        // Average Urge Intensity
        let avgIntensity: Double = cravingLogs.isEmpty ? 0 : Double(cravingLogs.reduce(0) { $0 + $1.intensity }) / Double(cravingLogs.count)

        // Trigger distribution
        var triggerCounts: [String: Int] = [:]
        for log in cravingLogs where !log.trigger.isEmpty {
            triggerCounts[log.trigger, default: 0] += 1
        }
        let sortedTriggers = triggerCounts.sorted(by: { $0.value > $1.value })

        // Latest Self Assessment (PGSI)
        let latestAssessment = assessmentResults.sorted(by: { $0.date > $1.date }).first

        var report = ""
        report += "============================================================\n"
        report += "CONFIDENTIAL CLINICAL RECOVERY REPORT\n"
        report += "Quit Gambling — Evidence-Based Patient Consultation Report\n"
        report += "============================================================\n\n"
        report += "Generated on:      \(dateFormatter.string(from: now))\n"
        report += "Application:       Quit Gambling for iOS\n"
        report += "Localization:      \(prefs.languageCode.uppercased()) | Currency: \(prefs.currencyCode) | Region: \(prefs.regionCode)\n\n"

        report += "------------------------------------------------------------\n"
        report += "1. SOBRIETY & ABSTINENCE STATUS\n"
        report += "------------------------------------------------------------\n"
        report += "• Current Gamble-Free Streak: \(daysClean) Days, \(hoursClean) Hours\n"
        report += "• Sobriety Start Date:        \(dateOnlyFormatter.string(from: startDate))\n"
        report += "• Total Recorded Relapses:    \(relapses.count)\n"
        if relapses.isEmpty {
            report += "• Abstinence State:           Continuous Remission (No lapses logged)\n"
        } else if let lastRelapse = relapses.first {
            report += "• Most Recent Relapse:        \(dateFormatter.string(from: lastRelapse.date))\n"
        }
        report += "\n"

        report += "------------------------------------------------------------\n"
        report += "2. FINANCIAL IMPACT & CAPITAL PRESERVED\n"
        report += "------------------------------------------------------------\n"
        if let prof = profile {
            report += "• Pre-Recovery Gambling Pattern: \(prof.spendPattern.title)\n"
            report += "• Historical Spend Baseline:     \(prefs.formatCurrencyPrecise(prof.estimatedBaseAmount)) per \(prof.spendPattern.shortTitle.lowercased())\n"
        }
        report += "• Computed Daily Rate:           \(prefs.formatCurrencyPrecise(dailySpend)) / day\n"
        report += "• Baseline Savings (Time Clean): \(prefs.formatCurrencyPrecise(baselineSavings))\n"
        report += "• Acute Losses Prevented (SOS):  \(prefs.formatCurrencyPrecise(acuteLossesTotal)) (\(preventedLosses.count) logged events)\n"
        report += "• TOTAL PRESERVED CAPITAL:       \(prefs.formatCurrencyPrecise(netPreservedCapital))\n\n"

        report += "------------------------------------------------------------\n"
        report += "3. RELAPSE & LAPSE AUDIT (CHRONOLOGICAL)\n"
        report += "------------------------------------------------------------\n"
        if relapses.isEmpty {
            report += "No relapses recorded by patient in this period.\n\n"
        } else {
            for (idx, relapse) in relapses.enumerated() {
                report += "[\(idx + 1)] Date/Time:      \(dateFormatter.string(from: relapse.date))\n"
                report += "    Urge Intensity: \(relapse.intensity) / 10\n"
                report += "    Primary Trigger: \(relapse.trigger.isEmpty ? "Unspecified" : relapse.trigger)\n"
                if !relapse.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    report += "    Patient Reflection:\n"
                    report += "    \"\(relapse.notes.trimmingCharacters(in: .whitespacesAndNewlines))\"\n"
                }
                report += "\n"
            }
        }

        report += "------------------------------------------------------------\n"
        report += "4. CLINICAL SCREENING (PROBLEM GAMBLING SEVERITY INDEX - PGSI)\n"
        report += "------------------------------------------------------------\n"
        if let pgsi = latestAssessment {
            report += "• Last Screening Date: \(dateOnlyFormatter.string(from: pgsi.date))\n"
            report += "• PGSI Total Score:    \(pgsi.score) / 27\n"
            report += "• Risk Classification: \(pgsi.riskCategory.uppercased())\n"
            report += "• Clinical Guidance:   \(pgsi.recommendation)\n"
        } else {
            report += "No PGSI screening has been performed by the patient yet.\n"
        }
        report += "\n"

        report += "------------------------------------------------------------\n"
        report += "5. URGE DYNAMICS & CRAVING LOGS\n"
        report += "------------------------------------------------------------\n"
        report += "• Total Craving Episodes Logged: \(cravingLogs.count)\n"
        report += "• Urges Successfully Resisted:   \(urgesResisted.count)\n"
        report += "• Average Craving Intensity:     \(String(format: "%.1f", avgIntensity)) / 10\n"
        if !sortedTriggers.isEmpty {
            report += "• Top Identified Triggers:\n"
            for (trigger, count) in sortedTriggers.prefix(5) {
                report += "  - \(trigger): \(count) times\n"
            }
        }
        report += "\n"

        if !preventedLosses.isEmpty {
            report += "------------------------------------------------------------\n"
            report += "6. PREVENTED ACUTE LOSSES (MOMENTUM LOG)\n"
            report += "------------------------------------------------------------\n"
            for item in preventedLosses.prefix(10) {
                report += "• \(dateFormatter.string(from: item.date)): \(prefs.formatCurrencyPrecise(item.amount)) saved"
                if !item.note.isEmpty {
                    report += " (\(item.note))"
                }
                report += "\n"
            }
            report += "\n"
        }

        report += "============================================================\n"
        report += "DISCLAIMER & CLINICAL NOTE:\n"
        report += "This document contains self-reported diagnostic and behavioural\n"
        report += "recovery metrics recorded on-device by the patient. All data is\n"
        report += "stored strictly client-side with zero external cloud transmission.\n"
        report += "============================================================\n"

        return report
    }

    // MARK: - Machine-Readable JSON Export

    /// Serializes all user recovery data into a portable JSON structure.
    func generateJSONExport(
        profile: UserProfile?,
        cravingLogs: [CravingLog],
        preventedLosses: [PreventedLossEntry],
        assessmentResults: [SelfAssessmentResult],
        journalEntries: [JournalEntry],
        savingsGoals: [SavingsGoal]
    ) -> String {
        let isoFormatter = ISO8601DateFormatter()

        let profileDict: [String: Any?] = [
            "sobrietyStartDate": profile != nil ? isoFormatter.string(from: profile!.sobrietyStartDate) : nil,
            "dailyGamblingSpend": profile?.dailyGamblingSpend,
            "spendPattern": profile?.spendPatternRaw,
            "estimatedBaseAmount": profile?.estimatedBaseAmount,
            "pledgedToday": profile?.pledgedToday,
            "lastPledgeDate": profile?.lastPledgeDate != nil ? isoFormatter.string(from: profile!.lastPledgeDate!) : nil,
            "preferredLanguage": AppPreferences.shared.languageCode,
            "preferredCurrency": AppPreferences.shared.currencyCode,
            "unitSystem": AppPreferences.shared.unitSystem.rawValue,
            "regionCode": AppPreferences.shared.regionCode
        ]

        let cravingsList = cravingLogs.map { item -> [String: Any] in
            [
                "date": isoFormatter.string(from: item.date),
                "intensity": item.intensity,
                "trigger": item.trigger,
                "mood": item.mood,
                "notes": item.notes,
                "wasRelapse": item.wasRelapse
            ]
        }

        let lossesList = preventedLosses.map { item -> [String: Any] in
            [
                "id": item.id.uuidString,
                "date": isoFormatter.string(from: item.date),
                "amount": item.amount,
                "note": item.note,
                "contextTag": item.contextTag
            ]
        }

        let assessmentsList = assessmentResults.map { item -> [String: Any] in
            [
                "date": isoFormatter.string(from: item.date),
                "score": item.score,
                "riskCategory": item.riskCategory,
                "answers": item.answers,
                "notes": item.notes
            ]
        }

        let journalsList = journalEntries.map { item -> [String: Any] in
            [
                "date": isoFormatter.string(from: item.date),
                "text": item.text,
                "mood": item.mood,
                "gratitude": item.gratitude,
                "hadCravings": item.hadCravings
            ]
        }

        let goalsList = savingsGoals.map { item -> [String: Any] in
            [
                "name": item.name,
                "targetAmount": item.targetAmount,
                "icon": item.icon
            ]
        }

        let exportPayload: [String: Any] = [
            "exportVersion": "1.0",
            "exportDate": isoFormatter.string(from: Date.now),
            "app": "Quit Gambling",
            "profile": profileDict,
            "cravingLogs": cravingsList,
            "preventedLosses": lossesList,
            "assessmentResults": assessmentsList,
            "journalEntries": journalsList,
            "savingsGoals": goalsList
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: exportPayload, options: [.prettyPrinted, .sortedKeys]),
              let jsonString = String(data: data, encoding: .utf8) else {
            return "{ \"error\": \"Failed to serialize recovery data\" }"
        }

        return jsonString
    }

    // MARK: - Native Share Sheet Presentation

    /// Opens the native iOS share sheet with text or written file URL.
    func shareContent(items: [Any]) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }

        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = rootVC.view
            popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        rootVC.present(activityVC, animated: true)
    }

    /// Saves text to a temporary file and triggers the share sheet.
    func shareFile(content: String, filename: String) {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)

        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            shareContent(items: [fileURL])
        } catch {
            // Fallback to sharing text directly
            shareContent(items: [content])
        }
    }
}
