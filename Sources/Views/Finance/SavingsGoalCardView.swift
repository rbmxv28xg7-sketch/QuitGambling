import SwiftUI

/// Card showing progress toward a specific savings goal.
struct SavingsGoalCardView: View {
    let goalName: String
    let savedAmount: Double
    let targetAmount: Double
    let icon: String

    private var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(savedAmount / targetAmount, 1.0)
    }

    private var percentage: Int {
        Int(progress * 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Design.Colors.gold)

                Text(goalName)
                    .font(.headline)

                Spacer()

                Text("\(percentage)%")
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(progress >= 1.0 ? Design.Colors.primary : .secondary)
            }

            ProgressView(value: progress)
                .tint(Design.Colors.gold)

            HStack {
                Text(savedAmount, format: .currency(code: "EUR"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("von")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Text(targetAmount, format: .currency(code: "EUR"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .bold()
            }
        }
        .padding(Design.Spacing.md)
        .background(Design.Colors.surface)
        .clipShape(.rect(cornerRadius: Design.Radius.md))
    }
}

#Preview {
    VStack {
        SavingsGoalCardView(goalName: "Urlaub", savedAmount: 1200, targetAmount: 2000, icon: "airplane")
        SavingsGoalCardView(goalName: "Schulden", savedAmount: 3500, targetAmount: 5000, icon: "creditcard.fill")
    }
    .padding()
}
