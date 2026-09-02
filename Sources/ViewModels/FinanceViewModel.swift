import SwiftUI
import SwiftData

@Observable
@MainActor
final class FinanceViewModel {
    var totalSaved: Double = 0
    var projectedYearlySavings: Double = 0
    var projectedMonthlySavings: Double = 0

    func calculateSavings(startDate: Date, dailySpend: Double) {
        let daysClean = Calendar.current.dateComponents([.day], from: startDate, to: .now).day ?? 0
        let days = max(Double(daysClean), 0)
        totalSaved = days * dailySpend
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
}
