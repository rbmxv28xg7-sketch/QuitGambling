import SwiftUI
import SwiftData

@Observable
@MainActor
final class DashboardViewModel {
    var daysClean: Int = 0
    var hoursClean: Int = 0
    var minutesClean: Int = 0
    var secondsClean: Int = 0
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
        guard let profile = try? context.fetch(descriptor).first else { return }
        sobrietyStartDate = profile.sobrietyStartDate
        dailySpend = profile.dailyGamblingSpend
        hasPledgedToday = profile.pledgedToday && Calendar.current.isDateInToday(profile.lastPledgeDate ?? .distantPast)
        updateTimer()
    }
    
    func updateTimer() {
        let interval = Date.now.timeIntervalSince(sobrietyStartDate)
        guard interval > 0 else {
            daysClean = 0; hoursClean = 0; minutesClean = 0; secondsClean = 0; moneySaved = 0
            return
        }
        let totalSeconds = Int(interval)
        daysClean = totalSeconds / 86400
        hoursClean = (totalSeconds % 86400) / 3600
        minutesClean = (totalSeconds % 3600) / 60
        secondsClean = totalSeconds % 60
        moneySaved = Double(daysClean) * dailySpend + (Double(totalSeconds % 86400) / 86400.0) * dailySpend
    }
    
    func confirmPledge(context: ModelContext) {
        let descriptor = FetchDescriptor<UserProfile>()
        guard let profile = try? context.fetch(descriptor).first else { return }
        profile.pledgedToday = true
        profile.lastPledgeDate = .now
        try? context.save()
        hasPledgedToday = true
    }
}
