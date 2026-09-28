import SwiftUI
import SwiftData

/// Detailed interactive sheet showing tangible real-world equivalents of saved gambling money,
/// featuring the Model 3 Hybrid breakdown (passive baseline + acute prevented deposits).
struct SavingsEquivalentsSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionManager.self) private var subscriptionManager

    let moneySaved: Double

    @Query private var profiles: [UserProfile]
    @Query(sort: \PreventedLossEntry.date, order: .reverse) private var preventedEntries: [PreventedLossEntry]

    @State private var showingAddPreventedLoss = false
    @State private var showingPaywall = false
    @State private var entryToDelete: PreventedLossEntry?

    private var acutePreventedTotal: Double {
        preventedEntries.reduce(0) { $0 + $1.amount }
    }

    private var baselineSaved: Double {
        max(moneySaved - acutePreventedTotal, 0)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FlutedGlassBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Design.Spacing.lg) {
                        // Hero Header
                        heroHeader

                        // Model 3 Hybrid Composition Card
                        hybridCompositionCard

                        // Multiplier Quick Breakdown (if applicable)
                        let multipliers = SavingsEquivalentService.quickMultipliers(for: moneySaved)
                        if !multipliers.isEmpty {
                            multipliersCard(multipliers)
                        }

                        // All Tangible Milestones
                        milestonesSection
                    }
                    .padding(Design.Spacing.md)
                    .padding(.bottom, Design.Spacing.xl)
                }
            }
            .navigationTitle("Tangible Equivalents".loc)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close".loc) {
                        dismiss()
                    }
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(Design.Colors.primary)
                }
            }
            .sheet(isPresented: $showingAddPreventedLoss) {
                AddPreventedLossSheet(defaultContextTag: "Manual")
                    .scrollIndicators(.hidden)
            }
            .fullScreenCover(isPresented: $showingPaywall) {
                PaywallView()
            }
            .scrollIndicators(.hidden)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Design.Colors.gold.opacity(0.18))
                    .frame(width: 64, height: 64)

                Image(systemName: "banknote.fill")
                    .font(.title2)
                    .foregroundStyle(Design.Colors.gold)
            }
            .padding(.top, 4)

            Text(moneySaved, format: .currency(code: AppPreferences.shared.currencyCode))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
                .contentTransition(.numericText())
                .animation(Design.Anim.spring, value: moneySaved)

            Text("Money kept in real life — not lost to online casinos.".loc)
                .font(.caption)
                .foregroundStyle(Design.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Design.Spacing.md)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Design.Spacing.md)
        .sereneCardStyle(padding: Design.Spacing.md)
    }

    // MARK: - Model 3 Hybrid Composition Card

    private var hybridCompositionCard: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Design.Colors.gold)

                Text("SAVINGS BREAKDOWN".loc)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(Design.Colors.gold)

                Spacer()
            }

            VStack(spacing: 10) {
                // Row 1: Passive Baseline
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Design.Colors.primary.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.caption)
                            .foregroundStyle(Design.Colors.primary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Steady Baseline Savings".loc)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.white)

                        if let profile = profiles.first, profile.dailyGamblingSpend > 0 {
                            let formattedSpend = profile.dailyGamblingSpend.formatted(.currency(code: AppPreferences.shared.currencyCode))
                            Text("Based on your profile (~ %@/day)".loc(formattedSpend))
                                .font(.caption2)
                                .foregroundStyle(Design.Colors.textSecondary)
                        } else {
                            Text("Automatic calculation of your gamble-free days".loc)
                                .font(.caption2)
                                .foregroundStyle(Design.Colors.textSecondary)
                        }
                    }

                    Spacer()

                    Text(baselineSaved, format: .currency(code: AppPreferences.shared.currencyCode))
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(Color.white)
                        .contentTransition(.numericText())
                        .animation(Design.Anim.spring, value: baselineSaved)
                }

                Divider().background(Color.white.opacity(0.08))

                // Row 2: Acute Prevented Losses
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Design.Colors.gold.opacity(0.18))
                            .frame(width: 36, height: 36)
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.caption)
                            .foregroundStyle(Design.Colors.gold)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Averted Gambling Deposits".loc)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.white)

                        Text(preventedEntries.count == 1 ? "%d urge moment successfully defended".loc(preventedEntries.count) : "%d urge moments successfully defended".loc(preventedEntries.count))
                            .font(.caption2)
                            .foregroundStyle(Design.Colors.gold)
                            .contentTransition(.numericText())
                            .animation(Design.Anim.spring, value: preventedEntries.count)
                    }

                    Spacer()

                    Text(acutePreventedTotal, format: .currency(code: AppPreferences.shared.currencyCode))
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(Design.Colors.gold)
                        .contentTransition(.numericText())
                        .animation(Design.Anim.spring, value: acutePreventedTotal)
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous))

            // Action Button: Log Avoided Bet
            Button {
                showingAddPreventedLoss = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.subheadline)
                    Text("Log Prevented Bet".loc)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .foregroundStyle(Design.Colors.textOnPrimary)
                .background(
                    RoundedRectangle(cornerRadius: Design.Radius.sm, style: .continuous)
                        .fill(Design.Colors.primary)
                )
            }
            .buttonStyle(.plain)

            // History of Acute Wins (if any)
            if !preventedEntries.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("DEFENDED URGE MOMENTS".loc)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(1.0)
                        .foregroundStyle(Design.Colors.textTertiary)
                        .padding(.top, 4)

                    VStack(spacing: 6) {
                        ForEach(preventedEntries.prefix(5)) { entry in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 6) {
                                        Text(entry.contextTag.loc)
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundStyle(Design.Colors.gold)

                                        Text(entry.date.formatted(.dateTime.day().month().hour().minute()))
                                            .font(.caption2)
                                            .foregroundStyle(Design.Colors.textTertiary)
                                    }

                                    if !entry.note.isEmpty {
                                        Text(entry.note)
                                            .font(.caption2)
                                            .foregroundStyle(Design.Colors.textSecondary)
                                            .lineLimit(1)
                                    }
                                }

                                Spacer()

                                Text(entry.amount, format: .currency(code: AppPreferences.shared.currencyCode))
                                    .font(.caption)
                                    .bold()
                                    .foregroundStyle(Design.Colors.gold)

                                Button {
                                    modelContext.delete(entry)
                                    try? modelContext.save()
                                } label: {
                                    Image(systemName: "xmark.circle")
                                        .font(.caption2)
                                        .foregroundStyle(Design.Colors.textTertiary)
                                        .padding(.leading, 6)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.02))
                            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.sm, style: .continuous))
                        }
                    }
                }
            }
        }
        .sereneCardStyle(padding: Design.Spacing.md)
    }

    // MARK: - Multipliers Card

    private func multipliersCard(_ items: [(icon: String, text: String)]) -> some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            Label("This equals for example:".loc, systemImage: "sparkles")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(Design.Colors.gold)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Design.Colors.primary.opacity(0.15))
                                .frame(width: 28, height: 28)
                            Image(systemName: item.icon)
                                .font(.caption2)
                                .foregroundStyle(Design.Colors.primary)
                        }

                        Text(item.text)
                            .font(.subheadline)
                            .foregroundStyle(Design.Colors.ivory)

                        Spacer()
                    }
                }
            }
        }
        .sereneCardStyle(padding: Design.Spacing.md)
    }

    // MARK: - Milestones Section

    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            HStack {
                Text("WHAT YOUR MONEY BUYS".loc)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .tracking(1.2)
                    .foregroundStyle(Design.Colors.gold)
                    .padding(.leading, 4)
                Spacer()
                if !subscriptionManager.isPro {
                    ProBadge(isCompact: true)
                }
            }

            VStack(spacing: 10) {
                ForEach(Array(SavingsEquivalentService.equivalents.enumerated()), id: \.element.id) { index, item in
                    let isLocked = !subscriptionManager.isPro && index >= 2
                    milestoneRow(item, isLocked: isLocked)
                }

                if !subscriptionManager.isPro {
                    Button {
                        showingPaywall = true
                    } label: {
                        HStack(spacing: 8) {
                            ProBadge()
                            Text("Unlock all 15+ Purchasing Power Milestones".loc)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(Design.Colors.gold)
                        }
                        .padding(12)
                        .background(Design.Colors.gold.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: Design.Radius.md)
                                .strokeBorder(Design.Colors.gold.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
            }
        }
    }

    private func milestoneRow(_ item: SavingsEquivalent, isLocked: Bool) -> some View {
        let isAchieved = moneySaved >= item.threshold
        let remaining = max(item.threshold - moneySaved, 0)

        return Button {
            if isLocked {
                showingPaywall = true
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isAchieved && !isLocked ? Design.Colors.primary.opacity(0.2) : Color.white.opacity(0.05))
                        .frame(width: 44, height: 44)

                    Image(systemName: item.icon)
                        .font(.body)
                        .foregroundStyle(isAchieved && !isLocked ? Design.Colors.primary : Design.Colors.textTertiary)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(item.title.loc)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(isAchieved && !isLocked ? Color.white : (isLocked ? Design.Colors.textSecondary.opacity(0.7) : Design.Colors.textSecondary))

                        Spacer()

                        Text(item.threshold, format: .currency(code: AppPreferences.shared.currencyCode))
                            .font(.caption)
                            .bold()
                            .foregroundStyle(isAchieved && !isLocked ? Design.Colors.gold : Design.Colors.textTertiary)
                    }

                    Text(item.description.loc)
                        .font(.caption2)
                        .foregroundStyle(isLocked ? Design.Colors.textSecondary.opacity(0.6) : Design.Colors.textSecondary)
                        .lineLimit(2)

                    if !isAchieved && remaining > 0 && !isLocked {
                        HStack(spacing: 4) {
                            let formattedRemaining = remaining.formatted(.currency(code: AppPreferences.shared.currencyCode))
                            Text("%@ left".loc(formattedRemaining))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Design.Colors.gold)
                            Spacer()
                        }
                        .padding(.top, 2)
                    }
                }

                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Design.Colors.gold)
                } else if isAchieved {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Design.Colors.primary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                    .fill(isAchieved && !isLocked ? Design.Colors.primary.opacity(0.10) : Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                            .stroke(isAchieved && !isLocked ? Design.Colors.primary.opacity(0.35) : (isLocked ? Design.Colors.gold.opacity(0.2) : Color.white.opacity(0.08)), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SavingsEquivalentsSheet(moneySaved: 450.0)
}
