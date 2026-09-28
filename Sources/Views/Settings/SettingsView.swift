import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PrivacyManager.self) private var privacyManager
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(ShieldManager.self) private var shieldManager: ShieldManager?

    @Query private var profiles: [UserProfile]
    @Query(sort: \PreventedLossEntry.date, order: .reverse) private var preventedEntries: [PreventedLossEntry]
    @Query private var cravingLogs: [CravingLog]
    @Query private var assessmentResults: [SelfAssessmentResult]
    @Query private var journalEntries: [JournalEntry]
    @Query private var savingsGoals: [SavingsGoal]

    @State private var startDate = Date.now
    @State private var dailySpend: Double = 0
    @State private var selectedSpendPattern: SpendPattern = .monthly
    @State private var baseSpendAmount: Double = 0
    @State private var showingAddPreventedLossSheet: Bool = false
    @State private var showingResetConfirm = false
    @State private var isLoaded = false
    @State private var showingEditPINAlert = false
    @State private var editPINText = ""

    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var showingPaywall = false

    @Bindable private var preferences = AppPreferences.shared
    @State private var themeManager = ThemeManager.shared
    @State private var sensoryService = SensoryFeedbackService.shared

    @Bindable private var bindablePrivacy: PrivacyManager
    @Bindable private var bindableNotifications: NotificationManager

    init() {
        // Fallback for previews/initialization
        self._bindablePrivacy = Bindable(wrappedValue: PrivacyManager())
        self._bindableNotifications = Bindable(wrappedValue: NotificationManager())
    }

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        @Bindable var privacy = privacyManager
        @Bindable var notifications = notificationManager

        ZStack {
            FlutedGlassBackgroundView()

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Design.Spacing.lg) {
                    settingsSection("Profile".loc) {
                        DatePicker("Clean since".loc, selection: $startDate, in: ...Date.now, displayedComponents: .date)
                            .tint(Design.Colors.primary)
                            .foregroundStyle(Design.Colors.textPrimary)
                            .onChange(of: startDate) { _, newValue in
                                profile?.sobrietyStartDate = newValue
                                try? modelContext.save()
                            }

                        Divider().background(Color.white.opacity(0.12))

                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Gambling Pattern".loc)
                                    .foregroundStyle(Design.Colors.textPrimary)
                                Text("Typical gambling pattern before quitting".loc)
                                    .font(.caption2)
                                    .foregroundStyle(Design.Colors.textTertiary)
                            }
                            Spacer()
                            Picker("Pattern".loc, selection: $selectedSpendPattern) {
                                ForEach(SpendPattern.allCases) { pattern in
                                    Text(pattern.title).tag(pattern)
                                }
                            }
                            .tint(Design.Colors.primary)
                            .onChange(of: selectedSpendPattern) { _, newPattern in
                                profile?.spendPattern = newPattern
                                profile?.recalculateDailySpend()
                                if let profile = profile {
                                    dailySpend = profile.dailyGamblingSpend
                                }
                                try? modelContext.save()
                                sensoryService.selectionClick()
                            }
                        }

                        if selectedSpendPattern != .manualOnly {
                            Divider().background(Color.white.opacity(0.12))

                            LabeledContent {
                                TextField("Amount".loc, value: $baseSpendAmount, format: .currency(code: preferences.currencyCode))
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.decimalPad)
                                    .foregroundStyle(Design.Colors.textPrimary)
                                    .onChange(of: baseSpendAmount) { _, newValue in
                                        profile?.estimatedBaseAmount = newValue
                                        profile?.recalculateDailySpend()
                                        if let profile = profile {
                                            dailySpend = profile.dailyGamblingSpend
                                        }
                                        try? modelContext.save()
                                    }
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Past Spend".loc)
                                        .foregroundStyle(Design.Colors.textPrimary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                    Text("Average per %@".loc(selectedSpendPattern.shortTitle.lowercased()))
                                        .font(.caption2)
                                        .foregroundStyle(Design.Colors.textTertiary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                            }

                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .font(.caption2)
                                let dailyEquiv = selectedSpendPattern.dailyEquivalent(amount: baseSpendAmount).formatted(.currency(code: preferences.currencyCode))
                                Text("Equates continuously to ~%@ per day.".loc(dailyEquiv))
                                    .font(.caption2)
                                    .contentTransition(.numericText())
                                    .animation(Design.Anim.spring, value: baseSpendAmount)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                            }
                            .foregroundStyle(Design.Colors.gold)
                        } else {
                            Divider().background(Color.white.opacity(0.12))

                            Text("Urge-only mode: $0 baseline. Savings grow exclusively through resisted bets.".loc)
                                .font(.caption2)
                                .foregroundStyle(Design.Colors.textSecondary)
                        }
                    }

                    preferencesSection

                    settingsSection("Appearance & Themes".loc) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Colorway.allCases) { colorway in
                                    let isLocked = !subscriptionManager.isPro && colorway != .cleanMonochrome
                                    ColorwayItemView(
                                        colorway: colorway,
                                        isSelected: themeManager.selectedColorway == colorway,
                                        isLocked: isLocked
                                    ) {
                                        if isLocked {
                                            showingPaywall = true
                                        } else {
                                            themeManager.selectColorway(colorway)
                                            sensoryService.selectionClick()
                                        }
                                    }
                                }
                            }
                            .padding(.leading, Design.Spacing.md)
                            .padding(.trailing, Design.Spacing.md)
                            .padding(.vertical, 4)
                        }
                        .scrollClipDisabled()
                        .smoothHorizontalScroll(bleedPadding: Design.Spacing.md, leadingFade: 24, trailingFade: 36)
                    }
                    .id("themesSection")

                    settingsSection("Mindful Haptics".loc) {
                        Toggle(isOn: $sensoryService.isHapticsEnabled) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Tactile Feedback (Haptics)".loc)
                                    .font(.body)
                                    .foregroundStyle(Design.Colors.textPrimary)
                                Text("Sensory pulses for pledge, check-ins, and emergency tools".loc)
                                    .font(.caption)
                                    .foregroundStyle(Design.Colors.textTertiary)
                            }
                        }
                        .tint(Design.Colors.toggleTint)
                        .onChange(of: sensoryService.isHapticsEnabled) { _, _ in
                            sensoryService.toggleChanged()
                        }
                    }

                    settingsSection("Security & Privacy".loc) {
                        HStack {
                            Toggle(isOn: Binding(
                                get: { privacy.isBiometricsEnabled },
                                set: { newValue in
                                    if newValue && !subscriptionManager.isPro {
                                        showingPaywall = true
                                    } else {
                                        privacy.isBiometricsEnabled = newValue
                                    }
                                }
                            )) {
                                HStack(spacing: 8) {
                                    Text("Protect with Face ID / Passcode".loc)
                                        .foregroundStyle(Design.Colors.textPrimary)
                                    if !subscriptionManager.isPro {
                                        ProBadge(isCompact: true)
                                    }
                                }
                            }
                            .tint(Design.Colors.toggleTint)
                        }
                    }

                    discreetAppIconSection

                    camouflageSection

                    settingsSection("Daily Reminders (Optional)".loc) {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Silent Refuge (Mindful Principle)".loc, systemImage: "bell.slash.fill")
                                .font(.caption)
                                .bold()
                                .foregroundStyle(Design.Colors.gold)

                            Text("Quit Gambling avoids unsolicited notifications by default to prevent triggering gambling urges (the Pink Elephant effect). Only enable reminder times if you desire structured personal check-ins.".loc)
                                .font(.caption2)
                                .foregroundStyle(Design.Colors.textTertiary)
                                .lineSpacing(2)
                        }
                        .padding(.vertical, 2)

                        Divider().background(Color.white.opacity(0.12))

                        Toggle("Morning Pledge Reminder".loc, isOn: $notifications.morningReminderEnabled)
                            .tint(Design.Colors.toggleTint)
                            .foregroundStyle(Design.Colors.textPrimary)
                            .onChange(of: notifications.morningReminderEnabled) { _, enabled in
                                if enabled {
                                    Task {
                                        _ = await notificationManager.requestPermission()
                                    }
                                }
                            }

                        if notifications.morningReminderEnabled {
                            Divider().background(Color.white.opacity(0.12))
                            DatePicker("Morning Time".loc, selection: $notifications.morningTime, displayedComponents: .hourAndMinute)
                                .tint(Design.Colors.primary)
                                .foregroundStyle(Design.Colors.textPrimary)
                        }

                        Divider().background(Color.white.opacity(0.12))

                        Toggle("Evening Reflection Reminder".loc, isOn: $notifications.eveningReminderEnabled)
                            .tint(Design.Colors.toggleTint)
                            .foregroundStyle(Design.Colors.textPrimary)
                            .onChange(of: notifications.eveningReminderEnabled) { _, enabled in
                                if enabled {
                                    Task {
                                        _ = await notificationManager.requestPermission()
                                    }
                                }
                            }

                        if notifications.eveningReminderEnabled {
                            Divider().background(Color.white.opacity(0.12))
                            DatePicker("Evening Time".loc, selection: $notifications.eveningTime, displayedComponents: .hourAndMinute)
                                .tint(Design.Colors.primary)
                                .foregroundStyle(Design.Colors.textPrimary)
                        }
                    }

                    settingsSection("Accountability Contact".loc) {
                        NavigationLink(destination: EmergencyBuddyView()) {
                            HStack {
                                Label("Manage Emergency Buddy".loc, systemImage: "person.2.fill")
                                    .foregroundStyle(Design.Colors.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Design.Colors.textTertiary)
                            }
                        }
                    }

                    settingsSection("Backup & Reset".loc) {
                        Button {
                            exportAllDataJSON()
                        } label: {
                            HStack {
                                Label("Export Backup (JSON)".loc, systemImage: "square.and.arrow.up")
                                    .foregroundStyle(Design.Colors.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Design.Colors.textTertiary)
                            }
                        }

                        Divider().background(Color.white.opacity(0.12))

                        Button(role: .destructive) {
                            sensoryService.selectionClick()
                            showingResetConfirm = true
                        } label: {
                            HStack {
                                Label("Delete All Data".loc, systemImage: "trash")
                                    .foregroundStyle(Design.Colors.sos)
                                Spacer()
                            }
                        }
                    }

                    settingsSection("About".loc) {
                        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.1"
                        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "6"
                        LabeledContent {
                            Text("\(appVersion) (\(buildNumber))")
                                .foregroundStyle(Design.Colors.textSecondary)
                        } label: {
                            Text("Version".loc)
                                .foregroundStyle(Design.Colors.textPrimary)
                        }

                        Divider().background(Color.white.opacity(0.12))

                        NavigationLink {
                            ZStack {
                                FlutedGlassBackgroundView()
                                ScrollView(showsIndicators: false) {
                                    VStack(alignment: .leading, spacing: Design.Spacing.md) {
                                        Text("Privacy Policy".loc)
                                            .font(.title2)
                                            .bold()
                                            .foregroundStyle(Design.Colors.textPrimary)
                                        Text("Quit Gambling stores all information (journal entries, urge logs, emergency contacts, assessment results) exclusively encrypted and locally on your device.\n\nZero data is transmitted to external servers or tracked.".loc)
                                            .foregroundStyle(Design.Colors.textSecondary)
                                            .lineSpacing(3)
                                    }
                                    .padding()
                                    .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.lg)
                                    .padding(.horizontal)
                                    .padding(.bottom, 96)
                                }
                            }
                            .navigationTitle("Privacy Policy".loc)
                        } label: {
                            HStack {
                                Text("Privacy Policy".loc)
                                    .foregroundStyle(Design.Colors.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Design.Colors.textTertiary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, Design.Spacing.md)
                .padding(.bottom, 96)
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ScrollToThemes"))) { _ in
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(350))
                    withAnimation(.spring) {
                        proxy.scrollTo("themesSection", anchor: .top)
                    }
                }
            }
            .onOpenURL { url in
                if url.host == "open-themes" {
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(350))
                        withAnimation(.spring) {
                            proxy.scrollTo("themesSection", anchor: .top)
                        }
                    }
                }
            }
        }
        }
        .navigationTitle("Settings".loc)
        .alert(
            "Delete All Data?".loc,
            isPresented: $showingResetConfirm
        ) {
            Button("Delete".loc, role: .destructive) {
                SensoryFeedbackService.shared.emergencyBrakeTriggered()
                deleteAllData()
            }
            Button("Cancel".loc, role: .cancel) {}
        } message: {
            Text("This action cannot be undone. All entries, milestones, assessment results, and settings will be permanently deleted.".loc)
        }
        .sheet(isPresented: $showingAddPreventedLossSheet) {
            AddPreventedLossSheet(defaultContextTag: "Settings")
                .scrollIndicators(.hidden)
        }
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
        .alert("Secret Unlock PIN".loc, isPresented: $showingEditPINAlert) {
            TextField("4-digit PIN".loc, text: $editPINText)
                .keyboardType(.numberPad)
            Button("Save".loc) {
                let clean = editPINText.trimmingCharacters(in: .whitespacesAndNewlines)
                if !clean.isEmpty {
                    privacyManager.camouflagePIN = clean
                    SensoryFeedbackService.shared.successFeedback()
                }
            }
            Button("Cancel".loc, role: .cancel) {}
        } message: {
            Text("Enter a secret PIN to unlock the app when using the calculator disguise.".loc)
        }
        .scrollIndicators(.hidden)
        .task {
            guard !isLoaded else { return }
            if let p = profile {
                startDate = p.sobrietyStartDate
                dailySpend = p.dailyGamblingSpend
                selectedSpendPattern = p.spendPattern
                baseSpendAmount = p.estimatedBaseAmount > 0 ? p.estimatedBaseAmount : (p.dailyGamblingSpend * 30.416)
            }
            isLoaded = true
        }
        .dismissKeyboardOnTap()
    }

    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(Design.Colors.gold)
                .padding(.leading, 8)

            VStack(spacing: Design.Spacing.md) {
                content()
            }
            .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.md)
        }
    }

    private var preferencesSection: some View {
        settingsSection("Preferences & Localization".loc) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Language".loc)
                        .foregroundStyle(Design.Colors.textPrimary)
                    Text("App display language".loc)
                        .font(.caption2)
                        .foregroundStyle(Design.Colors.textTertiary)
                }
                Spacer()
                Picker("Language".loc, selection: $preferences.languageCode) {
                    ForEach(AppPreferences.supportedLanguages) { lang in
                        Text(lang.nativeName).tag(lang.id)
                    }
                }
                .tint(Design.Colors.primary)
                .onChange(of: preferences.languageCode) { _, _ in
                    sensoryService.selectionClick()
                }
            }

            Divider().background(Color.white.opacity(0.12))

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Currency".loc)
                        .foregroundStyle(Design.Colors.textPrimary)
                    Text("Savings and loss calculations".loc)
                        .font(.caption2)
                        .foregroundStyle(Design.Colors.textTertiary)
                }
                Spacer()
                Picker("Currency".loc, selection: $preferences.currencyCode) {
                    ForEach(AppPreferences.supportedCurrencies) { curr in
                        Text("\(curr.symbol) \(curr.code)").tag(curr.code)
                    }
                }
                .tint(Design.Colors.primary)
                .onChange(of: preferences.currencyCode) { _, _ in
                    sensoryService.selectionClick()
                }
            }

            Divider().background(Color.white.opacity(0.12))

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Units".loc)
                        .foregroundStyle(Design.Colors.textPrimary)
                    Text("Distance measurements".loc)
                        .font(.caption2)
                        .foregroundStyle(Design.Colors.textTertiary)
                }
                Spacer()
                Picker("Units".loc, selection: $preferences.unitSystem) {
                    ForEach(AppPreferences.UnitSystem.allCases) { unit in
                        Text(unit.title).tag(unit)
                    }
                }
                .tint(Design.Colors.primary)
                .onChange(of: preferences.unitSystem) { _, _ in
                    sensoryService.selectionClick()
                }
            }

            Divider().background(Color.white.opacity(0.12))

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Region & Protection".loc)
                        .foregroundStyle(Design.Colors.textPrimary)
                    Text("Country-specific gambling blocklist".loc)
                        .font(.caption2)
                        .foregroundStyle(Design.Colors.textTertiary)
                }
                Spacer()
                Picker("Region".loc, selection: $preferences.regionCode) {
                    ForEach(AppPreferences.supportedRegions) { reg in
                        Text("\(reg.code) - \(reg.name)").tag(reg.code)
                    }
                }
                .tint(Design.Colors.primary)
                .onChange(of: preferences.regionCode) { _, newCode in
                    CountryBlocklistCatalog.setCountryCode(newCode)
                    shieldManager?.setCountry(newCode)
                    sensoryService.selectionClick()
                }
            }
        }
    }

    private func exportAllDataJSON() {
        sensoryService.selectionClick()
        let json = ClinicalReportExportService.shared.generateJSONExport(
            profile: profile,
            cravingLogs: cravingLogs,
            preventedLosses: preventedEntries,
            assessmentResults: assessmentResults,
            journalEntries: journalEntries,
            savingsGoals: savingsGoals
        )
        ClinicalReportExportService.shared.shareFile(
            content: json,
            filename: "QuitGambling_Full_Backup_\(Date.now.formatted(.iso8601.year().month().day())).json"
        )
    }

    private func deleteAllData() {
        try? modelContext.delete(model: JournalEntry.self)
        try? modelContext.delete(model: CravingLog.self)
        try? modelContext.delete(model: MilestoneAchievement.self)
        try? modelContext.delete(model: SavingsGoal.self)
        try? modelContext.delete(model: ReasonToQuit.self)
        try? modelContext.delete(model: EmergencyContact.self)
        try? modelContext.delete(model: SelfAssessmentResult.self)
        try? modelContext.delete(model: UserProfile.self)
        try? modelContext.delete(model: PreventedLossEntry.self)
        try? modelContext.save()
    }

    private var discreetAppIconSection: some View {
        settingsSection("Discreet App Icon (Homescreen)".loc) {
            VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                HStack {
                    Text("Change your homescreen icon to a generic disguise without mentioning gambling.".loc)
                        .font(.caption2)
                        .foregroundStyle(Design.Colors.textTertiary)
                        .lineSpacing(2)
                    Spacer()
                    if !subscriptionManager.isPro {
                        ProBadge(isCompact: true)
                    }
                }

                HStack(spacing: 12) {
                    iconOptionCard(
                        title: "Default".loc,
                        subtitle: "Quit Gambling",
                        imageName: "AppIconPreview",
                        isSelected: privacyManager.currentAlternateIcon == nil,
                        isLocked: false
                    ) {
                        Task {
                            await privacyManager.setAlternateAppIcon(nil)
                        }
                    }

                    iconOptionCard(
                        title: "Calculator".loc,
                        subtitle: "Discreet".loc,
                        imageName: "CalculatorPreview",
                        isSelected: privacyManager.currentAlternateIcon == "CalculatorIcon",
                        isLocked: !subscriptionManager.isPro
                    ) {
                        if !subscriptionManager.isPro {
                            showingPaywall = true
                        } else {
                            Task {
                                await privacyManager.setAlternateAppIcon("CalculatorIcon")
                            }
                        }
                    }

                    iconOptionCard(
                        title: "Notes".loc,
                        subtitle: "Discreet".loc,
                        imageName: "NotesPreview",
                        isSelected: privacyManager.currentAlternateIcon == "NotesIcon",
                        isLocked: !subscriptionManager.isPro
                    ) {
                        if !subscriptionManager.isPro {
                            showingPaywall = true
                        } else {
                            Task {
                                await privacyManager.setAlternateAppIcon("NotesIcon")
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var camouflageSection: some View {
        @Bindable var privacy = privacyManager
        return settingsSection("Camouflage Mode (In-App Disguise)".loc) {
            VStack(alignment: .leading, spacing: Design.Spacing.md) {
                if !subscriptionManager.isPro {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .font(.subheadline)
                            .foregroundStyle(Design.Colors.gold)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Stealth Camouflage is a Pro Feature".loc)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.white)
                            Text("Shake to hide and disguise as Calculator / Notes require Pro.".loc)
                                .font(.caption2)
                                .foregroundStyle(Design.Colors.textSecondary)
                        }
                        Spacer()
                        Button("Unlock".loc) {
                            showingPaywall = true
                        }
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Design.Colors.goldGradient)
                        .clipShape(Capsule())
                    }
                    .padding(10)
                    .background(Design.Colors.gold.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: Design.Radius.sm))
                }

                HStack {
                    Text("Active Disguise".loc)
                        .foregroundStyle(Design.Colors.textPrimary)
                    Spacer()
                    Picker("Disguise".loc, selection: Binding(
                        get: { privacy.selectedCamouflageStyle },
                        set: { newStyle in
                            if !subscriptionManager.isPro {
                                showingPaywall = true
                            } else {
                                privacy.selectedCamouflageStyle = newStyle
                            }
                        }
                    )) {
                        Text("Calculator".loc).tag(CamouflageStyle.calculator)
                        Text("Notes".loc).tag(CamouflageStyle.notes)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 180)
                }

                Divider().background(Color.white.opacity(0.12))

                Toggle(isOn: Binding(
                    get: { privacy.isShakeToCamouflageEnabled },
                    set: { enabled in
                        if enabled && !subscriptionManager.isPro {
                            showingPaywall = true
                        } else {
                            privacy.isShakeToCamouflageEnabled = enabled
                        }
                    }
                )) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Shake to Disguise".loc)
                            .foregroundStyle(Design.Colors.textPrimary)
                        Text("Instantly hide the app by shaking your iPhone".loc)
                            .font(.caption2)
                            .foregroundStyle(Design.Colors.textTertiary)
                    }
                }
                .tint(Design.Colors.toggleTint)

                Divider().background(Color.white.opacity(0.12))

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Secret Unlock PIN".loc)
                            .foregroundStyle(Design.Colors.textPrimary)
                        Text("Enter PIN then '=' in the calculator to unlock".loc)
                            .font(.caption2)
                            .foregroundStyle(Design.Colors.textTertiary)
                    }
                    Spacer()
                    Button {
                        if !subscriptionManager.isPro {
                            showingPaywall = true
                        } else {
                            editPINText = privacyManager.camouflagePIN
                            showingEditPINAlert = true
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(privacyManager.camouflagePIN)
                                .font(.subheadline.monospaced().weight(.bold))
                                .foregroundStyle(Design.Colors.gold)
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundStyle(Design.Colors.gold)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Design.Colors.gold.opacity(0.15))
                        .clipShape(Capsule())
                    }
                }

                Divider().background(Color.white.opacity(0.12))

                Button {
                    if !subscriptionManager.isPro {
                        showingPaywall = true
                    } else {
                        privacyManager.activateCamouflage()
                    }
                } label: {
                    HStack {
                        Label("Test Camouflage Screen Now".loc, systemImage: "eye.slash.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Design.Colors.primary)
                        Spacer()
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundStyle(Design.Colors.primary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private func iconOptionCard(
        title: String,
        subtitle: String,
        imageName: String?,
        isSelected: Bool,
        isLocked: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            SensoryFeedbackService.shared.selectionClick()
            action()
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    if let imageName {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 58, height: 58)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    } else {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.12, green: 0.22, blue: 0.18), Color(red: 0.08, green: 0.12, blue: 0.10)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 58, height: 58)
                            .overlay(
                                Image(systemName: "shield.checkered")
                                    .font(.system(size: 26))
                                    .foregroundStyle(Design.Colors.primary)
                            )
                    }

                    if isSelected {
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Design.Colors.primary, lineWidth: 2.5)
                            .overlay(
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Design.Colors.primary)
                                    .background(Circle().fill(Color.black).padding(2))
                                    .offset(x: 22, y: -22)
                            )
                    } else if isLocked {
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Design.Colors.gold.opacity(0.4), lineWidth: 1)
                            .overlay(
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(Color.black)
                                    .padding(4)
                                    .background(Design.Colors.goldGradient)
                                    .clipShape(Circle())
                                    .offset(x: 22, y: -22)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    }
                }
                .frame(width: 58, height: 58)

                VStack(spacing: 1) {
                    Text(title)
                        .font(.caption.weight(isSelected ? .bold : .medium))
                        .foregroundStyle(isSelected ? Color.white : Design.Colors.textSecondary)
                    Text(subtitle)
                        .font(.system(size: 9))
                        .foregroundStyle(Design.Colors.textTertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}

private struct ColorwayItemView: View {
    let colorway: Colorway
    let isSelected: Bool
    let isLocked: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Text(colorway.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isSelected ? Design.Colors.textPrimary : Design.Colors.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Spacer(minLength: 4)
                    
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Design.Colors.gold)
                    } else if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(colorway.primary)
                    }
                }

                HStack(spacing: 6) {
                    ForEach(Array(colorway.previewColors.enumerated()), id: \.offset) { _, col in
                        Circle()
                            .fill(col)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                            .shadow(color: col.opacity(0.35), radius: 3, y: 1)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(width: 175, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                isSelected ? colorway.primary.opacity(0.85) : (isLocked ? Design.Colors.gold.opacity(0.3) : Color.white.opacity(0.12)),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(color: isSelected ? colorway.primary.opacity(0.25) : Color.clear, radius: 8, y: 3)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(PrivacyManager())
    .environment(NotificationManager())
    .modelContainer(for: UserProfile.self, inMemory: true)
}
