import SwiftUI
import SwiftData

/// 15-Second Daily Check-in Sheet: Frictionless, empathetic emotional & gambling reflection.
struct DailyCheckInSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var profiles: [UserProfile]
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]

    // Form State
    @State private var selectedMood: Int = 4
    @State private var wasRelapse: Bool = false
    @State private var moneyLostText: String = ""
    @State private var selectedTag: String = ""
    @State private var thoughtText: String = ""
    @State private var resetSobrietyDate: Bool = false
    @State private var preventedLossAmount: Double = 0

    private let moodOptions: [(id: Int, title: String, icon: String)] = [
        (5, "Strong & Clear", "shield.fill"),
        (4, "Calm", "leaf.fill"),
        (3, "Neutral", "circle.fill"),
        (2, "Anxious", "bolt.fill"),
        (1, "Strong Urge", "flame.fill")
    ]

    private let quickTags: [String] = [
        "Worked out",
        "Overcame urge",
        "Felt stressed",
        "Proud of myself",
        "Felt lonely",
        "Grateful"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                FlutedGlassBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Design.Spacing.lg) {
                        // Header
                        VStack(spacing: 4) {
                            Text("Daily Reflection")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white)
                            Text("15 seconds for your clarity and honesty.")
                                .font(.caption)
                                .foregroundStyle(Design.Colors.textSecondary)
                        }
                        .padding(.top, Design.Spacing.sm)

                        // Step 1: Mood Pills
                        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                            Text("HOW ARE YOU FEELING TODAY?")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .tracking(1.5)
                                .foregroundStyle(Design.Colors.textSecondary)

                            HStack(spacing: 6) {
                                ForEach(moodOptions, id: \.id) { option in
                                    Button {
                                        selectedMood = option.id
                                        SensoryFeedbackService.shared.selectionClick()
                                    } label: {
                                        VStack(spacing: 6) {
                                            Image(systemName: option.icon)
                                                .font(.system(size: 16))
                                            Text(option.title)
                                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .foregroundStyle(selectedMood == option.id ? Color.white : Design.Colors.textSecondary)
                                        .background(
                                            RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                                                .fill(selectedMood == option.id ? Design.Colors.primary.opacity(0.25) : Color.white.opacity(0.05))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                                                .strokeBorder(
                                                    selectedMood == option.id ? Design.Colors.primary : Color.white.opacity(0.08),
                                                    lineWidth: selectedMood == option.id ? 1.5 : 1
                                                )
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, Design.Spacing.md)

                        // Step 2: Honest Status
                        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                            Text("YOUR STATUS TODAY")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .tracking(1.5)
                                .foregroundStyle(Design.Colors.textSecondary)

                            HStack(spacing: Design.Spacing.md) {
                                // Clean Card
                                Button {
                                    withAnimation(Design.Anim.spring) {
                                        wasRelapse = false
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.title3)
                                        Text("Gamble-Free")
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .foregroundStyle(!wasRelapse ? Color.white : Design.Colors.textSecondary)
                                    .background(
                                        RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                                            .fill(!wasRelapse ? Design.Colors.primary.opacity(0.20) : Color.white.opacity(0.04))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                                            .strokeBorder(!wasRelapse ? Design.Colors.primary : Color.white.opacity(0.08), lineWidth: !wasRelapse ? 1.5 : 1)
                                    )
                                }
                                .buttonStyle(.plain)

                                // Relapse Card
                                Button {
                                    withAnimation(Design.Anim.spring) {
                                        wasRelapse = true
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.title3)
                                        Text("Relapse / Money Lost")
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .foregroundStyle(wasRelapse ? Design.Colors.signalRed : Design.Colors.textSecondary)
                                    .background(
                                        RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                                            .fill(wasRelapse ? Design.Colors.signalRed.opacity(0.18) : Color.white.opacity(0.04))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                                            .strokeBorder(wasRelapse ? Design.Colors.signalRed : Color.white.opacity(0.08), lineWidth: wasRelapse ? 1.5 : 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }

                            // If Relapse: Compassionate input
                            if wasRelapse {
                                VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                                    Text("Amount spent in $ (optional)")
                                        .font(.caption2)
                                        .foregroundStyle(Design.Colors.textSecondary)

                                    TextField("e.g. 50", text: $moneyLostText)
                                        .keyboardType(.numberPad)
                                        .padding()
                                        .background(Color.white.opacity(0.06))
                                        .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous))
                                        .foregroundStyle(Color.white)

                                    Text("Honesty brings freedom. No judgment — what matters is that you keep going right now.")
                                        .font(.caption2)
                                        .foregroundStyle(Design.Colors.textSecondary)
                                        .padding(.top, 2)

                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.counterclockwise.circle.fill")
                                            .font(.subheadline)
                                            .foregroundStyle(Design.Colors.signalRed)
                                        Text("Your sobriety timer and days will be reset to 0 from this moment.")
                                            .font(.caption.weight(.medium))
                                            .foregroundStyle(Color.white.opacity(0.90))
                                    }
                                    .padding(.top, 4)
                                }
                                .padding(Design.Spacing.md)
                                .background(Color.white.opacity(0.04))
                                .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous))
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            } else {
                                // If clean: Optional acute prevented loss booster
                                VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                                    HStack {
                                        Text("AVERTED PLANNED GAMBLING?")
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                            .tracking(1.2)
                                            .foregroundStyle(Design.Colors.gold)

                                        Spacer()

                                        Text("Optional")
                                            .font(.caption2)
                                            .foregroundStyle(Design.Colors.textTertiary)
                                    }

                                    HStack(spacing: 8) {
                                        ForEach([20, 50, 100, 200], id: \.self) { amount in
                                            Button {
                                                withAnimation(Design.Anim.spring) {
                                                    if preventedLossAmount == Double(amount) {
                                                        preventedLossAmount = 0
                                                    } else {
                                                        preventedLossAmount = Double(amount)
                                                    }
                                                }
                                                SensoryFeedbackService.shared.selectionClick()
                                            } label: {
                                                Text("+$\(amount)")
                                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                                    .lineLimit(1)
                                                    .frame(maxWidth: .infinity)
                                                    .frame(height: 36)
                                                    .foregroundStyle(preventedLossAmount == Double(amount) ? Design.Colors.textOnPrimary : Color.white)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: Design.Radius.sm, style: .continuous)
                                                            .fill(preventedLossAmount == Double(amount) ? Design.Colors.primary : Color.white.opacity(0.06))
                                                    )
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: Design.Radius.sm, style: .continuous)
                                                            .strokeBorder(preventedLossAmount == Double(amount) ? Design.Colors.primary : Color.white.opacity(0.12), lineWidth: 1)
                                                    )
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }

                                    if preventedLossAmount > 0 {
                                        HStack(spacing: 4) {
                                            Image(systemName: "checkmark.shield.fill")
                                                .font(.caption2)
                                                .foregroundStyle(Design.Colors.gold)
                                            Text("$\(Int(preventedLossAmount)) saved — credited to your tracker as a victory.")
                                                .font(.caption2)
                                                .foregroundStyle(Design.Colors.gold)
                                                .contentTransition(.numericText())
                                                .animation(Design.Anim.spring, value: preventedLossAmount)
                                        }
                                        .padding(.top, 2)
                                    }
                                }
                                .padding(Design.Spacing.md)
                                .background(Color.white.opacity(0.03))
                                .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous))
                                .transition(.opacity)
                            }
                        }
                        .padding(.horizontal, Design.Spacing.md)

                        // Step 3: Quick Tag Chips
                        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                            Text("DAILY IMPULSE (QUICK SELECT)")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .tracking(1.5)
                                .foregroundStyle(Design.Colors.textSecondary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(quickTags, id: \.self) { tag in
                                        Button {
                                            SensoryFeedbackService.shared.selectionClick()
                                            if selectedTag == tag {
                                                selectedTag = ""
                                            } else {
                                                selectedTag = tag
                                            }
                                        } label: {
                                            Text(tag)
                                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .foregroundStyle(selectedTag == tag ? Color.white : Design.Colors.textSecondary)
                                                .background(
                                                    Capsule()
                                                        .fill(selectedTag == tag ? Design.Colors.primary.opacity(0.30) : Color.white.opacity(0.05))
                                                )
                                                .overlay(
                                                    Capsule()
                                                        .strokeBorder(selectedTag == tag ? Design.Colors.primary : Color.white.opacity(0.08), lineWidth: 1)
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.leading, Design.Spacing.md)
                                .padding(.trailing, Design.Spacing.md)
                            }
                            .scrollClipDisabled()
                            .smoothHorizontalScroll(bleedPadding: Design.Spacing.md, leadingFade: 24, trailingFade: 36)
                        }
                        .padding(.horizontal, Design.Spacing.md)

                        // Step 4: Optional Micro-Comment
                        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                            Text("A THOUGHT FOR TODAY (OPTIONAL)")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .tracking(1.5)
                                .foregroundStyle(Design.Colors.textSecondary)

                            TextField("What is on your mind?", text: $thoughtText, axis: .vertical)
                                .lineLimit(2...4)
                                .padding(Design.Spacing.md)
                                .background(Color.white.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous))
                                .foregroundStyle(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, Design.Spacing.md)

                        // Step 5: Save Button
                        Button {
                            saveCheckIn()
                        } label: {
                            Text("Save Check-In")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Design.Colors.textOnPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                                        .fill(Design.Colors.primary)
                                )
                                .shadow(color: Design.Colors.primary.opacity(0.3), radius: 10, y: 4)
                        }
                        .padding(.horizontal, Design.Spacing.md)
                        .padding(.top, Design.Spacing.sm)
                        .padding(.bottom, Design.Spacing.xl)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(Design.Colors.textSecondary)
                }
            }
            .onAppear {
                loadTodayIfAvailable()
            }
            .scrollIndicators(.hidden)
        }
        .scrollIndicators(.hidden)
        .dismissKeyboardOnTap()
        .sensoryFeedback(.impact(weight: .medium), trigger: selectedMood)
    }

    // MARK: - Actions

    private func loadTodayIfAvailable() {
        // If there is already an entry for today, pre-fill it for easy editing
        let calendar = Calendar.current
        if let todayEntry = entries.first(where: { calendar.isDateInToday($0.date) }) {
            selectedMood = todayEntry.mood
            wasRelapse = todayEntry.wasRelapse
            if todayEntry.moneyLost > 0 {
                moneyLostText = String(format: "%.0f", todayEntry.moneyLost)
            }
            selectedTag = todayEntry.tag
            thoughtText = todayEntry.text
        }
    }

    private func saveCheckIn() {
        let calendar = Calendar.current
        let money = Double(moneyLostText.replacingOccurrences(of: ",", with: ".")) ?? 0.0

        if let existing = entries.first(where: { calendar.isDateInToday($0.date) }) {
            existing.mood = selectedMood
            existing.wasRelapse = wasRelapse
            existing.moneyLost = money
            existing.tag = selectedTag
            existing.text = thoughtText
        } else {
            let entry = JournalEntry(
                date: .now,
                text: thoughtText,
                mood: selectedMood,
                gratitude: "",
                hadCravings: wasRelapse || selectedMood <= 2,
                wasRelapse: wasRelapse,
                moneyLost: money,
                tag: selectedTag
            )
            modelContext.insert(entry)
        }

        // If relapse: unconditionally reset timer and days from this exact moment!
        if wasRelapse {
            if let profile = profiles.first {
                profile.sobrietyStartDate = .now
                profile.pledgedToday = false
                profile.lastPledgeDate = nil
            }
            // Also ensure a CravingLog with wasRelapse is present for today so tracker/analytics are synchronized
            let descriptor = FetchDescriptor<CravingLog>()
            if let logs = try? modelContext.fetch(descriptor) {
                if !logs.contains(where: { calendar.isDateInToday($0.date) && $0.wasRelapse }) {
                    let log = CravingLog(
                        date: .now,
                        intensity: 10,
                        trigger: selectedTag.isEmpty ? "Daily Check-in" : selectedTag,
                        mood: selectedMood,
                        notes: thoughtText,
                        wasRelapse: true
                    )
                    modelContext.insert(log)
                }
            }
        }

        // If clean and prevented loss recorded
        if !wasRelapse && preventedLossAmount > 0 {
            let prevented = PreventedLossEntry(
                amount: preventedLossAmount,
                note: "Successfully prevented during daily check-in",
                contextTag: "Daily Check-in"
            )
            modelContext.insert(prevented)
        }

        try? modelContext.save()
        if wasRelapse {
            SensoryFeedbackService.shared.relapseRecorded()
        } else {
            SensoryFeedbackService.shared.checkInSaved()
        }
        dismiss()
    }
}

#Preview {
    DailyCheckInSheet()
        .modelContainer(for: [JournalEntry.self, UserProfile.self], inMemory: true)
}
