import SwiftUI
import SwiftData

struct TrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Query private var profiles: [UserProfile]
    @Query(sort: \CravingLog.date, order: .reverse) private var logs: [CravingLog]
    @State private var viewModel = TrackerViewModel()
    @State private var showingLogger = false

    var body: some View {
        NavigationStack {
            ZStack {
                FlutedGlassBackgroundView()

                ScrollView(showsIndicators: false) {
                VStack(spacing: Design.Spacing.xl) {
                    SobrietyCalendarView(viewModel: viewModel, logs: logs)

                    MilestoneBadgesView(daysClean: calculateDaysClean())

                    VStack(alignment: .leading, spacing: Design.Spacing.md) {
                        HStack {
                            Text("Recent Logs".loc)
                                .font(.headline)
                                .foregroundStyle(Color.white)
                                .shadow(color: Color.black.opacity(0.35), radius: 1.5, y: 1)
                            Spacer()
                            NavigationLink {
                                AnalyticsView()
                            } label: {
                                HStack(spacing: 5) {
                                    Label("Analytics".loc, systemImage: "chart.bar.xaxis")
                                    if !subscriptionManager.isPro {
                                        ProBadge(isCompact: true)
                                    }
                                }
                                .font(.subheadline)
                                .foregroundStyle(Design.Colors.primary)
                            }
                        }

                        if logs.isEmpty {
                            ContentUnavailableView(
                                "No Logs Yet".loc,
                                systemImage: "leaf",
                                description: Text("Your logged cravings and reflections will appear here.".loc)
                            )
                        } else {
                            ForEach(logs.prefix(5)) { log in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(log.date, format: .dateTime.day().month().year())
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(Color.white.opacity(0.88))
                                            .shadow(color: Color.black.opacity(0.35), radius: 1.5, y: 1)
                                        if !log.notes.isEmpty {
                                            Text(log.notes)
                                                .font(.body)
                                                .foregroundStyle(Color.white)
                                                .shadow(color: Color.black.opacity(0.35), radius: 1.5, y: 1)
                                        }
                                        if !log.trigger.isEmpty {
                                            Text(log.trigger)
                                                .font(.caption2)
                                                .foregroundStyle(Design.Colors.textSecondary)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
                                                .background(Color.white.opacity(0.08))
                                                .clipShape(Capsule())
                                        }
                                    }
                                    Spacer()
                                    if log.wasRelapse {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundStyle(Design.Colors.sos)
                                    }
                                }
                                .sereneCardStyle(padding: Design.Spacing.md)
                                .contentShape(Rectangle())
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, Design.Spacing.md)
                .padding(.bottom, 96)
            }
        }
        .navigationTitle("Progress".loc)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        AnalyticsView()
                    } label: {
                        Image(systemName: "chart.xyaxis.line")
                            .foregroundStyle(Design.Colors.primary)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
            }
            .sheet(isPresented: $showingLogger) {
                CravingLoggerView()
                    .scrollIndicators(.hidden)
            }
            .scrollIndicators(.hidden)
        }
        .scrollIndicators(.hidden)
    }

    private func calculateDaysClean() -> Int {
        guard let profile = profiles.first else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: profile.sobrietyStartDate, to: .now).day ?? 0
        return max(0, days)
    }
}

#Preview {
    TrackerView()
        .modelContainer(for: [CravingLog.self, UserProfile.self], inMemory: true)
}
