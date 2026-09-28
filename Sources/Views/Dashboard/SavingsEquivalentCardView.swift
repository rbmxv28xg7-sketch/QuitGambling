import SwiftUI

/// Elegant dashboard card translating saved gambling money into tangible purchasing power and lifestyle rewards.
struct SavingsEquivalentCardView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager: SubscriptionManager?
    let moneySaved: Double
    var onTap: () -> Void

    var body: some View {
        let current = SavingsEquivalentService.currentEquivalent(for: moneySaved)
        let nextProgress = SavingsEquivalentService.progressToNext(for: moneySaved)

        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Design.Colors.gold)

                        Text("WHAT YOUR MONEY BUYS")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .tracking(1.2)
                            .foregroundStyle(Design.Colors.gold)
                    }

                    Spacer()

                    HStack(spacing: 5) {
                        if let subscriptionManager, !subscriptionManager.isPro {
                            ProBadge(isCompact: true)
                        }

                        Text("All")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Design.Colors.textSecondary)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Design.Colors.textTertiary)
                    }
                }

                // Main Equivalent Row
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Design.Colors.primary.opacity(0.18))
                            .frame(width: 44, height: 44)

                        Image(systemName: moneySaved >= 5 ? current.icon : "leaf.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Design.Colors.primary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(moneySaved >= 5 ? "≈ \(current.title)" : "First Goal: $5 (Coffee & Snack)")
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(Color.white)
                            .lineLimit(1)

                        Text(moneySaved >= 5 ? current.description : "Every gamble-free day puts real money back into your life.")
                            .font(.caption2)
                            .foregroundStyle(Design.Colors.textSecondary)
                            .lineLimit(2)
                    }

                    Spacer()
                }

                // Progress to Next Tangible Reward (if applicable)
                if let next = nextProgress {
                    VStack(spacing: 6) {
                        // Subtle custom progress track
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.08))
                                    .frame(height: 4)

                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Design.Colors.primary, Design.Colors.gold],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: max(geo.size.width * CGFloat(next.progress), 4), height: 4)
                            }
                        }
                        .frame(height: 4)

                        HStack {
                            Text("Next Goal: \(next.next.shortTitle)")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(Design.Colors.textTertiary)
                                .lineLimit(1)

                            Spacer()

                            Text("\(next.remaining, format: .currency(code: "USD")) left")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Design.Colors.gold)
                                .lineLimit(1)
                        }
                    }
                    .padding(.top, 2)
                }
            }
            .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.md)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        SavingsEquivalentCardView(moneySaved: 145.0, onTap: {})
            .padding()
    }
}
