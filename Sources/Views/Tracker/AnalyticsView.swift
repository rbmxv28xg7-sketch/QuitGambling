import SwiftUI
import SwiftData
import Charts

/// Analytics dashboard displaying craving trends, trigger distribution, and mood tracking via Swift Charts.
struct AnalyticsView: View {
    @Query(sort: \CravingLog.date, order: .forward) private var cravingLogs: [CravingLog]
    @Query(sort: \JournalEntry.date, order: .forward) private var journalEntries: [JournalEntry]

    @State private var selectedTimeRange: TimeRange = .twoWeeks

    enum TimeRange: String, CaseIterable, Identifiable {
        case week = "7 Tage"
        case twoWeeks = "14 Tage"
        case month = "30 Tage"

        var id: String { rawValue }

        var days: Int {
            switch self {
            case .week: 7
            case .twoWeeks: 14
            case .month: 30
            }
        }
    }

    private var cutoffDate: Date {
        Calendar.current.date(byAdding: .day, value: -selectedTimeRange.days, to: .now) ?? .now
    }

    private var filteredCravings: [CravingLog] {
        cravingLogs.filter { $0.date >= cutoffDate }
    }

    private var filteredJournals: [JournalEntry] {
        journalEntries.filter { $0.date >= cutoffDate }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Design.Spacing.xl) {
                // Time range picker
                Picker("Zeitraum", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Design.Spacing.xs)

                if cravingLogs.isEmpty && journalEntries.isEmpty {
                    ContentUnavailableView(
                        "Noch keine Statistik-Daten",
                        systemImage: "chart.xyaxis.line",
                        description: Text("Sobald du Tagebucheinträge oder Verlangen protokollierst, siehst du hier deine persönlichen Muster.")
                    )
                    .padding(.top, Design.Spacing.xxl)
                } else {
                    cravingIntensityChartSection
                    triggerDistributionChartSection
                    moodTrendChartSection
                    summaryInsightsCard
                }
            }
            .padding(Design.Spacing.md)
        }
        .navigationTitle("Muster & Analysen")
        .background(Design.Colors.background)
    }

    // MARK: - Craving Intensity Chart

    private var cravingIntensityChartSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Verlangens-Intensität")
                    .font(.headline)
                Text("Skala von 1 (leicht) bis 10 (extrem)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if filteredCravings.isEmpty {
                Text("Kein Verlangen im ausgewählten Zeitraum protokolliert. Sehr gut!")
                    .font(.subheadline)
                    .foregroundStyle(Design.Colors.primary)
                    .padding(.vertical, Design.Spacing.lg)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Chart {
                    ForEach(filteredCravings) { log in
                        LineMark(
                            x: .value("Datum", log.date, unit: .day),
                            y: .value("Intensität", log.intensity)
                        )
                        .foregroundStyle(Design.Colors.accent)
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Datum", log.date, unit: .day),
                            y: .value("Intensität", log.intensity)
                        )
                        .foregroundStyle(log.wasRelapse ? Design.Colors.sos : Design.Colors.accent)
                        .symbolSize(log.wasRelapse ? 60 : 35)

                        AreaMark(
                            x: .value("Datum", log.date, unit: .day),
                            y: .value("Intensität", log.intensity)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Design.Colors.accent.opacity(0.25), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
                .chartYScale(domain: 0...10)
                .chartYAxis {
                    AxisMarks(values: [0, 2, 4, 6, 8, 10])
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: selectedTimeRange == .month ? 5 : 2)) { _ in
                        AxisValueLabel(format: .dateTime.day().month())
                    }
                }
                .frame(height: 200)
            }
        }
        .padding(Design.Spacing.lg)
        .background(Design.Colors.surface)
        .clipShape(.rect(cornerRadius: Design.Radius.lg))
    }

    // MARK: - Trigger Distribution Chart

    private var triggerDistributionChartSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Häufigste Auslöser (Trigger)")
                    .font(.headline)
                Text("Was treibt den Spieldruck an?")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            let counts = triggerCounts
            if counts.isEmpty {
                Text("Keine Trigger erfasst.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, Design.Spacing.md)
            } else {
                Chart(counts, id: \.trigger) { item in
                    BarMark(
                        x: .value("Anzahl", item.count),
                        y: .value("Trigger", item.trigger)
                    )
                    .foregroundStyle(Design.Colors.primary)
                    .cornerRadius(4)
                }
                .frame(height: max(140, CGFloat(counts.count * 32)))
            }
        }
        .padding(Design.Spacing.lg)
        .background(Design.Colors.surface)
        .clipShape(.rect(cornerRadius: Design.Radius.lg))
    }

    // MARK: - Mood Trend Chart

    private var moodTrendChartSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Stimmungsverlauf")
                    .font(.headline)
                Text("1 (😢 Sehr schlecht) bis 5 (😊 Sehr gut)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if filteredJournals.isEmpty {
                Text("Keine Tagebucheinträge im Zeitraum.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, Design.Spacing.md)
            } else {
                Chart {
                    ForEach(filteredJournals) { entry in
                        LineMark(
                            x: .value("Tag", entry.date, unit: .day),
                            y: .value("Stimmung", entry.mood)
                        )
                        .foregroundStyle(Design.Colors.secondary)
                        .interpolationMethod(.monotone)

                        PointMark(
                            x: .value("Tag", entry.date, unit: .day),
                            y: .value("Stimmung", entry.mood)
                        )
                        .foregroundStyle(Design.Colors.secondary)
                        .symbolSize(30)
                    }
                }
                .chartYScale(domain: 1...5)
                .chartYAxis {
                    AxisMarks(values: [1, 2, 3, 4, 5]) { val in
                        if let intVal = val.as(Int.self), let mood = Design.Mood(rawValue: intVal) {
                            AxisValueLabel {
                                Text(mood.emoji)
                            }
                        }
                    }
                }
                .frame(height: 160)
            }
        }
        .padding(Design.Spacing.lg)
        .background(Design.Colors.surface)
        .clipShape(.rect(cornerRadius: Design.Radius.lg))
    }

    // MARK: - Summary Insights

    private var summaryInsightsCard: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            Label("Wichtigste Erkenntnisse", systemImage: "sparkles")
                .font(.headline)
                .foregroundStyle(Design.Colors.gold)

            let totalCravingCount = filteredCravings.count
            let avgIntensity = filteredCravings.isEmpty ? 0 : Double(filteredCravings.reduce(0) { $0 + $1.intensity }) / Double(totalCravingCount)

            Text("• **Ereignisse:** In den letzten \(selectedTimeRange.rawValue) hast du \(totalCravingCount) Verlangensphasen erfolgreich überstanden.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if avgIntensity > 0 {
                Text("• **Durchschnittliche Intensität:** \(avgIntensity, format: .number.precision(.fractionLength(1))) von 10.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let topTrigger = triggerCounts.first {
                Text("• **Haupttrigger:** Am häufigsten trat Verlangen durch **\(topTrigger.trigger)** auf.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(Design.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Design.Colors.surface)
        .clipShape(.rect(cornerRadius: Design.Radius.lg))
    }

    // MARK: - Helpers

    private var triggerCounts: [(trigger: String, count: Int)] {
        var map: [String: Int] = [:]
        for log in filteredCravings {
            let key = log.trigger.isEmpty ? "Nicht angegeben" : log.trigger
            map[key, default: 0] += 1
        }
        return map.map { (trigger: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
}

#Preview {
    NavigationStack {
        AnalyticsView()
    }
    .modelContainer(for: [CravingLog.self, JournalEntry.self], inMemory: true)
}
