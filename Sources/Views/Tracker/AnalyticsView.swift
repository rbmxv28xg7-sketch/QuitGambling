import SwiftUI
import SwiftData
import Charts

/// Analytics dashboard displaying craving trends, trigger distribution, and mood tracking via Swift Charts.
struct AnalyticsView: View {
    @Query(sort: \CravingLog.date, order: .forward) private var cravingLogs: [CravingLog]
    @Query(sort: \JournalEntry.date, order: .forward) private var journalEntries: [JournalEntry]

    @State private var selectedTimeRange: TimeRange = .twoWeeks

    enum TimeRange: String, CaseIterable, Identifiable {
        case week = "7 Days"
        case twoWeeks = "14 Days"
        case month = "30 Days"

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

    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var showingPaywall = false

    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: Design.Spacing.xl) {
                    // Time range picker
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, Design.Spacing.xs)

                    if cravingLogs.isEmpty && journalEntries.isEmpty {
                        ContentUnavailableView(
                            "No Analytics Data Yet",
                            systemImage: "chart.xyaxis.line",
                            description: Text("As soon as you log journal entries or urges, your personal patterns will appear here.")
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
                .padding(.bottom, 96)
                .blur(radius: subscriptionManager.isPro ? 0 : 8)
                .allowsHitTesting(subscriptionManager.isPro)
            }

            if !subscriptionManager.isPro {
                VStack(spacing: Design.Spacing.md) {
                    ProBadge()

                    Text("Urge & Trigger Analytics")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.white)

                    Text("Gain deep clinical clarity into your craving peaks, psychological triggers, and mood dynamics over time.")
                        .font(.caption)
                        .foregroundStyle(Design.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .padding(.horizontal, Design.Spacing.sm)

                    Button {
                        showingPaywall = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "crown.fill")
                            Text("Unlock Analytics with Pro")
                        }
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Design.Colors.goldGradient)
                        .clipShape(Capsule())
                        .shadow(color: Design.Colors.gold.opacity(0.35), radius: 8, y: 3)
                    }
                    .padding(.top, 4)
                }
                .padding(Design.Spacing.lg)
                .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.lg)
                .padding(.horizontal, Design.Spacing.lg)
                .transition(.opacity)
            }
        }
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
        .navigationTitle("Patterns & Analytics")
        .onAppear {
            SensoryFeedbackService.shared.selectionClick()
        }
        .onChange(of: selectedTimeRange) { _, _ in
            SensoryFeedbackService.shared.selectionClick()
        }
    }

    // MARK: - Craving Intensity Chart

    private var cravingIntensityChartSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Urge Intensity")
                    .font(.headline)
                    .foregroundStyle(Design.Colors.ivory)
                Text("Scale from 1 (mild) to 10 (extreme)")
                    .font(.caption)
                    .foregroundStyle(Design.Colors.textSecondary)
            }

            if filteredCravings.isEmpty {
                Text("No urges logged during the selected period. Excellent job!")
                    .font(.subheadline)
                    .foregroundStyle(Design.Colors.primary)
                    .padding(.vertical, Design.Spacing.lg)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Chart {
                    ForEach(filteredCravings) { log in
                        LineMark(
                            x: .value("Date", log.date, unit: .day),
                            y: .value("Intensity", log.intensity)
                        )
                        .foregroundStyle(Design.Colors.accent)
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Date", log.date, unit: .day),
                            y: .value("Intensity", log.intensity)
                        )
                        .foregroundStyle(log.wasRelapse ? Design.Colors.sos : Design.Colors.accent)
                        .symbolSize(log.wasRelapse ? 60 : 35)

                        AreaMark(
                            x: .value("Date", log.date, unit: .day),
                            y: .value("Intensity", log.intensity)
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
        .sereneCardStyle(padding: Design.Spacing.lg)
    }

    // MARK: - Trigger Distribution Chart

    private var triggerDistributionChartSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Top Triggers")
                    .font(.headline)
                    .foregroundStyle(Design.Colors.ivory)
                Text("What activates gambling pressure?")
                    .font(.caption)
                    .foregroundStyle(Design.Colors.textSecondary)
            }

            let counts = triggerCounts
            if counts.isEmpty {
                Text("No triggers recorded.")
                    .font(.subheadline)
                    .foregroundStyle(Design.Colors.textSecondary)
                    .padding(.vertical, Design.Spacing.md)
            } else {
                Chart(counts, id: \.trigger) { item in
                    BarMark(
                        x: .value("Count", item.count),
                        y: .value("Trigger", item.trigger)
                    )
                    .foregroundStyle(Design.Colors.primary)
                    .cornerRadius(4)
                }
                .frame(height: max(140, CGFloat(counts.count * 32)))
            }
        }
        .sereneCardStyle(padding: Design.Spacing.lg)
    }

    // MARK: - Mood Trend Chart

    private var moodTrendChartSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Mood Trends")
                    .font(.headline)
                    .foregroundStyle(Design.Colors.ivory)
                Text("Scale from 1 (overwhelmed) to 5 (strong)")
                    .font(.caption)
                    .foregroundStyle(Design.Colors.textSecondary)
            }

            if filteredJournals.isEmpty {
                Text("No journal entries in this period.")
                    .font(.subheadline)
                    .foregroundStyle(Design.Colors.textSecondary)
                    .padding(.vertical, Design.Spacing.md)
            } else {
                Chart {
                    ForEach(filteredJournals) { entry in
                        LineMark(
                            x: .value("Day", entry.date, unit: .day),
                            y: .value("Mood", entry.mood)
                        )
                        .foregroundStyle(Design.Colors.secondary)
                        .interpolationMethod(.monotone)

                        PointMark(
                            x: .value("Day", entry.date, unit: .day),
                            y: .value("Mood", entry.mood)
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
                                Text("\(intVal)")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(mood.color)
                            }
                        }
                    }
                }
                .frame(height: 160)
            }
        }
        .sereneCardStyle(padding: Design.Spacing.lg)
    }

    // MARK: - Summary Insights

    private var summaryInsightsCard: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            Label("Key Insights", systemImage: "sparkles")
                .font(.headline)
                .foregroundStyle(Design.Colors.gold)

            let totalCravingCount = filteredCravings.count
            let avgIntensity = filteredCravings.isEmpty ? 0 : Double(filteredCravings.reduce(0) { $0 + $1.intensity }) / Double(totalCravingCount)

            Text("• **Events:** In the last \(selectedTimeRange.rawValue), you successfully overcame \(totalCravingCount) urge moments.")
                .font(.subheadline)
                .foregroundStyle(Design.Colors.textSecondary)

            if avgIntensity > 0 {
                Text("• **Average Intensity:** \(avgIntensity, format: .number.precision(.fractionLength(1))) of 10.")
                    .font(.subheadline)
                    .foregroundStyle(Design.Colors.textSecondary)
            }

            if let topTrigger = triggerCounts.first {
                Text("• **Primary Trigger:** Urges occurred most frequently from **\(topTrigger.trigger)**.")
                    .font(.subheadline)
                    .foregroundStyle(Design.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .sereneCardStyle(padding: Design.Spacing.lg)
    }

    // MARK: - Helpers

    private var triggerCounts: [(trigger: String, count: Int)] {
        var map: [String: Int] = [:]
        for log in filteredCravings {
            let key = log.trigger.isEmpty ? "Unspecified" : log.trigger
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
