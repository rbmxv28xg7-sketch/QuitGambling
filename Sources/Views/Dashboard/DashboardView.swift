import SwiftUI
import SwiftData

/// Pure Apple Craftsmanship Dashboard.
/// True OLED black, massive monolithic typography, solid tactile controls, zero Dribbble clichés.
struct DashboardView: View {
    @Binding var selectedTab: AppTab
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = DashboardViewModel()
    @State private var showingSavingsEquivalents = false
    @State private var showingLogger = false

    init(selectedTab: Binding<AppTab> = .constant(.home)) {
        self._selectedTab = selectedTab
    }

    @Query private var profiles: [UserProfile]
    @Query private var preventedEntries: [PreventedLossEntry]
    @Query private var cravingLogs: [CravingLog]
    @Query private var journalEntries: [JournalEntry]
    @Query private var assessmentResults: [SelfAssessmentResult]

    private var freedomScoreData: (score: Int, grade: String, summary: String) {
        FreedomScoreCalculator.calculateScore(
            daysClean: viewModel.daysClean,
            hasPledgedToday: viewModel.hasPledgedToday,
            cravingLogs: cravingLogs,
            journalEntries: journalEntries,
            selfAssessmentResults: assessmentResults
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FlutedGlassBackgroundView()

                // Continuous Natural ScrollView
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Design.Spacing.xl) {
                        // Top Date (Pure, quiet typography)
                        topDateHeader

                        // The Monolithic Streak Hero
                        ZenCounterDialView(
                            viewModel: viewModel,
                            score: freedomScoreData.score,
                            grade: freedomScoreData.grade
                        )


                        // Tactile Mechanical Daily Pledge Control
                        DailyPledgeView(
                            hasPledgedToday: viewModel.hasPledgedToday,
                            onPledge: {
                                viewModel.confirmPledge(context: modelContext)
                            }
                        )

                        // 15-Second Daily Check-in & Micro-Reflection
                        DailyCheckInCardView()

                        // 2 Solid Metric Pods
                        HStack(spacing: Design.Spacing.md) {
                            Button {
                                SensoryFeedbackService.shared.cardTap()
                                showingSavingsEquivalents = true
                            } label: {
                                SavingsMetricCard(moneySaved: viewModel.moneySaved)
                            }
                            .buttonStyle(.plain)

                            Button {
                                SensoryFeedbackService.shared.selectionClick()
                                withAnimation(Design.Anim.spring) {
                                    selectedTab = .tracker
                                }
                            } label: {
                                MilestoneMetricCard(viewModel: viewModel)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, Design.Spacing.lg)
                    .padding(.bottom, 96)
                }
            }
            .sheet(isPresented: $showingSavingsEquivalents) {
                SavingsEquivalentsSheet(moneySaved: viewModel.moneySaved)
                    .scrollIndicators(.hidden)
            }
            .sheet(isPresented: $showingLogger) {
                CravingLoggerView()
                    .scrollIndicators(.hidden)
            }
            .scrollIndicators(.hidden)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        SensoryFeedbackService.shared.buttonTap()
                        showingLogger = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Design.Colors.accent)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
            }
            .task {
                viewModel.loadProfile(context: modelContext)
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(1))
                    viewModel.updateTimer()
                }
            }
            .onChange(of: preventedEntries.count) { _, _ in
                viewModel.loadProfile(context: modelContext)
            }
            .onChange(of: profiles.first?.dailyGamblingSpend) { _, _ in
                viewModel.loadProfile(context: modelContext)
            }
            .onChange(of: profiles.first?.sobrietyStartDate) { _, _ in
                viewModel.loadProfile(context: modelContext)
            }
            .onChange(of: profiles.first?.pledgedToday) { _, _ in
                viewModel.loadProfile(context: modelContext)
            }
            .onChange(of: cravingLogs.count) { _, _ in
                viewModel.loadProfile(context: modelContext)
            }
            .onChange(of: journalEntries.count) { _, _ in
                viewModel.loadProfile(context: modelContext)
            }
        }
        .scrollIndicators(.hidden)
        .preferredColorScheme(.dark)
    }

    // MARK: - Discrete Top Date

    private var topDateHeader: some View {
        let dateString = Date.now.formatted(
            .dateTime.weekday(.wide).day().month(.wide).locale(Locale(identifier: AppPreferences.shared.languageCode))
        )

        return HStack(spacing: 6) {
            Circle()
                .fill(Design.Colors.amberGold)
                .frame(width: 6, height: 6)
                .shadow(color: Design.Colors.amberGold.opacity(0.8), radius: 4)

            Text(dateString.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(2.5)
                .foregroundStyle(Design.Colors.textSecondary)

            Spacer()
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [UserProfile.self, CravingLog.self, JournalEntry.self, SelfAssessmentResult.self], inMemory: true)
}
