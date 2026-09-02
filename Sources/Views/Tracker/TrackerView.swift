import SwiftUI
import SwiftData

struct TrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \CravingLog.date, order: .reverse) private var logs: [CravingLog]
    @State private var viewModel = TrackerViewModel()
    @State private var showingLogger = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Design.Spacing.xl) {
                    SobrietyCalendarView(viewModel: viewModel, logs: logs)

                    MilestoneBadgesView(daysClean: calculateDaysClean())

                    VStack(alignment: .leading, spacing: Design.Spacing.md) {
                        HStack {
                            Text("Letzte Einträge")
                                .font(.headline)
                                .foregroundStyle(Design.Colors.secondary)
                            Spacer()
                            NavigationLink {
                                AnalyticsView()
                            } label: {
                                Label("Analysen", systemImage: "chart.bar.xaxis")
                                    .font(.subheadline)
                                    .foregroundStyle(Design.Colors.primary)
                            }
                        }

                        if logs.isEmpty {
                            ContentUnavailableView(
                                "Keine Einträge",
                                systemImage: "leaf",
                                description: Text("Hier erscheinen deine protokollierten Erfahrungen.")
                            )
                        } else {
                            ForEach(logs.prefix(5)) { log in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(log.date, format: .dateTime.day().month().year())
                                            .font(.subheadline)
                                            .foregroundStyle(Design.Colors.secondary)
                                        if !log.notes.isEmpty {
                                            Text(log.notes)
                                                .font(.body)
                                                .foregroundStyle(Design.Colors.primary)
                                        }
                                    }
                                    Spacer()
                                    if log.wasRelapse {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundStyle(Design.Colors.sos)
                                    }
                                }
                                .padding()
                                .background(Design.Colors.surface)
                                .clipShape(.rect(cornerRadius: Design.Radius.md))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Design.Colors.background)
            .navigationTitle("Fortschritt")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        AnalyticsView()
                    } label: {
                        Image(systemName: "chart.xyaxis.line")
                            .foregroundStyle(Design.Colors.primary)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingLogger = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Design.Colors.accent)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
            }
            .sheet(isPresented: $showingLogger) {
                CravingLoggerView()
            }
        }
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
