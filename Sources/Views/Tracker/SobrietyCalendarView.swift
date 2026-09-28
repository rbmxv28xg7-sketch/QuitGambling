import SwiftUI
import SwiftData

/// Liquid Glass Sobriety Calendar displaying daily clean status, subtle mood heatmap dots,
/// and an interactive Day Detail Sheet showing mood, reflections, cravings, and savings.
struct SobrietyCalendarView: View {
    @Bindable var viewModel: TrackerViewModel
    var logs: [CravingLog]

    @Query private var profiles: [UserProfile]
    @Query(sort: \JournalEntry.date, order: .reverse) private var journalEntries: [JournalEntry]
    @State private var selectedDate: Date?

    private var daysOfWeek: [String] {
        LocalizationService.shared.weekdays
    }

    var body: some View {
        VStack(spacing: Design.Spacing.md) {
            // Header with Month Navigation
            HStack {
                Button(action: {
                    SensoryFeedbackService.shared.selectionClick()
                    viewModel.previousMonth()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.body.bold())
                        .foregroundStyle(Design.Colors.primary)
                        .frame(minWidth: 44, minHeight: 44)
                }
                Spacer()
                Text(viewModel.selectedMonth, format: .dateTime.month(.wide).year())
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Design.Colors.ivory)
                Spacer()
                Button(action: {
                    SensoryFeedbackService.shared.selectionClick()
                    viewModel.nextMonth()
                }) {
                    Image(systemName: "chevron.right")
                        .font(.body.bold())
                        .foregroundStyle(Design.Colors.primary)
                        .frame(minWidth: 44, minHeight: 44)
                }
            }
            .padding(.horizontal, Design.Spacing.xs)

            // Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: Design.Spacing.sm) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Design.Colors.textSecondary)
                        .shadow(color: Color.black.opacity(0.35), radius: 1.5, y: 1)
                }

                let days = getDaysInMonth()
                ForEach(days, id: \.self) { date in
                    let status = viewModel.dayStatus(
                        for: date,
                        logs: logs,
                        journalEntries: journalEntries,
                        startDate: profiles.first?.sobrietyStartDate ?? .now
                    )
                    let isToday = Calendar.current.isDateInToday(date)
                    let entry = journalEntries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }

                    ZStack {
                        RoundedRectangle(cornerRadius: Design.Radius.sm, style: .continuous)
                            .fill(dayCellBackground(for: status))

                        RoundedRectangle(cornerRadius: Design.Radius.sm, style: .continuous)
                            .strokeBorder(dayCellBorder(for: status, isToday: isToday), lineWidth: isToday ? 2 : 1)

                        VStack(spacing: 2) {
                            Text(date, format: .dateTime.day())
                                .font(.callout.weight(isToday || status == .clean ? .bold : .regular))
                                .foregroundStyle(dayCellTextColor(for: status, isToday: isToday))
                                .shadow(color: Color.black.opacity(status == .clean ? 0.2 : 0.35), radius: 1.5, y: 1)

                            // Subtle Mood Heatmap Dot
                            if let entry = entry {
                                Circle()
                                    .fill(moodColor(for: entry.mood))
                                    .frame(width: 4, height: 4)
                                    .shadow(color: moodColor(for: entry.mood).opacity(0.6), radius: 2)
                            } else if status == .clean {
                                Circle()
                                    .fill(Design.Colors.primary.opacity(0.35))
                                    .frame(width: 3, height: 3)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        SensoryFeedbackService.shared.selectionClick()
                        selectedDate = date
                    }
                }
            }
            .padding(.horizontal, Design.Spacing.xs)
        }
        .sereneCardStyle(padding: Design.Spacing.md)
        .padding(.horizontal)
        .sheet(item: $selectedDate) { date in
            let entry = journalEntries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
            let dayLogs = logs.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            let status = viewModel.dayStatus(
                for: date,
                logs: logs,
                journalEntries: journalEntries,
                startDate: profiles.first?.sobrietyStartDate ?? .now
            )

            DayDetailSheet(
                date: date,
                entry: entry,
                cravings: dayLogs,
                status: status,
                startDate: profiles.first?.sobrietyStartDate ?? .now,
                dailySpend: profiles.first?.dailyGamblingSpend ?? 0
            )
            .scrollIndicators(.hidden)
            .presentationDetents([.fraction(0.65), .large])
            .presentationDragIndicator(.visible)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Styling Helpers

    private func dayCellBackground(for status: TrackerViewModel.DayStatus) -> Color {
        switch status {
        case .clean:
            return Design.Colors.primary.opacity(0.28)
        case .craving:
            return Design.Colors.copper.opacity(0.35)
        case .relapse:
            return Design.Colors.signalRed.opacity(0.35)
        case .future, .beforeStart:
            return Color.white.opacity(0.08)
        }
    }

    private func dayCellBorder(for status: TrackerViewModel.DayStatus, isToday: Bool) -> Color {
        if isToday {
            return Design.Colors.primary
        }
        switch status {
        case .clean:
            return Design.Colors.primary.opacity(0.70)
        case .craving:
            return Design.Colors.copper.opacity(0.75)
        case .relapse:
            return Design.Colors.signalRed.opacity(0.75)
        case .future, .beforeStart:
            return Color.white.opacity(0.14)
        }
    }

    private func dayCellTextColor(for status: TrackerViewModel.DayStatus, isToday: Bool) -> Color {
        if isToday {
            return Color.white
        }
        switch status {
        case .clean:
            return Color.white
        case .craving:
            return Design.Colors.champagne
        case .relapse:
            return Color.white
        case .beforeStart:
            return Color.white.opacity(0.60)
        case .future:
            return Color.white.opacity(0.35)
        }
    }

    private func getDaysInMonth() -> [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: viewModel.selectedMonth),
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: viewModel.selectedMonth)) else {
            return []
        }

        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
}

// MARK: - Day Detail Sheet

struct DayDetailSheet: View {
    let date: Date
    @State var entry: JournalEntry?
    let cravings: [CravingLog]
    let status: TrackerViewModel.DayStatus
    let startDate: Date
    let dailySpend: Double

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var quickMood: Int = 4
    @State private var isChangingMood: Bool = false

    private var isToday: Bool { Calendar.current.isDateInToday(date) }
    private var isFuture: Bool { date > .now && !isToday }
    private var isBeforeStart: Bool { date < Calendar.current.startOfDay(for: startDate) }
    private var isClean: Bool { status == .clean }

    private var dayNumber: Int? {
        let cal = Calendar.current
        guard date >= cal.startOfDay(for: startDate) && !isFuture else { return nil }
        let diff = cal.dateComponents([.day], from: cal.startOfDay(for: startDate), to: cal.startOfDay(for: date)).day ?? 0
        return diff + 1
    }

    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: Design.Spacing.lg) {
                    // Top Bar with Close Button
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(date, format: .dateTime.weekday(.wide).day().month(.wide).year())
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Color.white)

                            if let dayNum = dayNumber {
                                Text("Day %d of your journey".loc(dayNum))
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Design.Colors.gold)
                            }
                        }

                        Spacer()

                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Design.Colors.textSecondary)
                        }
                    }
                    .padding(.top, Design.Spacing.sm)

                    // Status Banner
                    statusBanner

                    // Mood & Check-in Reflection
                    moodSection

                    // Financial Gain for this day
                    if isClean && dailySpend > 0 {
                        savingsCard
                    }

                    // Neuro-Benefit / Motivation
                    mindfulInsightCard

                    // Dismiss Button
                    Button {
                        dismiss()
                    } label: {
                        Text("Done".loc)
                            .font(.headline)
                            .foregroundStyle(Design.Colors.textOnPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Design.Colors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .padding(.top, 4)
                }
                .padding(Design.Spacing.lg)
                .padding(.bottom, 24)
            }
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Status Banner

    private var statusBanner: some View {
        HStack(spacing: 12) {
            if isClean {
                Image(systemName: "checkmark.shield.fill")
                    .font(.title2)
                    .foregroundStyle(Design.Colors.signalGreen)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Clean & Free".loc)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.white)
                    Text("Your shield remained rock-solid on this day.".loc)
                        .font(.caption)
                        .foregroundStyle(Design.Colors.textSecondary)
                }

                Spacer()

                if dailySpend > 0 {
                    Text("+$\(Int(dailySpend))")
                        .font(.caption.bold())
                        .foregroundStyle(Design.Colors.signalGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Design.Colors.signalGreen.opacity(0.16))
                        .clipShape(Capsule())
                }
            } else if status == .craving {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundStyle(Design.Colors.copper)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Urge Overcome".loc)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.white)
                    Text("Faced the urge and stayed strong!".loc)
                        .font(.caption)
                        .foregroundStyle(Design.Colors.textSecondary)
                }
                Spacer()
            } else if status == .relapse {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundStyle(Design.Colors.signalRed)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Relapse Recorded".loc)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.white)
                    Text("The past does not define you. Every day is a new beginning.".loc)
                        .font(.caption)
                        .foregroundStyle(Design.Colors.textSecondary)
                }
                Spacer()
            } else if isFuture {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundStyle(Design.Colors.textTertiary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Future Day".loc)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.white)
                    Text("One day at a time.".loc)
                        .font(.caption)
                        .foregroundStyle(Design.Colors.textSecondary)
                }
                Spacer()
            } else {
                Image(systemName: "clock")
                    .font(.title2)
                    .foregroundStyle(Design.Colors.textTertiary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Before Your Journey".loc)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.white)
                    Text("Where your path to freedom began.".loc)
                        .font(.caption)
                        .foregroundStyle(Design.Colors.textSecondary)
                }
                Spacer()
            }
        }
        .padding(Design.Spacing.md)
        .liquidGlass(cornerRadius: Design.Radius.card)
    }

    // MARK: - Mood Section

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            HStack {
                Image(systemName: "face.smiling")
                    .foregroundStyle(entry != nil ? moodColor(for: entry!.mood) : Design.Colors.gold)
                Text("HOW YOU FELT".loc)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(entry != nil ? moodColor(for: entry!.mood) : Design.Colors.gold)
                Spacer()

                if entry != nil && !isFuture && !isBeforeStart {
                    Button {
                        withAnimation(Design.Anim.spring) {
                            isChangingMood.toggle()
                        }
                    } label: {
                        Text(isChangingMood ? "Close".loc : "Change".loc)
                            .font(.caption2.bold())
                            .foregroundStyle(Design.Colors.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Capsule())
                    }
                }
            }

            if let entry = entry {
                // Recorded Mood Display
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(moodColor(for: entry.mood).opacity(0.20))
                            .frame(width: 48, height: 48)
                            .overlay(
                                Circle()
                                    .strokeBorder(moodColor(for: entry.mood).opacity(0.50), lineWidth: 1.2)
                            )
                        MorphingMoodFace(
                            progress: CGFloat(entry.mood),
                            isSelected: true,
                            colorOverride: moodColor(for: entry.mood)
                        )
                        .frame(width: 28, height: 28)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(moodTitle(for: entry.mood))
                            .font(.headline.weight(.bold))
                            .foregroundStyle(moodColor(for: entry.mood))

                        if !entry.tag.isEmpty {
                            Text(entry.tag)
                                .font(.caption2.bold())
                                .foregroundStyle(Design.Colors.textSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.08))
                                .clipShape(Capsule())
                        }
                    }
                    Spacer()
                }

                if isChangingMood {
                    moodPickerRow(selectedMood: entry.mood)
                        .padding(.top, 4)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Gratitude Quote
                if !entry.gratitude.isEmpty {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("What you were grateful for:".loc)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Design.Colors.gold)
                        Text("“\(entry.gratitude)”")
                            .font(.subheadline.italic())
                            .foregroundStyle(Color.white.opacity(0.92))
                    }
                    .padding(Design.Spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                // Journal Reflection Note
                if !entry.text.isEmpty {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Journal Reflection:".loc)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Design.Colors.textSecondary)
                        Text("“\(entry.text)”")
                            .font(.subheadline)
                            .foregroundStyle(Color.white.opacity(0.88))
                    }
                    .padding(Design.Spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            } else if !isFuture && !isBeforeStart {
                // No mood yet - Quick Retroactive Entry matching live check-in smileys & colors
                VStack(alignment: .leading, spacing: 10) {
                    Text("No mood recorded for this day yet.".loc)
                        .font(.caption)
                        .foregroundStyle(Design.Colors.textSecondary)

                    Text("How did you feel on this day?".loc)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.white)

                    moodPickerRow(selectedMood: nil)
                }
            } else {
                Text("No records available.".loc)
                    .font(.caption)
                    .foregroundStyle(Design.Colors.textTertiary)
            }
        }
        .padding(Design.Spacing.lg)
        .liquidGlass(cornerRadius: Design.Radius.card)
    }

    private func moodPickerRow(selectedMood: Int?) -> some View {
        let options: [(id: Int, color: Color)] = [
            (1, Color(red: 0.68, green: 0.78, blue: 0.94)),
            (2, Color(red: 0.95, green: 0.55, blue: 0.42)),
            (3, Color(red: 0.78, green: 0.98, blue: 0.20)),
            (4, Color(red: 0.98, green: 0.68, blue: 0.18)),
            (5, Color(red: 1.0, green: 0.85, blue: 0.40))
        ]

        return HStack(spacing: 8) {
            ForEach(options, id: \.id) { opt in
                let isCurrent = selectedMood == opt.id
                Button {
                    recordMood(opt.id)
                } label: {
                    MorphingMoodFace(
                        progress: CGFloat(opt.id),
                        isSelected: isCurrent,
                        colorOverride: opt.color
                    )
                    .frame(width: 32, height: 32)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                            .fill(isCurrent ? opt.color.opacity(0.32) : opt.color.opacity(0.12))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                            .strokeBorder(opt.color.opacity(isCurrent ? 0.95 : 0.30), lineWidth: isCurrent ? 2 : 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }


    // MARK: - Savings Card

    private var savingsCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "banknote.fill")
                .font(.title2)
                .foregroundStyle(Design.Colors.signalGreen)

            VStack(alignment: .leading, spacing: 2) {
                Text(dailySpend, format: .currency(code: AppPreferences.shared.currencyCode))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.white)
                Text("Money saved on this day".loc)
                    .font(.caption2)
                    .foregroundStyle(Design.Colors.textSecondary)
            }

            Spacer()

            Text("Saved".loc)
                .font(.caption2.bold())
                .foregroundStyle(Design.Colors.signalGreen)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Design.Colors.signalGreen.opacity(0.16))
                .clipShape(Capsule())
        }
        .padding(Design.Spacing.md)
        .liquidGlass(cornerRadius: Design.Radius.card)
    }

    // MARK: - Mindful Insight Card

    private var mindfulInsightCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .foregroundStyle(Design.Colors.gold)
            Text(isClean ? "Every gambling-free day builds stronger neural pathways of self-control.".loc : "Be gentle with yourself. Growth includes learning from setbacks.".loc)
                .font(.caption)
                .foregroundStyle(Color.white.opacity(0.85))
                .lineSpacing(2)
        }
        .padding(Design.Spacing.md)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous))
    }

    // MARK: - Retroactive Record Action

    private func recordMood(_ mood: Int) {
        if let existing = entry {
            existing.mood = mood
        } else {
            let newEntry = JournalEntry(
                date: date,
                text: "",
                mood: mood,
                gratitude: "",
                hadCravings: !cravings.isEmpty,
                wasRelapse: false
            )
            modelContext.insert(newEntry)
            self.entry = newEntry
        }
        try? modelContext.save()
        SensoryFeedbackService.shared.selectionClick()
        withAnimation(Design.Anim.spring) {
            isChangingMood = false
        }
    }
}

// MARK: - Mood Metadata Helpers

@MainActor
private func moodTitle(for mood: Int) -> String {
    switch mood {
    case 5: return "Strong & Free".loc
    case 4: return "Confident".loc
    case 3: return "Steady & Calm".loc
    case 2: return "Tense".loc
    case 1: return "Overwhelmed".loc
    default: return "Steady & Calm".loc
    }
}

@MainActor
private func moodShortLabel(for mood: Int) -> String {
    switch mood {
    case 5: return "Strong"
    case 4: return "Confident"
    case 3: return "Steady"
    case 2: return "Tense"
    case 1: return "Overwhelmed"
    default: return ""
    }
}

@MainActor
private func moodIcon(for mood: Int) -> String {
    switch mood {
    case 5: return "face.smiling.inverse"
    case 4: return "face.smiling"
    case 3: return "face.smiling"
    case 2: return "face.dashed"
    case 1: return "face.dashed"
    default: return "face.smiling"
    }
}

@MainActor
private func moodColor(for mood: Int) -> Color {
    switch mood {
    case 1: return Color(red: 0.68, green: 0.78, blue: 0.94) // Quiet Twilight Mist
    case 2: return Color(red: 0.95, green: 0.55, blue: 0.42) // Warm Copper / Terracotta
    case 3: return Color(red: 0.78, green: 0.98, blue: 0.20) // Vibrant Zen Lime
    case 4: return Color(red: 0.98, green: 0.68, blue: 0.18) // Signature Amber Gold
    case 5: return Color(red: 1.0, green: 0.85, blue: 0.40)  // Solar Champagne Topaz
    default: return Color(red: 0.78, green: 0.98, blue: 0.20)
    }
}

extension Date: @retroactive Identifiable {
    public var id: TimeInterval { self.timeIntervalSince1970 }
}
