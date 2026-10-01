import SwiftUI

/// Preview card on the dashboard showing the next milestone with an animated progress ring.
struct MilestonePreviewView: View {
    var viewModel: DashboardViewModel

    var body: some View {
        HStack(spacing: Design.Spacing.md) {
            ZStack {
                // Background Track
                Circle()
                    .stroke(Design.Colors.gold.opacity(0.2), lineWidth: 4)

                // Animated Progress Ring
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(viewModel.milestoneProgress, 1.0)))
                    .stroke(
                        LinearGradient(
                            colors: [Design.Colors.gold, Design.Colors.gold.opacity(0.75)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(Design.Anim.spring, value: viewModel.milestoneProgress)

                if let next = viewModel.nextMilestone {
                    Image(systemName: next.icon)
                        .font(.headline)
                        .foregroundStyle(Design.Colors.gold)
                }
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                if let next = viewModel.nextMilestone {
                    Text("\(viewModel.daysToNextMilestone) \(viewModel.daysToNextMilestone == 1 ? "day" : "days") until \(next.label)")
                        .font(.headline)
                        .foregroundStyle(Design.Colors.primary)
                    Text("Next Milestone • \(Int(viewModel.milestoneProgress * 100))% achieved")
                        .font(.caption)
                        .foregroundStyle(Design.Colors.textSecondary)
                } else {
                    Text("All Milestones Achieved!")
                        .font(.headline)
                        .foregroundStyle(Design.Colors.gold)
                    Text("You are living an empowered, gamble-free life.")
                        .font(.caption)
                        .foregroundStyle(Design.Colors.textSecondary)
                }
            }

            Spacer()
        }
        .sereneCardStyle(padding: Design.Spacing.md)
        .ambientShimmer(isActive: viewModel.milestoneProgress >= 0.75)
    }
}

#Preview {
    MilestonePreviewView(viewModel: DashboardViewModel())
        .padding()
}
