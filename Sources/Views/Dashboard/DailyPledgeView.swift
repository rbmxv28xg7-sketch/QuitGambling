import SwiftUI

/// Tactile, Warm Liquid Glass Daily Pledge control.
struct DailyPledgeView: View {
    var hasPledgedToday: Bool
    var onPledge: () -> Void

    @State private var holdProgress: Double = 0.0
    @State private var isHolding: Bool = false
    @State private var showCelebration: Bool = false

    var body: some View {
        Group {
            if hasPledgedToday || showCelebration {
                pledgedLiquidCard
            } else {
                unpledgedHoldPill
            }
        }
    }

    // MARK: - Pledged State (Warm Liquid Glass)

    private var pledgedLiquidCard: some View {
        HStack(spacing: Design.Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(Design.Colors.amberGold)

            VStack(alignment: .leading, spacing: 2) {
                Text("Daily Pledge Kept".loc)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white)
                Text("Committed to staying free today.".loc)
                    .font(.caption2)
                    .foregroundStyle(Design.Colors.textSecondary)
            }

            Spacer()
        }
        .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.md)
    }

    // MARK: - Unpledged Tactile Pill (Warm Liquid Glass Track)

    private var unpledgedHoldPill: some View {
        ZStack {
            // Warm Liquid Glass Track (No Muddy Gray!)
            Capsule()
                .fill(.ultraThinMaterial.opacity(0.35))
                .overlay(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Design.Colors.champagne.opacity(0.12),
                                    Design.Colors.copper.opacity(0.06)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    Capsule()
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: Color.white.opacity(0.20), location: 0.0),
                                    .init(color: Design.Colors.champagne.opacity(0.05), location: 0.35),
                                    .init(color: Color.clear, location: 0.70)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .overlay(
                    Capsule()
                        .strokeBorder(
                            LinearGradient(
                                stops: [
                                    .init(color: Design.Colors.champagne.opacity(0.55), location: 0.0),
                                    .init(color: Color.white.opacity(0.20), location: 0.30),
                                    .init(color: Color.clear, location: 0.65),
                                    .init(color: Design.Colors.copper.opacity(0.35), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.22), radius: 12, x: 0, y: 6)
                .frame(height: 54)

            // Tactile Fill (Radiant Liquid Amber)
            GeometryReader { geo in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Design.Colors.warmFlame,
                                Design.Colors.amberGold
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * holdProgress, height: 54)
                    .animation(.linear(duration: 0.05), value: holdProgress)
            }
            .frame(height: 54)
            .clipShape(Capsule())

            // 1. Base Layer (White text on dark track)
            pledgeButtonContent(textColor: Color.white)

            // 2. High-Contrast Overlay Layer (Masked to holdProgress fill, dark text on bright fill!)
            if holdProgress > 0 {
                GeometryReader { geo in
                    let fillWidth = geo.size.width * holdProgress
                    pledgeButtonContent(textColor: Design.Colors.textOnPrimary)
                        .frame(width: geo.size.width, height: 54)
                        .mask(alignment: .leading) {
                            Rectangle()
                                .frame(width: fillWidth, height: 54)
                        }
                }
                .allowsHitTesting(false)
            }
        }
        .frame(height: 54)
        .contentShape(Capsule())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isHolding && !hasPledgedToday {
                        startHolding()
                    }
                }
                .onEnded { _ in
                    if isHolding {
                        cancelHolding()
                    }
                }
        )
        .sensoryFeedback(.impact(weight: .medium), trigger: isHolding)
        .sensoryFeedback(.success, trigger: showCelebration)
    }

    private func startHolding() {
        isHolding = true
        Task {
            let steps = 25
            let duration = 0.95 / Double(steps)
            for i in 1...steps {
                guard isHolding else { break }
                try? await Task.sleep(for: .seconds(duration))
                guard isHolding else { break }
                holdProgress = Double(i) / Double(steps)
            }

            if isHolding && holdProgress >= 0.98 {
                showCelebration = true
                SensoryFeedbackService.shared.pledgeConfirmed()
                onPledge()
                isHolding = false
                holdProgress = 0
            }
        }
    }

    private func cancelHolding() {
        isHolding = false
        withAnimation(.easeOut(duration: 0.2)) {
            holdProgress = 0
        }
    }

    @ViewBuilder
    private func pledgeButtonContent(textColor: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: isHolding ? "shield.fill" : "shield.checkered")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Design.Colors.amberGold)

            Text(isHolding ? "Confirming pledge...".loc : "Pledge to stay gamble-free today".loc)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
                .shadow(color: Color.black.opacity(textColor == .white ? 0.5 : 0), radius: 2, y: 1)

            Spacer(minLength: 4)

            if !isHolding {
                Text("Hold".loc)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Design.Colors.champagne)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial.opacity(0.40))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(Design.Colors.champagne.opacity(0.30), lineWidth: 0.8)
                    )
            }
        }
        .padding(.horizontal, Design.Spacing.md)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 16) {
            DailyPledgeView(hasPledgedToday: false, onPledge: {})
            DailyPledgeView(hasPledgedToday: true, onPledge: {})
        }
        .padding()
    }
}
