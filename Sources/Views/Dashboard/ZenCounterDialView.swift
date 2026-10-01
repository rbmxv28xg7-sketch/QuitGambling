import SwiftUI

/// Monolithic Streak Centerpiece with Warm Liquid Glass Accents.
struct ZenCounterDialView: View {
    var viewModel: DashboardViewModel
    let score: Int
    let grade: String

    var body: some View {
        VStack(spacing: Design.Spacing.md) {
            // Massive Solid Number (Floating cleanly above warm video)
            Text("\(viewModel.daysClean)")
                .font(.system(size: 96, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
                .contentTransition(.numericText())
                .shadow(color: Color.black.opacity(0.35), radius: 16, y: 8)

            // Crisp Label
            Text("DAYS GAMBLE-FREE".loc)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .tracking(3.0)
                .foregroundStyle(Design.Colors.textSecondary)

            // Precision Time Ticker (Warm Liquid Glass Capsule)
            HStack(spacing: 8) {
                Text(String(format: "%02d %@ : %02d %@ : %02d %@", viewModel.hoursClean, "hrs".loc, viewModel.minutesClean, "min".loc, viewModel.secondsClean, "sec".loc))
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.white.opacity(0.95))
            }
            .padding(.horizontal, Design.Spacing.md)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial.opacity(0.35))
            .overlay(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Design.Colors.champagne.opacity(0.10),
                                Design.Colors.copper.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            stops: [
                                .init(color: Design.Colors.champagne.opacity(0.50), location: 0.0),
                                .init(color: Color.white.opacity(0.20), location: 0.30),
                                .init(color: Color.clear, location: 0.65),
                                .init(color: Design.Colors.copper.opacity(0.30), location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.20), radius: 10, y: 4)
            .padding(.top, Design.Spacing.xs)

            // Freedom Score Badge (Warm Amber Pill)
            HStack(spacing: 6) {
                Circle()
                    .fill(Design.Colors.amberGold)
                    .frame(width: 6, height: 6)
                    .shadow(color: Design.Colors.amberGold.opacity(0.8), radius: 4)

                Text("\(score)% " + "Protection Status".loc)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Design.Colors.champagne)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Design.Spacing.lg)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ZenCounterDialView(viewModel: DashboardViewModel(), score: 88, grade: "Klarheit")
    }
}
