import SwiftUI
import SwiftData

struct FinanceView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var goals: [SavingsGoal]
    @State private var viewModel = FinanceViewModel()
    @State private var showingAddGoal = false
    @State private var newGoalName = ""
    @State private var newGoalAmount: Double = 0
    @State private var newGoalIcon = "star.fill"

    private let predefinedIcons = [
        "star.fill", "car.fill", "airplane", "house.fill",
        "gift.fill", "creditcard.fill", "graduationcap.fill", "heart.fill"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: Design.Spacing.lg) {
                SavingsProgressView(
                    totalSaved: viewModel.totalSaved,
                    startDate: profiles.first?.sobrietyStartDate ?? .now
                )

                // Projected savings
                HStack {
                    projectionCard(title: "In 1 Monat", amount: viewModel.projectedMonthlySavings)
                    projectionCard(title: "In 1 Jahr", amount: viewModel.projectedYearlySavings)
                }

                // Savings goals
                VStack(alignment: .leading, spacing: Design.Spacing.md) {
                    Text("Sparziele")
                        .font(.headline)

                    if goals.isEmpty {
                        ContentUnavailableView(
                            "Keine Sparziele",
                            systemImage: "target",
                            description: Text("Füge ein Ziel hinzu, um deinen Fortschritt zu sehen.")
                        )
                    } else {
                        ForEach(goals) { goal in
                            SavingsGoalCardView(
                                goalName: goal.name,
                                savedAmount: viewModel.totalSaved,
                                targetAmount: goal.targetAmount,
                                icon: goal.icon
                            )
                        }
                    }
                }
            }
            .padding(Design.Spacing.md)
        }
        .navigationTitle("Finanzen")
        .toolbar {
            Button("Neues Ziel", systemImage: "plus") {
                newGoalName = ""
                newGoalAmount = 0
                newGoalIcon = "star.fill"
                showingAddGoal = true
            }
        }
        .sheet(isPresented: $showingAddGoal) {
            addGoalSheet
        }
        .task {
            if let profile = profiles.first {
                viewModel.calculateSavings(
                    startDate: profile.sobrietyStartDate,
                    dailySpend: profile.dailyGamblingSpend
                )
            }
        }
    }

    private func projectionCard(title: String, amount: Double) -> some View {
        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(amount, format: .currency(code: "EUR"))
                .font(.headline)
                .bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Design.Spacing.md)
        .background(Design.Colors.surface)
        .clipShape(.rect(cornerRadius: Design.Radius.md))
    }

    private var addGoalSheet: some View {
        NavigationStack {
            Form {
                TextField("Name des Ziels", text: $newGoalName)
                TextField("Betrag", value: $newGoalAmount, format: .currency(code: "EUR"))
                    .keyboardType(.decimalPad)

                Section("Symbol") {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4), spacing: Design.Spacing.md) {
                        ForEach(predefinedIcons, id: \.self) { icon in
                            Button {
                                newGoalIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 52, height: 52)
                                    .background(newGoalIcon == icon ? Design.Colors.primary.opacity(0.15) : Color.clear)
                                    .clipShape(.rect(cornerRadius: Design.Radius.sm))
                            }
                            .tint(newGoalIcon == icon ? Design.Colors.primary : .secondary)
                        }
                    }
                }
            }
            .navigationTitle("Neues Sparziel")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { showingAddGoal = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        guard !newGoalName.isEmpty, newGoalAmount > 0 else { return }
                        viewModel.addGoal(context: modelContext, name: newGoalName, targetAmount: newGoalAmount, icon: newGoalIcon)
                        showingAddGoal = false
                    }
                    .disabled(newGoalName.isEmpty || newGoalAmount <= 0)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FinanceView()
    }
    .modelContainer(for: [UserProfile.self, SavingsGoal.self], inMemory: true)
}
