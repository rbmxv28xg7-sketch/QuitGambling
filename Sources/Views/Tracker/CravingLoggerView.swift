import SwiftUI
import SwiftData

struct CravingLoggerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var profiles: [UserProfile]
    @Query(sort: \JournalEntry.date, order: .reverse) private var journalEntries: [JournalEntry]

    @State private var intensity: Double = 5
    @State private var selectedTrigger: Design.Trigger = .other
    @State private var notes: String = ""
    @State private var wasRelapse: Bool = false

    private var currentMood: Int {
        journalEntries.first(where: { Calendar.current.isDateInToday($0.date) })?.mood ?? 3
    }

    private var intensityTitle: String {
        switch Int(intensity) {
        case 1...2: return "Very Mild • Barely Noticeable"
        case 3...4: return "Mild • Easily Controlled"
        case 5...6: return "Moderate • Noticeable Urge"
        case 7...8: return "Strong • Active Distraction Needed"
        case 9...10: return "Extreme • High Alert"
        default: return ""
        }
    }

    private var intensityColor: Color {
        switch Int(intensity) {
        case 1...3: return Design.Colors.signalGreen
        case 4...6: return Design.Colors.gold
        case 7...8: return Design.Colors.amberGold
        case 9...10: return Design.Colors.sos
        default: return Design.Colors.gold
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FlutedGlassBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Design.Spacing.lg) {
                        Text("Log Urge")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, Design.Spacing.xs)

                        cravingSection("Urge Intensity") {
                            VStack(spacing: Design.Spacing.md) {
                                // Question & Hero Number Display
                                VStack(spacing: 6) {
                                    Text("How intense is your urge right now?")
                                        .font(.subheadline)
                                        .foregroundStyle(Design.Colors.textSecondary)

                                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                                        Text("\(Int(intensity))")
                                            .font(.system(size: 46, weight: .bold, design: .rounded))
                                            .foregroundStyle(intensityColor)

                                        Text("/ 10")
                                            .font(.title3.weight(.semibold))
                                            .foregroundStyle(Design.Colors.textSecondary)
                                    }

                                    Text(intensityTitle)
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(intensityColor)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(intensityColor.opacity(0.14))
                                        .clipShape(Capsule())
                                }
                                .frame(maxWidth: .infinity)
                                // 100% Silent Custom Slider (Zero UIKit/System haptics)
                                SilentIntensitySlider(value: $intensity, tintColor: intensityColor)
                                    .padding(.vertical, 4)

                                // 1 to 10 Quick-Select Tap Buttons
                                HStack(spacing: 4) {
                                    ForEach(1...10, id: \.self) { num in
                                        let isSelected = Int(intensity) == num
                                        Button {
                                            SensoryFeedbackService.shared.selectionClick()
                                            withAnimation(.easeOut(duration: 0.15)) {
                                                intensity = Double(num)
                                            }
                                        } label: {
                                            Text("\(num)")
                                                .font(.system(size: 13, weight: isSelected ? .bold : .medium, design: .rounded))
                                                .foregroundStyle(isSelected ? Color.black : Color.white.opacity(0.85))
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 32)
                                                .background(
                                                    isSelected
                                                        ? intensityColor
                                                        : Color.white.opacity(0.08)
                                                )
                                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                        .stroke(isSelected ? Color.clear : Color.white.opacity(0.12), lineWidth: 1)
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        cravingSection("Trigger") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: Design.Spacing.sm) {
                                    ForEach(Design.Trigger.allCases) { trigger in
                                        let isSelected = selectedTrigger == trigger
                                        Button {
                                            SensoryFeedbackService.shared.selectionClick()
                                            selectedTrigger = trigger
                                        } label: {
                                            HStack(spacing: 6) {
                                                Image(systemName: trigger.icon)
                                                Text(trigger.rawValue)
                                            }
                                            .padding(.horizontal, Design.Spacing.md)
                                            .padding(.vertical, Design.Spacing.sm)
                                            .background(isSelected ? Design.Colors.primary : Color.white.opacity(0.08))
                                            .foregroundStyle(isSelected ? Design.Colors.textOnPrimary : Design.Colors.textSecondary)
                                            .clipShape(.capsule)
                                            .overlay(
                                                Capsule()
                                                    .stroke(isSelected ? Color.clear : Color.white.opacity(0.12), lineWidth: 1)
                                            )
                                        }
                                        .frame(minHeight: 44)
                                    }
                                }
                                .padding(.leading, Design.Spacing.md)
                                .padding(.trailing, Design.Spacing.md)
                                .padding(.vertical, 4)
                            }
                            .scrollClipDisabled()
                            .smoothHorizontalScroll(bleedPadding: Design.Spacing.md, leadingFade: 24, trailingFade: 36)
                        }

                        cravingSection("Notes & Thoughts") {
                            TextField("What went through your mind?", text: $notes, axis: .vertical)
                                .lineLimit(3...6)
                                .frame(minHeight: 44)
                                .foregroundStyle(Design.Colors.textPrimary)
                        }

                        cravingSection(nil) {
                            Toggle(isOn: $wasRelapse) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Record Relapse")
                                        .font(.body)
                                        .bold()
                                        .foregroundStyle(wasRelapse ? Design.Colors.sos : Design.Colors.textPrimary)
                                    Text("Setbacks are part of the recovery process. Be honest with yourself.")
                                        .font(.caption2)
                                        .foregroundStyle(Design.Colors.textSecondary)
                                }
                            }
                            .tint(Design.Colors.sos)
                            .onChange(of: wasRelapse) { _, _ in
                                SensoryFeedbackService.shared.toggleChanged()
                            }

                            if wasRelapse {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.counterclockwise.circle.fill")
                                        .font(.subheadline)
                                        .foregroundStyle(Design.Colors.sos)
                                    Text("Your streak counter and days will be reset starting from this moment.")
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(Color.white.opacity(0.90))
                                }
                                .padding(.top, 4)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
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
                    Button("Cancel") {
                        SensoryFeedbackService.shared.selectionClick()
                        dismiss()
                    }
                    .foregroundStyle(Design.Colors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .bold()
                    .foregroundStyle(Design.Colors.gold)
                }
            }
        }
        .dismissKeyboardOnTap()
    }

    private func cravingSection<Content: View>(_ title: String?, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
            if let title {
                Text(title.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Design.Colors.gold)
                    .padding(.leading, 8)
            }

            VStack(spacing: Design.Spacing.md) {
                content()
            }
            .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.md)
        }
    }

    private func save() {
        let log = CravingLog(
            intensity: Int(intensity),
            trigger: selectedTrigger.rawValue,
            mood: currentMood,
            notes: notes,
            wasRelapse: wasRelapse
        )
        modelContext.insert(log)

        if wasRelapse {
            // Unconditionally reset sobriety date and timer starting from this exact moment
            if let profile = profiles.first {
                profile.sobrietyStartDate = .now
                profile.pledgedToday = false
                profile.lastPledgeDate = nil
            }

            // Synchronize with today's JournalEntry
            let calendar = Calendar.current
            let descriptor = FetchDescriptor<JournalEntry>()
            if let entries = try? modelContext.fetch(descriptor),
               let todayEntry = entries.first(where: { calendar.isDateInToday($0.date) }) {
                todayEntry.wasRelapse = true
                todayEntry.hadCravings = true
            } else {
                let entry = JournalEntry(
                    date: .now,
                    text: notes,
                    mood: currentMood,
                    gratitude: "",
                    hadCravings: true,
                    wasRelapse: true
                )
                modelContext.insert(entry)
            }

            SensoryFeedbackService.shared.relapseRecorded()
        } else {
            SensoryFeedbackService.shared.selectionClick()
        }

        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    CravingLoggerView()
        .modelContainer(for: [UserProfile.self, CravingLog.self, JournalEntry.self], inMemory: true)
}

/// 100% Custom, Pure SwiftUI Intensity Slider.
/// Guaranteed ZERO system haptic detents (unlike native iOS Slider with step).
struct SilentIntensitySlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double> = 1...10
    let tintColor: Color

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let thumbDiameter: CGFloat = 26
            let trackHeight: CGFloat = 8
            let usableWidth = max(1, totalWidth - thumbDiameter)

            let progress = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
            let clampedProgress = min(max(progress, 0.0), 1.0)
            let thumbOffset = clampedProgress * usableWidth

            ZStack(alignment: .leading) {
                // Background Track
                Capsule()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: trackHeight)

                // Filled Colored Track
                Capsule()
                    .fill(tintColor)
                    .frame(width: thumbOffset + thumbDiameter / 2, height: trackHeight)

                // Thumb Knob
                Circle()
                    .fill(Color.white)
                    .frame(width: thumbDiameter, height: thumbDiameter)
                    .shadow(color: Color.black.opacity(0.35), radius: 3, y: 1)
                    .overlay(
                        Circle()
                            .stroke(tintColor, lineWidth: 2)
                    )
                    .offset(x: thumbOffset)
            }
            .frame(height: max(thumbDiameter, 44))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let locationX = min(max(gesture.location.x - thumbDiameter / 2, 0), usableWidth)
                        let newFraction = usableWidth > 0 ? Double(locationX / usableWidth) : 0
                        let rawValue = range.lowerBound + newFraction * (range.upperBound - range.lowerBound)
                        let rounded = Double(round(rawValue))
                        if rounded != value {
                            value = rounded
                            SensoryFeedbackService.shared.selectionClick()
                        }
                    }
            )
        }
        .frame(height: 36)
    }
}
