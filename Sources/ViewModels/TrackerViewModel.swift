import Foundation
import SwiftData
import SwiftUI

@Observable
@MainActor
final class TrackerViewModel {
    var selectedMonth: Date = .now

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
                return Design.Colors.surfaceHover
            case .beforeStart:
                return Design.Colors.background
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

    func dayStatus(for date: Date, logs: [CravingLog], startDate: Date) -> DayStatus {
        let calendar = Calendar.current

        if calendar.isDate(date, inSameDayAs: .now) {
            // fallthrough
        } else if date > .now {
            return .future
        }

        if date < calendar.startOfDay(for: startDate) {
            return .beforeStart
        }

        let logsForDay = logs.filter { calendar.isDate($0.date, inSameDayAs: date) }

        if logsForDay.contains(where: { $0.wasRelapse }) {
            return .relapse
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
        try? context.save()
    }
}
