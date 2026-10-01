import SwiftUI
import SwiftData

struct FinanceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Query private var profiles: [UserProfile]
    @Query private var goals: [SavingsGoal]
    @Query private var preventedEntries: [PreventedLossEntry]
    @State private var viewModel = FinanceViewModel()
    @State private var showingAddGoal = false
    @State private var showingEquivalentsSheet = false
    @State private var showingPaywall = false
    @State private var newGoalName = ""
    @State private var newGoalAmount: Double = 0
    @State private var newGoalIcon = "star.fill"

    private struct GoalIconItem: Identifiable {
        let icon: String
        let label: String
        var id: String { icon }
    }

    private let predefinedIcons: [GoalIconItem] = [
        .init(icon: "airplane", label: "Travel"),
        .init(icon: "car.fill", label: "Car"),
        .init(icon: "house.fill", label: "Home"),
        .init(icon: "laptopcomputer", label: "Tech"),
        .init(icon: "creditcard.fill", label: "Debt-Free"),
        .init(icon: "heart.fill", label: "Health"),
        .init(icon: "shield.fill", label: "Emergency"),
        .init(icon: "gift.fill", label: "Gift"),
        .init(icon: "graduationcap.fill", label: "Education"),
        .init(icon: "sparkles", label: "Dream"),
        .init(icon: "tshirt.fill", label: "Wardrobe"),
        .init(icon: "fork.knife", label: "Dining")
    ]

    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: Design.Spacing.lg) {
                    SavingsProgressView(
                        totalSaved: viewModel.totalSaved,
                        startDate: profiles.first?.sobrietyStartDate ?? .now
                    )

                    // Tangible Real-World Equivalents Card
                    SavingsEquivalentCardView(moneySaved: viewModel.totalSaved) {
                        showingEquivalentsSheet = true
                    }

                    // Projected savings
                    HStack(spacing: Design.Spacing.md) {
                        projectionCard(title: "In 1 Month".loc, amount: viewModel.projectedMonthlySavings)
                        projectionCard(title: "In 1 Year".loc, amount: viewModel.projectedYearlySavings)
                    }

                    // Savings goals
                    VStack(alignment: .leading, spacing: Design.Spacing.md) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text("Savings Goals".loc)
                                        .font(.headline)
                                        .foregroundStyle(Design.Colors.secondary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                    if !subscriptionManager.isPro {
                                        ProBadge(isCompact: true)
                                    }
                                }
                                Text("Press and hold to edit or delete".loc)
                                    .font(.caption2)
                                    .foregroundStyle(Design.Colors.textTertiary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }

                            Spacer(minLength: 4)

                            Button {
                                if !subscriptionManager.isPro && goals.count >= 1 {
                                    showingPaywall = true
                                } else {
                                    SensoryFeedbackService.shared.buttonTap()
                                    newGoalName = ""
                                    newGoalAmount = 0
                                    newGoalIcon = "star.fill"
                                    showingAddGoal = true
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(Design.Colors.gold)
                            }
                            .buttonStyle(.plain)
                        }

                        if !subscriptionManager.isPro {
                            Text("\(goals.count) of 1 free goal used • Pro unlocks unlimited parallel goals")
                                .font(.caption2)
                                .foregroundStyle(Design.Colors.textTertiary)
                        }

                        if goals.isEmpty {
                            ContentUnavailableView(
                                "No Savings Goals",
                                systemImage: "target",
                                description: Text("Add a goal to watch your saved money grow.")
                            )
                        } else {
                            ForEach(goals) { goal in
                                SavingsGoalCardView(
                                    goalName: goal.name,
                                    savedAmount: viewModel.totalSaved,
                                    targetAmount: goal.targetAmount,
                                    icon: goal.icon
                                )
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.deleteGoal(context: modelContext, goal: goal)
                                        SensoryFeedbackService.shared.selectionClick()
                                    } label: {
                                        Label("Delete Goal", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(Design.Spacing.md)
            }
        }
        .navigationTitle("Finances")
        .toolbar {
            Button("New Goal", systemImage: "plus") {
                if !subscriptionManager.isPro && goals.count >= 1 {
                    showingPaywall = true
                } else {
                    SensoryFeedbackService.shared.buttonTap()
                    newGoalName = ""
                    newGoalAmount = 0
                    newGoalIcon = "star.fill"
                    showingAddGoal = true
                }
            }
        }
        .sheet(isPresented: $showingAddGoal) {
            addGoalSheet
                .scrollIndicators(.hidden)
        }
        .sheet(isPresented: $showingEquivalentsSheet) {
            SavingsEquivalentsSheet(moneySaved: viewModel.totalSaved)
                .scrollIndicators(.hidden)
        }
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
        .scrollIndicators(.hidden)
        .task {
            updateSavings()
        }
        .onChange(of: profiles.first?.sobrietyStartDate) { _, _ in
            updateSavings()
        }
        .onChange(of: profiles.first?.dailyGamblingSpend) { _, _ in
            updateSavings()
        }
        .onChange(of: preventedEntries.count) { _, _ in
            updateSavings()
        }
    }

    private func updateSavings() {
        if let profile = profiles.first {
            viewModel.calculateSavings(
                startDate: profile.sobrietyStartDate,
                dailySpend: profile.dailyGamblingSpend,
                context: modelContext
            )
        }
    }

    private func projectionCard(title: String, amount: Double) -> some View {
        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Design.Colors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(amount, format: .currency(code: AppPreferences.shared.currencyCode))
                .font(.headline)
                .bold()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .sereneCardStyle(padding: Design.Spacing.md)
    }

    private var addGoalSheet: some View {
        NavigationStack {
            ZStack {
                FlutedGlassBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Design.Spacing.lg) {
                        // 1. Live Hero Goal Preview Puck
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [Design.Colors.gold.opacity(0.32), Color.clear],
                                            center: .center,
                                            startRadius: 10,
                                            endRadius: 42
                                        )
                                    )
                                    .frame(width: 84, height: 84)

                                Circle()
                                    .fill(Color(white: 0.12))
                                    .frame(width: 66, height: 66)

                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Design.Colors.gold.opacity(0.28), Design.Colors.copper.opacity(0.16)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 66, height: 66)

                                Circle()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [Design.Colors.champagne, Design.Colors.gold.opacity(0.50)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                                    .frame(width: 66, height: 66)

                                Image(systemName: newGoalIcon)
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundStyle(Design.Colors.champagne)
                                    .shadow(color: Design.Colors.gold.opacity(0.6), radius: 6, y: 1)
                            }
                            .padding(.top, Design.Spacing.xs)

                            Text(newGoalName.isEmpty ? "New Savings Goal" : newGoalName)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Color.white)
                                .lineLimit(1)

                            if newGoalAmount > 0 {
                                Text(newGoalAmount, format: .currency(code: "USD"))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Design.Colors.gold)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        // 2. Quick Presets
                        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
                            Text("QUICK PRESETS")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Design.Colors.gold)
                                .padding(.leading, 8)
                                .lineLimit(1)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    presetChip(name: "Emergency Fund", amount: 1000, icon: "shield.fill")
                                    presetChip(name: "Vacation", amount: 2000, icon: "airplane")
                                    presetChip(name: "Debt Freedom", amount: 3000, icon: "creditcard.fill")
                                    presetChip(name: "Tech Upgrade", amount: 1200, icon: "laptopcomputer")
                                    presetChip(name: "Shopping", amount: 500, icon: "gift.fill")
                                }
                                .padding(.leading, 8)
                                .padding(.trailing, 8)
                            }
                            .scrollClipDisabled()
                            .smoothHorizontalScroll(bleedPadding: 8, leadingFade: 16, trailingFade: 28)
                        }

                        // 3. Goal Details (Single clean card)
                        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
                            Text("GOAL DETAILS")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Design.Colors.gold)
                                .padding(.leading, 8)
                                .lineLimit(1)

                            VStack(spacing: Design.Spacing.md) {
                                HStack(spacing: 12) {
                                    Image(systemName: "pencil")
                                        .font(.subheadline)
                                        .foregroundStyle(Design.Colors.gold)
                                        .frame(width: 24)

                                    TextField("Goal Name (e.g. Vacation)", text: $newGoalName)
                                        .foregroundStyle(Design.Colors.textPrimary)
                                        .font(.body)
                                }

                                Divider().background(Color.white.opacity(0.12))

                                HStack(spacing: 12) {
                                    Image(systemName: "dollarsign.circle.fill")
                                        .font(.subheadline)
                                        .foregroundStyle(Design.Colors.primary)
                                        .frame(width: 24)

                                    TextField("Target Amount in USD", value: $newGoalAmount, format: .currency(code: "USD"))
                                        .keyboardType(.decimalPad)
                                        .foregroundStyle(Design.Colors.textPrimary)
                                        .font(.body.weight(.semibold))
                                }
                            }
                            .sereneCardStyle(padding: Design.Spacing.md)
                        }

                        // 4. Circular Icon Badges
                        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
                            Text("SELECT ICON")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Design.Colors.gold)
                                .padding(.leading, 8)
                                .lineLimit(1)

                            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 12), count: 4), spacing: 14) {
                                ForEach(predefinedIcons) { item in
                                    let isSelected = newGoalIcon == item.icon
                                    Button {
                                        withAnimation(Design.Anim.spring) {
                                            newGoalIcon = item.icon
                                            SensoryFeedbackService.shared.selectionClick()
                                        }
                                    } label: {
                                        VStack(spacing: 6) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color(white: 0.12))
                                                    .frame(width: 50, height: 50)

                                                if isSelected {
                                                    Circle()
                                                        .fill(
                                                            LinearGradient(
                                                                colors: [Design.Colors.gold, Design.Colors.copper],
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            )
                                                        )
                                                        .frame(width: 50, height: 50)
                                                        .shadow(color: Design.Colors.gold.opacity(0.55), radius: 8, y: 2)

                                                    Circle()
                                                        .strokeBorder(Color.white.opacity(0.95), lineWidth: 2)
                                                        .frame(width: 50, height: 50)

                                                    Image(systemName: item.icon)
                                                        .font(.system(size: 20, weight: .bold))
                                                        .foregroundStyle(Color.black.opacity(0.85))
                                                } else {
                                                    Circle()
                                                        .fill(Color.white.opacity(0.06))
                                                        .frame(width: 50, height: 50)

                                                    Circle()
                                                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                                                        .frame(width: 50, height: 50)

                                                    Image(systemName: item.icon)
                                                        .font(.system(size: 19, weight: .medium))
                                                        .foregroundStyle(Design.Colors.champagne.opacity(0.85))
                                                }
                                            }
                                            .scaleEffect(isSelected ? 1.08 : 1.0)

                                            Text(item.label)
                                                .font(.caption2)
                                                .foregroundStyle(isSelected ? Design.Colors.gold : Design.Colors.textSecondary)
                                                .lineLimit(1)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .sereneCardStyle(padding: Design.Spacing.md)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, Design.Spacing.md)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingAddGoal = false }
                        .foregroundStyle(Design.Colors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard !newGoalName.isEmpty, newGoalAmount > 0 else { return }
                        viewModel.addGoal(context: modelContext, name: newGoalName, targetAmount: newGoalAmount, icon: newGoalIcon)
                        showingAddGoal = false
                    }
                    .bold()
                    .foregroundStyle(Design.Colors.gold)
                    .disabled(newGoalName.isEmpty || newGoalAmount <= 0)
                }
            }
        }
    }

    private func presetChip(name: String, amount: Double, icon: String) -> some View {
        let isSelected = newGoalName == name
        return Button {
            withAnimation(Design.Anim.spring) {
                newGoalName = name
                newGoalAmount = amount
                newGoalIcon = icon
                SensoryFeedbackService.shared.selectionClick()
            }
        } label: {
            HStack(spacing: 7) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Design.Colors.gold : Color.white.opacity(0.12))
                        .frame(width: 24, height: 24)
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(isSelected ? Color.black : Design.Colors.gold)
                }

                Text(name)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)

                Text(amount, format: .currency(code: "USD"))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Design.Colors.champagne)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(isSelected ? Design.Colors.gold.opacity(0.18) : Color.white.opacity(0.07))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? Design.Colors.gold : Color.white.opacity(0.12),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        FinanceView()
    }
    .modelContainer(for: [UserProfile.self, SavingsGoal.self], inMemory: true)
}
