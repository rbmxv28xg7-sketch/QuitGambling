import SwiftUI
import SwiftData

/// Dedicated clinical consultation view designed for presenting verified sobriety,
/// relapse history, financial impact, and craving analytics to healthcare professionals.
struct ClinicalReportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionManager.self) private var subscriptionManager

    @Query private var profiles: [UserProfile]
    @Query(sort: \CravingLog.date, order: .reverse) private var cravingLogs: [CravingLog]
    @Query(sort: \PreventedLossEntry.date, order: .reverse) private var preventedLosses: [PreventedLossEntry]
    @Query(sort: \SelfAssessmentResult.date, order: .reverse) private var assessmentResults: [SelfAssessmentResult]
    @Query(sort: \JournalEntry.date, order: .reverse) private var journalEntries: [JournalEntry]
    @Query private var savingsGoals: [SavingsGoal]

    @State private var copiedConfirmation = false
    @State private var showingPaywall = false
    private var prefs = AppPreferences.shared

    private var profile: UserProfile? { profiles.first }

    private var relapses: [CravingLog] {
        cravingLogs.filter { $0.wasRelapse }
    }

    private var resistedCravings: [CravingLog] {
        cravingLogs.filter { !$0.wasRelapse }
    }

    private var totalSecondsClean: Int {
        guard let startDate = profile?.sobrietyStartDate else { return 0 }
        return max(0, Int(Date.now.timeIntervalSince(startDate)))
    }

    private var daysClean: Int {
        totalSecondsClean / 86400
    }

    private var hoursClean: Int {
        (totalSecondsClean % 86400) / 3600
    }

    private var baselineSavings: Double {
        let dailySpend = profile?.dailyGamblingSpend ?? 0
        return (Double(daysClean) * dailySpend) + (Double(totalSecondsClean % 86400) / 86400.0 * dailySpend)
    }

    private var acuteLossesTotal: Double {
        preventedLosses.reduce(0.0) { $0 + $1.amount }
    }

    private var netPreservedCapital: Double {
        baselineSavings + acuteLossesTotal
    }

    private var avgCravingIntensity: Double {
        guard !cravingLogs.isEmpty else { return 0 }
        return Double(cravingLogs.reduce(0) { $0 + $1.intensity }) / Double(cravingLogs.count)
    }

    private var latestAssessment: SelfAssessmentResult? {
        assessmentResults.first
    }

    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: Design.Spacing.lg) {
                    headerCard
                    vitalsMetricsGrid
                    relapseAuditSection
                    financialAuditSection
                    urgeDynamicsSection
                    screeningSection
                    exportActionsSection
                }
                .padding(.horizontal)
                .padding(.top, Design.Spacing.md)
                .padding(.bottom, 96)
            }
        }
        .navigationTitle("Clinical Report".loc)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    shareReport()
                } label: {
                    Label("Share".loc, systemImage: "square.and.arrow.up")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Design.Colors.primary)
                }
            }
        }
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
        .overlay(alignment: .bottom) {
            if copiedConfirmation {
                Text("Report copied to clipboard".loc)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.85))
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.2), lineWidth: 0.8))
                    .padding(.bottom, 30)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "cross.case.fill")
                    .font(.title3)
                    .foregroundStyle(Design.Colors.primary)
                Text("Confidential Recovery Report".loc)
                    .font(.headline)
                    .foregroundStyle(Design.Colors.textPrimary)
                Spacer()
                Text("CONFIDENTIAL".loc)
                    .font(.system(size: 9, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Design.Colors.primary.opacity(0.2))
                    .clipShape(Capsule())
                    .foregroundStyle(Design.Colors.primary)
            }

            Text("This clinical summary consolidates your verified sobriety timeline, relapse timestamps, financial preservation, and craving triggers. You can present this directly to a doctor, psychologist, or addiction counselor.".loc)
                .font(.caption)
                .foregroundStyle(Design.Colors.textSecondary)
                .lineSpacing(2)

            Divider().background(Color.white.opacity(0.12))

            HStack {
                Text("Report Date:".loc)
                    .font(.caption2)
                    .foregroundStyle(Design.Colors.textTertiary)
                Text(Date.now, style: .date)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Design.Colors.textSecondary)
                Spacer()
                Text("Loc: \(prefs.languageCode.uppercased()) • \(prefs.currencyCode) • \(prefs.regionCode)")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Design.Colors.textTertiary)
            }
        }
        .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.lg)
    }

    // MARK: - Core Metrics Grid

    private var vitalsMetricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            metricTile(
                title: "Gamble-Free Duration".loc,
                value: "\(daysClean)d \(hoursClean)h",
                subtitle: "Sobriety Timeline".loc,
                icon: "checkmark.shield.fill",
                accentColor: Design.Colors.primary
            )

            metricTile(
                title: "Relapse Count".loc,
                value: "\(relapses.count)",
                subtitle: (relapses.isEmpty ? "Continuous Remission" : "Recorded Lapses").loc,
                icon: relapses.isEmpty ? "heart.circle.fill" : "exclamationmark.triangle.fill",
                accentColor: relapses.isEmpty ? Design.Colors.primary : Design.Colors.sos
            )

            metricTile(
                title: "Capital Preserved".loc,
                value: prefs.formatCurrency(netPreservedCapital),
                subtitle: "Savings & Interventions".loc,
                icon: "banknote.fill",
                accentColor: Design.Colors.gold
            )

            metricTile(
                title: "Clinical PGSI".loc,
                value: latestAssessment != nil ? "\(latestAssessment!.score) / 27" : "N/A",
                subtitle: (latestAssessment?.riskCategory ?? "Not Screened").loc,
                icon: "chart.bar.doc.horizontal.fill",
                accentColor: Color.blue
            )
        }
    }

    private func metricTile(title: String, value: String, subtitle: String, icon: String, accentColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.16))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(accentColor)
                }
                Spacer()
            }
            .padding(.bottom, 8)

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Design.Colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.bottom, 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Design.Colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(Design.Colors.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 126, maxHeight: 126, alignment: .topLeading)
        .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.md)
    }

    // MARK: - Relapse Audit Section

    private var relapseAuditSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            HStack {
                Label("Relapse & Lapse Audit".loc, systemImage: "clock.arrow.circlepath")
                    .font(.headline)
                    .foregroundStyle(Design.Colors.textPrimary)
                Spacer()
                Text(String(format: "%d Total".loc, relapses.count))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(relapses.isEmpty ? Design.Colors.primary : Design.Colors.sos)
            }

            if relapses.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title2)
                        .foregroundStyle(Design.Colors.primary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Zero Relapses Recorded".loc)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Design.Colors.textPrimary)
                        Text("Patient has maintained continuous abstinence with no lapses logged since start.".loc)
                            .font(.caption2)
                            .foregroundStyle(Design.Colors.textSecondary)
                    }
                }
                .padding(.vertical, 4)
            } else {
                VStack(spacing: 10) {
                    ForEach(relapses) { relapse in
                        relapseCard(relapse)
                    }
                }
            }
        }
        .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.lg)
    }

    private func relapseCard(_ relapse: CravingLog) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(relapse.date, style: .date)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Design.Colors.textPrimary)
                Text(relapse.date, style: .time)
                    .font(.caption2)
                    .foregroundStyle(Design.Colors.textTertiary)
                Spacer()
                Text(String(format: "Intensity: %d/10".loc, relapse.intensity))
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Design.Colors.sos.opacity(0.18))
                    .clipShape(Capsule())
                    .foregroundStyle(Design.Colors.sos)
            }

            if !relapse.trigger.isEmpty {
                HStack(spacing: 4) {
                    Text("Trigger:".loc)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Design.Colors.textTertiary)
                    Text(relapse.trigger)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Design.Colors.textSecondary)
                }
            }

            if !relapse.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("\"\(relapse.notes.trimmingCharacters(in: .whitespacesAndNewlines))\"")
                    .font(.caption)
                    .italic()
                    .foregroundStyle(Design.Colors.textSecondary)
                    .padding(.leading, 6)
                    .overlay(
                        Rectangle()
                            .fill(Design.Colors.sos.opacity(0.6))
                            .frame(width: 2),
                        alignment: .leading
                    )
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    // MARK: - Financial Audit Section

    private var financialAuditSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            Label("Financial Impact & Preservation".loc, systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)
                .foregroundStyle(Design.Colors.textPrimary)

            VStack(spacing: 8) {
                if let prof = profile {
                    detailRow(title: "Historical Gambling Pattern".loc, value: prof.spendPattern.title)
                    detailRow(title: "Pre-Recovery Spend Rate".loc, value: "\(prefs.formatCurrencyPrecise(prof.estimatedBaseAmount)) / \(prof.spendPattern.shortTitle.lowercased())")
                    detailRow(title: "Computed Daily Baseline".loc, value: "\(prefs.formatCurrencyPrecise(prof.dailyGamblingSpend)) / day")
                }
                detailRow(title: "Baseline Saved (Clean Duration)".loc, value: prefs.formatCurrencyPrecise(baselineSavings))
                detailRow(title: "Acute SOS Losses Prevented".loc, value: "\(prefs.formatCurrencyPrecise(acuteLossesTotal)) (\(preventedLosses.count))")
                Divider().background(Color.white.opacity(0.12))
                detailRow(
                    title: "Total Preserved Capital".loc,
                    value: prefs.formatCurrencyPrecise(netPreservedCapital),
                    highlight: true
                )
            }

            if !preventedLosses.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Recent Acute Loss Interventions:".loc)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Design.Colors.textTertiary)

                    ForEach(preventedLosses.prefix(3)) { item in
                        HStack {
                            Text(item.date, style: .date)
                                .font(.caption2)
                                .foregroundStyle(Design.Colors.textSecondary)
                            if !item.note.isEmpty {
                                Text("• \(item.note)")
                                    .font(.caption2)
                                    .foregroundStyle(Design.Colors.textTertiary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Text("+\(prefs.formatCurrencyPrecise(item.amount))")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Design.Colors.gold)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.lg)
    }

    // MARK: - Urge Dynamics Section

    private var urgeDynamicsSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            Label("Craving & Urge Dynamics".loc, systemImage: "waveform.path.ecg")
                .font(.headline)
                .foregroundStyle(Design.Colors.textPrimary)

            VStack(spacing: 8) {
                detailRow(title: "Total Logged Craving Episodes".loc, value: "\(cravingLogs.count)")
                detailRow(title: "Urges Resisted Without Gambling".loc, value: "\(resistedCravings.count)")
                detailRow(title: "Average Urge Intensity".loc, value: String(format: "%.1f / 10", avgCravingIntensity))
            }
        }
        .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.lg)
    }

    // MARK: - Screening Section (PGSI)

    private var screeningSection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            HStack {
                Label("Diagnostic Screening (PGSI)".loc, systemImage: "doc.badge.ellipsis")
                    .font(.headline)
                    .foregroundStyle(Design.Colors.textPrimary)
                Spacer()
                if let assessment = latestAssessment {
                    Text(assessment.date, style: .date)
                        .font(.caption2)
                        .foregroundStyle(Design.Colors.textTertiary)
                }
            }

            if let assessment = latestAssessment {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(format: "Severity Score: %d / 27".loc, assessment.score))
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Design.Colors.textPrimary)
                            Text(String(format: "Classification: %@".loc, assessment.riskCategory.loc))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Design.Colors.gold)
                        }
                        Spacer()
                    }

                    Text(assessment.recommendation)
                        .font(.caption2)
                        .foregroundStyle(Design.Colors.textSecondary)
                        .lineSpacing(2)
                }
            } else {
                Text("No Problem Gambling Severity Index (PGSI) screening recorded yet. You can complete one anytime in Resources.".loc)
                    .font(.caption)
                    .foregroundStyle(Design.Colors.textSecondary)
            }
        }
        .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.lg)
    }

    // MARK: - Export Actions Section

    private var exportActionsSection: some View {
        VStack(spacing: 12) {
            Button {
                shareReport()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export Report for Doctor".loc)
                    if !subscriptionManager.isPro {
                        ProBadge(isCompact: true)
                    }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Design.Colors.primary)
                .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous))
            }
            .buttonStyle(.plain)

            HStack(spacing: 12) {
                Button {
                    copyToClipboard()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.on.doc")
                        Text("Copy Text".loc)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Design.Colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.8)
                    )
                }
                .buttonStyle(.plain)

                Button {
                    exportJSON()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "curlybraces")
                        Text("Export JSON".loc)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Design.Colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.8)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Row Helper

    private func detailRow(title: String, value: String, highlight: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(highlight ? .subheadline.weight(.semibold) : .caption)
                .foregroundStyle(highlight ? Design.Colors.textPrimary : Design.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(highlight ? .subheadline.weight(.bold) : .caption.weight(.medium))
                .foregroundStyle(highlight ? Design.Colors.primary : Design.Colors.textPrimary)
        }
    }

    // MARK: - Actions

    private func shareReport() {
        SensoryFeedbackService.shared.selectionClick()
        guard subscriptionManager.isPro else {
            showingPaywall = true
            return
        }
        let report = ClinicalReportExportService.shared.generateClinicalReport(
            profile: profile,
            cravingLogs: cravingLogs,
            preventedLosses: preventedLosses,
            assessmentResults: assessmentResults,
            journalEntries: journalEntries
        )
        ClinicalReportExportService.shared.shareFile(
            content: report,
            filename: "Clinical_Recovery_Report_\(Date.now.formatted(.iso8601.year().month().day())).txt"
        )
    }

    private func copyToClipboard() {
        SensoryFeedbackService.shared.successFeedback()
        let report = ClinicalReportExportService.shared.generateClinicalReport(
            profile: profile,
            cravingLogs: cravingLogs,
            preventedLosses: preventedLosses,
            assessmentResults: assessmentResults,
            journalEntries: journalEntries
        )
        UIPasteboard.general.string = report

        withAnimation(.spring(duration: 0.3)) {
            copiedConfirmation = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                copiedConfirmation = false
            }
        }
    }

    private func exportJSON() {
        SensoryFeedbackService.shared.selectionClick()
        guard subscriptionManager.isPro else {
            showingPaywall = true
            return
        }
        let json = ClinicalReportExportService.shared.generateJSONExport(
            profile: profile,
            cravingLogs: cravingLogs,
            preventedLosses: preventedLosses,
            assessmentResults: assessmentResults,
            journalEntries: journalEntries,
            savingsGoals: savingsGoals
        )
        ClinicalReportExportService.shared.shareFile(
            content: json,
            filename: "QuitGambling_Full_Backup_\(Date.now.formatted(.iso8601.year().month().day())).json"
        )
    }
}
