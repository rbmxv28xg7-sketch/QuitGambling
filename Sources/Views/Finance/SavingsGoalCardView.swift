import SwiftUI

/// Redesigned Apple-grade card showing progress toward a specific savings goal.
/// Strictly single-line title + single-line subtitle, with fluid animated progress bar.
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

    private var isAchieved: Bool {
        progress >= 1.0
    }

    var body: some View {
        VStack(spacing: Design.Spacing.sm) {
            HStack(spacing: 12) {
                // Goal Icon Badge
                ZStack {
                    Circle()
                        .fill(isAchieved ? Design.Colors.primary.opacity(0.18) : Design.Colors.gold.opacity(0.14))
                        .frame(width: 42, height: 42)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(isAchieved ? Design.Colors.primary : Design.Colors.gold)
                }

                // Title (Line 1) + Subtitle (Line 2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(goalName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    HStack(spacing: 4) {
                        Text(savedAmount, format: .currency(code: AppPreferences.shared.currencyCode))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(isAchieved ? Design.Colors.primary : Design.Colors.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Text("of".loc)
                            .font(.caption2)
                            .foregroundStyle(Design.Colors.textTertiary)

                        Text(targetAmount, format: .currency(code: AppPreferences.shared.currencyCode))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Design.Colors.champagne)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .lineLimit(1)
                }

                Spacer(minLength: 4)

                // Percentage or Achieved Pill
                if isAchieved {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                        Text("Reached".loc)
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Design.Colors.primary)
                    .clipShape(Capsule())
                } else {
                    Text("\(percentage)%")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Design.Colors.gold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Design.Colors.gold.opacity(0.14))
                        .clipShape(Capsule())
                }
            }

            // Sleek Custom Progress Capsule
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 6)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: isAchieved
                                    ? [Design.Colors.primary, Design.Colors.primaryLight]
                                    : [Design.Colors.gold, Design.Colors.amberGold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(6, geo.size.width * CGFloat(progress)), height: 6)
                        .animation(Design.Anim.spring, value: progress)
                }
            }
            .frame(height: 6)
            .padding(.top, 2)
        }
        .sereneCardStyle(padding: Design.Spacing.md)
    }
}

#Preview {
    VStack(spacing: 12) {
        SavingsGoalCardView(goalName: "Notgroschen", savedAmount: 1200, targetAmount: 2000, icon: "shield.fill")
        SavingsGoalCardView(goalName: "Urlaub nach New York", savedAmount: 3500, targetAmount: 3500, icon: "airplane")
    }
    .padding()
}
