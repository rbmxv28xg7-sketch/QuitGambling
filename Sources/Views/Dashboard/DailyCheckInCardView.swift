import SwiftUI
import SwiftData

/// Liquid Glass Dashboard Card displaying today's reflection status and 7-day honesty streak.
struct DailyCheckInCardView: View {
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    @State private var showingSheet = false

    private var todayEntry: JournalEntry? {
        let calendar = Calendar.current
        return entries.first(where: { calendar.isDateInToday($0.date) })
    }

    private func moodColor(for mood: Int) -> Color {
        switch mood {
        case 1: return Color(red: 0.68, green: 0.78, blue: 0.94)
        case 2: return Color(red: 0.95, green: 0.55, blue: 0.42)
        case 3: return Color(red: 0.78, green: 0.98, blue: 0.20)
        case 4: return Color(red: 0.98, green: 0.68, blue: 0.18)
        case 5: return Color(red: 1.0, green: 0.85, blue: 0.40)
        default: return Color(red: 0.78, green: 0.98, blue: 0.20)
        }
    }

    private func moodTitle(for mood: Int) -> String {
        switch mood {
        case 1: return "Overwhelmed".loc
        case 2: return "Anxious".loc
        case 3: return "Stable & Calm".loc
        case 4: return "Optimistic".loc
        case 5: return "Strong & Free".loc
        default: return "Good".loc
        }
    }

    var body: some View {
        Button {
            SensoryFeedbackService.shared.cardTap()
            showingSheet = true
        } label: {
            VStack(alignment: .leading, spacing: Design.Spacing.md) {
                if let entry = todayEntry {
                    completedView(entry: entry)
                } else {
                    uncompletedView
                }

                // 7-Day Reflection Strip (Week overview)
                weekReflectionStrip
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.md)
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $showingSheet) {
            DailyMorningCheckinView()
                .scrollIndicators(.hidden)
        }
    }

    // MARK: - Uncompleted State (Inviting CTA)

    private var uncompletedView: some View {
        HStack(spacing: Design.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Design.Colors.amberGold.opacity(0.18))
                    .frame(width: 44, height: 44)
                Image(systemName: "pencil.and.scribble")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Design.Colors.amberGold)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("DAILY REFLECTION".loc)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(Design.Colors.amberGold)

                    Text("• 15 SECONDS".loc)
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(Design.Colors.textSecondary)
                }

                Text("How are you feeling today?".loc)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)

                Text("Tap to check in honestly today.".loc)
                    .font(.caption2)
                    .foregroundStyle(Design.Colors.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Design.Colors.textSecondary)
        }
    }

    // MARK: - Completed State (Pride & Reflection)

    private func completedView(entry: JournalEntry) -> some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Design.Colors.amberGold)

                    Text("REFLECTED TODAY".loc)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(Design.Colors.amberGold)
                }

                Spacer()

                Text("Tap to edit".loc)
                    .font(.caption2)
                    .foregroundStyle(Design.Colors.textTertiary)
            }

            HStack(spacing: 8) {
                // Mood Badge
                let mColor = moodColor(for: entry.mood)
                HStack(spacing: 5) {
                    MorphingMoodFace(
                        progress: CGFloat(entry.mood),
                        isSelected: true,
                        colorOverride: mColor
                    )
                    .frame(width: 14, height: 14)

                    Text(moodTitle(for: entry.mood))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(mColor.opacity(0.18))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(mColor.opacity(0.40), lineWidth: 1)
                )
                .foregroundStyle(Color.white)

                // Status Badge
                HStack(spacing: 4) {
                    Image(systemName: entry.wasRelapse ? "exclamationmark.triangle.fill" : "shield.fill")
                        .font(.caption2)
                    Text(entry.wasRelapse ? "Relapse".loc : "Gamble-Free".loc)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(entry.wasRelapse ? Design.Colors.signalRed.opacity(0.20) : Design.Colors.amberGold.opacity(0.20))
                .foregroundStyle(entry.wasRelapse ? Design.Colors.signalRed : Design.Colors.amberGold)
                .clipShape(Capsule())

                // Tag if available
                if !entry.tag.isEmpty {
                    Text(entry.tag)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.06))
                        .clipShape(Capsule())
                        .foregroundStyle(Design.Colors.textSecondary)
                }
            }

            // Thought quote if user wrote one
            if !entry.text.isEmpty {
                Text("„\(entry.text)“")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .italic()
                    .foregroundStyle(Color.white.opacity(0.90))
                    .lineLimit(2)
                    .padding(.top, 2)
            }
        }
    }

    // MARK: - 7-Day Week Strip

    private var weekReflectionStrip: some View {
        let calendar = Calendar.current
        let today = Date.now
        // Calculate the last 7 days ending with today
        let days: [Date] = (-6...0).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }

        return HStack(spacing: 6) {
            ForEach(days, id: \.self) { date in
                let isToday = calendar.isDateInToday(date)
                let entryForDate = entries.first(where: { calendar.isDate($0.date, inSameDayAs: date) })
                let weekdayLetter = date.formatted(.dateTime.weekday(.narrow).locale(Locale(identifier: AppPreferences.shared.languageCode)))

                VStack(spacing: 4) {
                    Text(weekdayLetter)
                        .font(.system(size: 10, weight: isToday ? .bold : .medium, design: .rounded))
                        .foregroundStyle(isToday ? Design.Colors.amberGold : Design.Colors.textSecondary)

                    ZStack {
                        Circle()
                            .fill(entryForDate != nil ? (entryForDate!.wasRelapse ? Design.Colors.signalRed.opacity(0.85) : Design.Colors.primary) : Color.white.opacity(0.08))
                            .frame(width: 20, height: 20)

                        if let entry = entryForDate {
                            Image(systemName: entry.wasRelapse ? "xmark" : "checkmark")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(entry.wasRelapse ? Color.white : Design.Colors.textOnPrimary)
                        } else if isToday {
                            Circle()
                                .strokeBorder(Design.Colors.primary, lineWidth: 1)
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 4)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        DailyCheckInCardView()
            .modelContainer(for: JournalEntry.self, inMemory: true)
            .padding()
    }
}
