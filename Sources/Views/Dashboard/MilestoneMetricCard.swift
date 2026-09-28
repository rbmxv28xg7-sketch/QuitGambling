import SwiftUI

/// Liquid Glass metric pod displaying next milestone.
struct MilestoneMetricCard: View {
    var viewModel: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            HStack {
                if let next = viewModel.nextMilestone {
                    Image(systemName: next.icon)
                        .font(.caption)
                        .foregroundStyle(Design.Colors.textSecondary)
                } else {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundStyle(Design.Colors.signalGreen)
                }

                Spacer()

                Text("GOAL".loc)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(Design.Colors.textSecondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                if let next = viewModel.nextMilestone {
                    Text(viewModel.daysToNextMilestone == 1 ? "In %d day".loc(viewModel.daysToNextMilestone) : "In %d days".loc(viewModel.daysToNextMilestone))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    HStack(spacing: 4) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Design.Colors.gold)

                        Text(next.label.loc)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Design.Colors.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                } else {
                    Text("Achieved".loc)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Design.Colors.signalGreen)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text("All Milestones".loc)
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
        MilestoneMetricCard(viewModel: DashboardViewModel())
            .frame(width: 170)
            .padding()
    }
}
