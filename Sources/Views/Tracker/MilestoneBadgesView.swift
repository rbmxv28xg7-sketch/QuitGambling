import SwiftUI
import SwiftData

/// Minimalist, high-end trophy card displaying 8 recovery milestones in a clean 4x2 grid.
/// Harmonizes 100% with the Liquid Glass system and SobrietyCalendarView.
struct MilestoneBadgesView: View {
    let daysClean: Int
    @Query private var profiles: [UserProfile]
    @State private var selectedMilestone: Design.Milestone?

    private var profile: UserProfile? { profiles.first }
    private var dailySpend: Double { profile?.dailyGamblingSpend ?? 0 }

    private var achievedCount: Int {
        Design.Milestone.allCases.filter { daysClean >= $0.days }.count
    }

    private var nextMilestone: Design.Milestone? {
        Design.Milestone.allCases.first { daysClean < $0.days }
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    var body: some View {
        VStack(spacing: Design.Spacing.md) {
            // Header
            HStack {
                Text("Milestones".loc)
                    .font(.headline)
                    .foregroundStyle(Design.Colors.ivory)
                    .shadow(color: Color.black.opacity(0.35), radius: 1.5, y: 1)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 4)

                Text("%d of %d achieved".loc(achievedCount, Design.Milestone.allCases.count))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Design.Colors.gold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            // 4x2 Minimalist Grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Design.Milestone.allCases) { milestone in
                    let isAchieved = daysClean >= milestone.days
                    let isNext = nextMilestone == milestone
                    let daysLeft = max(0, milestone.days - daysClean)

                    Button {
                        if isAchieved {
                            SensoryFeedbackService.shared.milestoneAchieved()
                        } else {
                            SensoryFeedbackService.shared.selectionClick()
                        }
                        selectedMilestone = milestone
                    } label: {
                        VStack(spacing: 6) {
                            // Badge Icon
                            ZStack {
                                Circle()
                                    .fill(
                                        isAchieved
                                        ? Design.Colors.gold.opacity(0.18)
                                        : (isNext ? Color.white.opacity(0.10) : Color.white.opacity(0.04))
                                    )
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(
                                                isAchieved
                                                ? Design.Colors.gold.opacity(0.65)
                                                : (isNext ? Design.Colors.gold : Color.white.opacity(0.10)),
                                                lineWidth: isNext ? 1.8 : 1.0
                                            )
                                    )

                                Image(systemName: milestone.icon)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(
                                        isAchieved
                                        ? Design.Colors.gold
                                        : (isNext ? Color.white : Color.white.opacity(0.25))
                                    )

                                // Status Badge
                                if isAchieved {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(Design.Colors.signalGreen)
                                        .background(Circle().fill(Color.black).padding(1))
                                        .offset(x: 16, y: -16)
                                } else if !isNext {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 9))
                                        .foregroundStyle(Design.Colors.textTertiary)
                                        .offset(x: 15, y: -15)
                                }
                            }

                            // Label & Status
                            VStack(spacing: 1) {
                                Text(milestone.label.loc)
                                    .font(.caption.weight(isAchieved || isNext ? .bold : .medium))
                                    .foregroundStyle(isAchieved ? Color.white : (isNext ? Design.Colors.gold : Design.Colors.textSecondary))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)

                                if isAchieved {
                                    Text("Unlocked".loc)
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(Design.Colors.signalGreen)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                } else if isNext {
                                    Text(daysLeft == 1 ? "%d day left".loc(daysLeft) : "%d days left".loc(daysLeft))
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(Design.Colors.gold)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                } else {
                                    Text("Locked".loc)
                                        .font(.system(size: 10))
                                        .foregroundStyle(Design.Colors.textTertiary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }

            // Next Goal Progress Bar
            if let next = nextMilestone {
                let previousDays = Design.Milestone.allCases.last(where: { $0.days <= daysClean })?.days ?? 0
                let range = max(1, next.days - previousDays)
                let progress = min(1.0, max(0.0, Double(daysClean - previousDays) / Double(range)))
                let daysLeft = max(1, next.days - daysClean)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Next Goal: %@".loc(next.label.loc))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Spacer(minLength: 4)
                        Text(daysLeft == 1 ? "%d day left".loc(daysLeft) : "%d days left".loc(daysLeft))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Design.Colors.gold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }

                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.10))
                                .frame(height: 5)

                            Capsule()
                                .fill(Design.Colors.gold)
                                .frame(width: max(6, proxy.size.width * progress), height: 5)
                                .shadow(color: Design.Colors.gold.opacity(0.4), radius: 3)
                        }
                    }
                    .frame(height: 5)
                }
                .padding(.top, 4)
            }
        }
        .sereneCardStyle(padding: Design.Spacing.md)
        .padding(.horizontal)
        .sheet(item: $selectedMilestone) { milestone in
            MinimalMilestoneDetailSheet(
                milestone: milestone,
                daysClean: daysClean,
                dailySpend: dailySpend
            )
            .scrollIndicators(.hidden)
            .presentationDetents([.fraction(0.48), .medium])
            .presentationDragIndicator(.visible)
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - Minimalist Milestone Detail Sheet

private struct MinimalMilestoneDetailSheet: View {
    let milestone: Design.Milestone
    let daysClean: Int
    let dailySpend: Double
    @Environment(\.dismiss) private var dismiss

    private var isAchieved: Bool { daysClean >= milestone.days }
    private var daysRemaining: Int { max(0, milestone.days - daysClean) }

    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()

            VStack(spacing: Design.Spacing.lg) {
                // Minimalist Icon
                ZStack {
                    Circle()
                        .fill(isAchieved ? Design.Colors.gold.opacity(0.18) : Color.white.opacity(0.08))
                        .frame(width: 64, height: 64)
                        .overlay(
                            Circle()
                                .strokeBorder(isAchieved ? Design.Colors.gold.opacity(0.7) : Color.white.opacity(0.15), lineWidth: 1.5)
                        )

                    Image(systemName: milestone.icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(isAchieved ? Design.Colors.gold : Color.white.opacity(0.4))
                }
                .padding(.top, Design.Spacing.sm)

                // Title & Status
                VStack(spacing: 4) {
                    Text("%@ Gamble-Free".loc(milestone.label.loc))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    if isAchieved {
                        Text("Milestone Unlocked".loc)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Design.Colors.signalGreen)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    } else {
                        Text(daysRemaining == 1 ? "%d day until unlocked".loc(daysRemaining) : "%d days until unlocked".loc(daysRemaining))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Design.Colors.gold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }

                // Core Scientific Benefit
                Text(milestone.scientificFact)
                    .font(.subheadline)
                    .foregroundStyle(Color.white.opacity(0.88))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, Design.Spacing.md)

                // Money Saved if any
                if dailySpend > 0 {
                    let saved = Double(milestone.days) * dailySpend
                    HStack(spacing: 6) {
                        Image(systemName: "banknote")
                            .foregroundStyle(Design.Colors.signalGreen)
                        Text(isAchieved ? "Money saved:".loc : "Projected savings:".loc)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text(saved, format: .currency(code: AppPreferences.shared.currencyCode))
                            .bold()
                            .foregroundStyle(Design.Colors.signalGreen)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .font(.caption)
                    .foregroundStyle(Design.Colors.textSecondary)
                }

                // Close Button
                Button {
                    dismiss()
                } label: {
                    Text("Close".loc)
                        .font(.headline)
                        .foregroundStyle(Design.Colors.textOnPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Design.Colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.top, 4)
            }
            .padding(Design.Spacing.lg)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        MilestoneBadgesView(daysClean: 13)
    }
}
