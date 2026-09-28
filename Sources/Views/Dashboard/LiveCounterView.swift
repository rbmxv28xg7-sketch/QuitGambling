import SwiftUI

/// Hero card on the dashboard displaying the living growth plant and live sobriety timer.
struct LiveCounterView: View {
    var viewModel: DashboardViewModel

    var body: some View {
        VStack(spacing: Design.Spacing.md) {
            // Living Progress Plant
            GrowingPlantView(daysClean: viewModel.daysClean, size: 75)
                .padding(.top, Design.Spacing.xs)

            // Days Count
            VStack(spacing: 0) {
                Text("\(viewModel.daysClean)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(Design.Colors.primary)
                    .contentTransition(.numericText())
                    .animation(Design.Anim.spring, value: viewModel.daysClean)

                Text("Days Gamble-Free")
                    .font(.headline)
                    .foregroundStyle(Design.Colors.secondary)
            }

            // Live HH:MM:SS clock
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.caption2)
                    .foregroundStyle(Design.Colors.primary.opacity(0.8))

                Text(String(format: "%02d hrs : %02d min : %02d sec", viewModel.hoursClean, viewModel.minutesClean, viewModel.secondsClean))
                    .font(.system(.subheadline, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundStyle(Design.Colors.secondary)
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, Design.Spacing.md)
            .padding(.vertical, Design.Spacing.xs)
            .background(Design.Colors.surface.opacity(0.7))
            .clipShape(.capsule)
        }
        .frame(maxWidth: .infinity)
        .padding(Design.Spacing.lg)
        .background(
            LinearGradient(
                colors: [
                    Design.Colors.primary.opacity(0.12),
                    Design.Colors.primaryLight.opacity(0.06),
                    Design.Colors.surface
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(.rect(cornerRadius: Design.Radius.xl))
        .shadow(color: .black.opacity(0.03), radius: 8, y: 3)
    }
}

#Preview {
    LiveCounterView(viewModel: DashboardViewModel())
        .padding()
}
