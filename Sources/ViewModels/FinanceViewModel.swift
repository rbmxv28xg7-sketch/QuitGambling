import SwiftUI
import SwiftData

@Observable
@MainActor
final class FinanceViewModel {
    var baselineSaved: Double = 0
    var acutePreventedSaved: Double = 0
    var totalSaved: Double = 0
    var projectedYearlySavings: Double = 0
    var projectedMonthlySavings: Double = 0

    func calculateSavings(startDate: Date, dailySpend: Double, context: ModelContext? = nil) {
        let daysClean = Calendar.current.dateComponents([.day], from: startDate, to: .now).day ?? 0
        let days = max(Double(daysClean), 0)
        baselineSaved = days * dailySpend
        
        if let context = context {
            let descriptor = FetchDescriptor<PreventedLossEntry>()
            if let entries = try? context.fetch(descriptor) {
                acutePreventedSaved = entries.reduce(0) { $0 + $1.amount }
            } else {
                acutePreventedSaved = 0
            }
        }
        
        totalSaved = baselineSaved + acutePreventedSaved
        projectedYearlySavings = 365.0 * dailySpend
        projectedMonthlySavings = 30.0 * dailySpend
    }

    func addGoal(context: ModelContext, name: String, targetAmount: Double, icon: String) {
        let goal = SavingsGoal(name: name, targetAmount: targetAmount, icon: icon)
        context.insert(goal)
        try? context.save()
    }

    func deleteGoal(context: ModelContext, goal: SavingsGoal) {
        context.delete(goal)
        try? context.save()
    }

    func addPreventedLoss(amount: Double, contextTag: String = "Finances", note: String = "", context: ModelContext) {
        guard amount > 0 else { return }
        let entry = PreventedLossEntry(amount: amount, note: note, contextTag: contextTag)
        context.insert(entry)
        try? context.save()
        acutePreventedSaved += amount
        totalSaved = baselineSaved + acutePreventedSaved
    }

    func deletePreventedLoss(_ entry: PreventedLossEntry, context: ModelContext) {
        context.delete(entry)
        try? context.save()
    }
}
