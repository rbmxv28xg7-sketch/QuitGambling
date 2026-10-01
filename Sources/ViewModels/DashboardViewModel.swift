import SwiftUI
import SwiftData

@Observable
@MainActor
final class DashboardViewModel {
    var daysClean: Int = 0
    var hoursClean: Int = 0
    var minutesClean: Int = 0
    var secondsClean: Int = 0
    var baselineSaved: Double = 0
    var acutePreventedSaved: Double = 0
    var preventedLossEntriesCount: Int = 0
    var moneySaved: Double = 0
    var dailySpend: Double = 0
    var hasPledgedToday: Bool = false
    var sobrietyStartDate: Date = .now
    
    var nextMilestone: Design.Milestone? {
        Design.Milestone.allCases.first { $0.days > daysClean }
    }
    
    var daysToNextMilestone: Int {
        guard let next = nextMilestone else { return 0 }
        return max(0, next.days - daysClean)
    }
    
    var milestoneProgress: Double {
        guard let next = nextMilestone else { return 1.0 }
        let previousDays = Design.Milestone.allCases.last(where: { $0.days <= daysClean })?.days ?? 0
        let range = Double(next.days - previousDays)
        guard range > 0 else { return 0 }
        return Double(daysClean - previousDays) / range
    }
    
    func loadProfile(context: ModelContext) {
        let descriptor = FetchDescriptor<UserProfile>()
        if let profile = try? context.fetch(descriptor).first {
            sobrietyStartDate = profile.sobrietyStartDate
            dailySpend = profile.dailyGamblingSpend
            hasPledgedToday = profile.pledgedToday && Calendar.current.isDateInToday(profile.lastPledgeDate ?? .distantPast)
        }

        let preventedDescriptor = FetchDescriptor<PreventedLossEntry>()
        if let entries = try? context.fetch(preventedDescriptor) {
            acutePreventedSaved = entries.reduce(0) { $0 + $1.amount }
            preventedLossEntriesCount = entries.count
        } else {
            acutePreventedSaved = 0
            preventedLossEntriesCount = 0
        }

        updateTimer()
    }
    
    func updateTimer() {
        let interval = Date.now.timeIntervalSince(sobrietyStartDate)
        guard interval > 0 else {
            daysClean = 0; hoursClean = 0; minutesClean = 0; secondsClean = 0
            baselineSaved = 0
            moneySaved = acutePreventedSaved
            return
        }
        let totalSeconds = Int(interval)
        daysClean = totalSeconds / 86400
        hoursClean = (totalSeconds % 86400) / 3600
        minutesClean = (totalSeconds % 3600) / 60
        secondsClean = totalSeconds % 60
        baselineSaved = Double(daysClean) * dailySpend + (Double(totalSeconds % 86400) / 86400.0) * dailySpend
        moneySaved = baselineSaved + acutePreventedSaved
    }
    
    func confirmPledge(context: ModelContext) {
        let descriptor = FetchDescriptor<UserProfile>()
        guard let profile = try? context.fetch(descriptor).first else { return }
        profile.pledgedToday = true
        profile.lastPledgeDate = .now
        try? context.save()
        hasPledgedToday = true
    }

    func addPreventedLoss(amount: Double, contextTag: String = "Manuell", note: String = "", context: ModelContext) {
        guard amount > 0 else { return }
        let entry = PreventedLossEntry(amount: amount, note: note, contextTag: contextTag)
        context.insert(entry)
        try? context.save()
        loadProfile(context: context)
    }

    func deletePreventedLoss(_ entry: PreventedLossEntry, context: ModelContext) {
        context.delete(entry)
        try? context.save()
        loadProfile(context: context)
    }
}
