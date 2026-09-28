import Foundation
import SwiftData
import SwiftUI

@Observable
@MainActor
final class TrackerViewModel {
    var selectedMonth: Date = .now

    @MainActor
    enum DayStatus {
        case clean
        case craving
        case relapse
        case future
        case beforeStart

        var color: Color {
            switch self {
            case .clean:
                return Design.Colors.calendarClean
            case .craving:
                return Design.Colors.calendarCraving
            case .relapse:
                return Design.Colors.calendarRelapse
            case .future:
                return Color.white.opacity(0.04)
            case .beforeStart:
                return Color.white.opacity(0.04)
            }
        }
    }

    func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }

    func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }

    func dayStatus(for date: Date, logs: [CravingLog], journalEntries: [JournalEntry] = [], startDate: Date) -> DayStatus {
        let calendar = Calendar.current

        if calendar.isDate(date, inSameDayAs: .now) {
            // fallthrough
        } else if date > .now {
            return .future
        }

        let logsForDay = logs.filter { calendar.isDate($0.date, inSameDayAs: date) }
        let hasRelapseJournal = journalEntries.contains(where: { calendar.isDate($0.date, inSameDayAs: date) && $0.wasRelapse })

        if logsForDay.contains(where: { $0.wasRelapse }) || hasRelapseJournal {
            return .relapse
        } else if date < calendar.startOfDay(for: startDate) {
            return .beforeStart
        } else if !logsForDay.isEmpty {
            return .craving
        } else {
            return .clean
        }
    }

    func logCraving(context: ModelContext, intensity: Int, trigger: String, mood: Int, notes: String, wasRelapse: Bool) {
        let log = CravingLog(
            date: .now,
            intensity: intensity,
            trigger: trigger,
            mood: mood,
            notes: notes,
            wasRelapse: wasRelapse
        )
        context.insert(log)

        if wasRelapse {
            let descriptor = FetchDescriptor<UserProfile>()
            if let profile = try? context.fetch(descriptor).first {
                profile.sobrietyStartDate = .now
                profile.pledgedToday = false
                profile.lastPledgeDate = nil
            }
        }

        try? context.save()
    }
}
