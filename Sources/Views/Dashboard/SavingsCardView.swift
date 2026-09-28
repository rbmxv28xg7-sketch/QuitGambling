import SwiftUI

/// Dashboard card displaying total money saved with numeric animation and ambient shimmer.
struct SavingsCardView: View {
    var moneySaved: Double

    var body: some View {
        HStack(spacing: Design.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Design.Colors.gold.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: "banknote.fill")
                    .font(.title3)
                    .foregroundStyle(Design.Colors.gold)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(moneySaved, format: .currency(code: "USD"))
                    .font(.title2)
                    .bold()
                    .contentTransition(.numericText())
                    .foregroundStyle(Design.Colors.primary)
                    .animation(Design.Anim.spring, value: moneySaved)

                Text("Money you didn't gamble away")
                    .font(.caption)
                    .foregroundStyle(Design.Colors.textSecondary)
            }

            Spacer()

            Image(systemName: "sparkles")
                .font(.caption)
                .foregroundStyle(Design.Colors.gold.opacity(0.85))
        }
        .sereneCardStyle(padding: Design.Spacing.md)
        .ambientShimmer(isActive: moneySaved > 0, duration: 2.8, delay: 6.0)
    }
}

#Preview {
    SavingsCardView(moneySaved: 125.50)
        .padding()
}
