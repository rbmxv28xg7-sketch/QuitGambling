import SwiftUI

/// Liquid Glass metric pod displaying savings and its tangible real-world equivalent.
struct SavingsMetricCard: View {
    let moneySaved: Double

    var body: some View {
        let current = SavingsEquivalentService.currentEquivalent(for: moneySaved)

        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            HStack {
                Image(systemName: "banknote")
                    .font(.caption)
                    .foregroundStyle(Design.Colors.textSecondary)

                Spacer()

                Text("SAVED".loc)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(Design.Colors.textSecondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(moneySaved, format: .currency(code: AppPreferences.shared.currencyCode))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .contentTransition(.numericText())
                    .animation(Design.Anim.spring, value: moneySaved)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                if moneySaved >= 5 {
                    HStack(spacing: 4) {
                        Image(systemName: current.icon)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Design.Colors.gold)

                        Text("≈ \(current.shortTitle.loc)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Design.Colors.gold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                } else {
                    Text("Money preserved".loc)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Design.Colors.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
        }
        .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.md)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        SavingsMetricCard(moneySaved: 420.50)
            .frame(width: 170)
            .padding()
    }
}
