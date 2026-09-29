import SwiftUI
import SwiftData

/// Multi-step fullscreen onboarding and setup flow for first-time users and repeatable testing.
struct OnboardingView: View {
    var initialStep: Int = 0

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ShieldManager.self) private var shieldManager: ShieldManager?
    @Environment(SubscriptionManager.self) private var subscriptionManager: SubscriptionManager?

    @Query private var profiles: [UserProfile]

    @State private var preferences = AppPreferences.shared
    @State private var sensoryService = SensoryFeedbackService.shared

    @State private var currentStep: Int
    @State private var selectedCountryCode = CountryBlocklistCatalog.currentCountryCode
    @State private var startDate = Date.now
    @State private var selectedSpendPattern: SpendPattern = .monthly
    @State private var baseSpendAmount: Double = 300.0
    @State private var dailySpend: Double = 300.0 / 30.416
    @State private var showCheckmark = false
    @State private var showingPaywall = false

    init(initialStep: Int = 0) {
        self.initialStep = initialStep
        _currentStep = State(initialValue: initialStep)
    }

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()

            VStack(spacing: 0) {
                // Top Navigation Bar
                topNavigationBar

                // Steps TabView
                TabView(selection: $currentStep) {
                    languageStep.tag(0)
                    appExplanationStep.tag(1)
                    countryStep.tag(2)
                    dateStep.tag(3)
                    spendStep.tag(4)
                    completionStep.tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(Design.Anim.spring, value: currentStep)
            }
        }
        .task {
            if initialStep > 0 && initialStep <= 5 {
                currentStep = initialStep
            }
            loadExistingProfile()
        }
        .onChange(of: initialStep) { _, newStep in
            if newStep >= 0 && newStep <= 5 {
                currentStep = newStep
            }
        }
        .onChange(of: preferences.languageCode) { _, newLang in
            selectedCountryCode = CountryBlocklistCatalog.defaultCountryCode(for: newLang)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SetOnboardingStep"))) { notif in
            if let step = notif.object as? Int, step >= 0 && step <= 5 {
                withAnimation(Design.Anim.spring) {
                    currentStep = step
                }
            }
        }
        .fullScreenCover(isPresented: $showingPaywall, onDismiss: {
            dismiss()
        }) {
            PaywallView()
                .dismissKeyboardOnTap()
                .scrollIndicators(.hidden)
        }
    }

    // MARK: - Top Navigation Bar

    private var topNavigationBar: some View {
        HStack(spacing: 16) {
            // Back Button
            if currentStep > 0 {
                Button {
                    sensoryService.selectionClick()
                    withAnimation(Design.Anim.spring) {
                        currentStep -= 1
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back".loc)
                            .font(.subheadline)
                    }
                    .foregroundStyle(Design.Colors.textSecondary)
                }
            } else {
                Spacer()
                    .frame(width: 60)
            }

            Spacer()

            // Step Progress Indicator (6 steps)
            HStack(spacing: 6) {
                ForEach(0..<6) { step in
                    Capsule()
                        .fill(currentStep == step ? Design.Colors.primary : (currentStep > step ? Design.Colors.primary.opacity(0.4) : Color.white.opacity(0.15)))
                        .frame(width: currentStep == step ? 22 : 7, height: 6)
                        .animation(Design.Anim.spring, value: currentStep)
                }
            }

            Spacer()

            // Close / Dismiss Button (available when testing or re-running)
            if profile != nil {
                Button {
                    sensoryService.selectionClick()
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.white.opacity(0.35))
                }
            } else {
                Spacer()
                    .frame(width: 60)
            }
        }
        .padding(.horizontal, Design.Spacing.lg)
        .padding(.top, Design.Spacing.md)
        .padding(.bottom, Design.Spacing.sm)
    }

    // MARK: - Step 0: Language Selection (FIRST STEP)

    private var languageStep: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                Text("Choose Your Language".loc)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Design.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Select your preferred language for the app. You can change this anytime in settings.".loc)
                    .font(.caption)
                    .foregroundStyle(Design.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Design.Spacing.md)
            }
            .padding(.top, Design.Spacing.sm)
            .padding(.bottom, Design.Spacing.md)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(AppPreferences.supportedLanguages) { lang in
                        let isSelected = preferences.languageCode == lang.id
                        Button {
                            sensoryService.selectionClick()
                            withAnimation(Design.Anim.spring) {
                                preferences.languageCode = lang.id
                                selectedCountryCode = CountryBlocklistCatalog.defaultCountryCode(for: lang.id)
                            }
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(isSelected ? Design.Colors.primary.opacity(0.25) : Color.white.opacity(0.06))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: languageIcon(for: lang.id))
                                        .font(.title3)
                                        .foregroundStyle(isSelected ? Design.Colors.primary : Design.Colors.textSecondary)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(lang.nativeName)
                                        .font(.headline)
                                        .foregroundStyle(isSelected ? Color.white : Design.Colors.textPrimary)

                                    Text(lang.name)
                                        .font(.caption2)
                                        .foregroundStyle(isSelected ? Design.Colors.primary : Design.Colors.textTertiary)
                                }

                                Spacer()

                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(Design.Colors.primary)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: Design.Radius.card, style: .continuous)
                                    .fill(isSelected ? Design.Colors.primary.opacity(0.14) : Color.white.opacity(0.04))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Design.Radius.card, style: .continuous)
                                            .stroke(isSelected ? Design.Colors.primary.opacity(0.85) : Color.white.opacity(0.1), lineWidth: isSelected ? 1.5 : 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Design.Spacing.lg)
                .padding(.bottom, Design.Spacing.sm)
            }
            .smoothTopScrollFade(fadeLength: 24)

            // Fixed Bottom Button
            primaryActionButton("Continue".loc) {
                withAnimation(Design.Anim.spring) { currentStep = 1 }
            }
            .padding(.horizontal, Design.Spacing.lg)
            .padding(.bottom, Design.Spacing.md)
        }
    }

    private func languageIcon(for code: String) -> String {
        switch code {
        case "de": return "globe.europe.africa.fill"
        case "en": return "globe.americas.fill"
        case "es": return "globe.americas.fill"
        case "fr": return "globe.europe.africa.fill"
        default: return "globe"
        }
    }

    // MARK: - Step 1: Welcome & App Explanation (Core 4 Pillars)

    private var appExplanationStep: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Design.Spacing.md) {
                    // Emblem
                    ZStack {
                        Circle()
                            .fill(Design.Colors.primary.opacity(0.18))
                            .frame(width: 86, height: 86)
                            .blur(radius: 12)

                        Circle()
                            .fill(Design.Colors.primary.opacity(0.12))
                            .frame(width: 68, height: 68)

                        Image(systemName: "leaf.fill")
                            .font(.system(size: 34))
                            .foregroundStyle(Design.Colors.primary)
                    }
                    .padding(.top, Design.Spacing.md)

                    // Title & Subtitle
                    VStack(spacing: Design.Spacing.xs) {
                        Text("How Quit Gambling Protects You".loc)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(Design.Colors.textPrimary)
                            .multilineTextAlignment(.center)

                        Text("Your personal refuge with 4 essential recovery tools:".loc)
                            .font(.caption)
                            .foregroundStyle(Design.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Design.Spacing.sm)
                    }

                    // 4 Core Pillars
                    VStack(spacing: 10) {
                        pillarFeatureRow(
                            icon: "shield.checkered",
                            color: Design.Colors.primary,
                            title: "System-Wide Shield".loc,
                            subtitle: "Blocks gambling sites and apps on your device before temptations arise.".loc
                        )

                        pillarFeatureRow(
                            icon: "cross.circle.fill",
                            color: Design.Colors.sos,
                            title: "SOS Emergency Aid".loc,
                            subtitle: "Urge surfing, guided breathing, and grounding exercises during acute cravings.".loc
                        )

                        pillarFeatureRow(
                            icon: "clock.badge.checkmark.fill",
                            color: Design.Colors.gold,
                            title: "Sobriety Tracker & Journal".loc,
                            subtitle: "Celebrate clean milestones and track emotional triggers day by day.".loc
                        )

                        pillarFeatureRow(
                            icon: "banknote.fill",
                            color: Design.Colors.secondary,
                            title: "Financial Freedom".loc,
                            subtitle: "Watch your saved money grow and set tangible goals for your future.".loc
                        )
                    }
                }
                .padding(.horizontal, Design.Spacing.lg)
                .padding(.top, Design.Spacing.xs)
                .padding(.bottom, Design.Spacing.sm)
            }
            .smoothTopScrollFade(fadeLength: 28)

            // Fixed Bottom Button
            primaryActionButton("Continue".loc) {
                withAnimation(Design.Anim.spring) { currentStep = 2 }
            }
            .padding(.horizontal, Design.Spacing.lg)
            .padding(.bottom, Design.Spacing.md)
        }
    }

    private func pillarFeatureRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.16))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Design.Colors.textPrimary)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(Design.Colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(Design.Spacing.md)
        .liquidGlass(cornerRadius: Design.Radius.card, padding: 0)
    }

    // MARK: - Step 2: Country / Regional Shield

    private var countryStep: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                Text("Activate Regional Shield".loc)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Design.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Select your country to block the top 25 online casinos and betting portals automatically via Screen Time.".loc)
                    .font(.caption)
                    .foregroundStyle(Design.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, Design.Spacing.sm)
            .padding(.bottom, Design.Spacing.sm)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(CountryBlocklistCatalog.prioritizedCountries(for: preferences.languageCode)) { country in
                        Button {
                            sensoryService.selectionClick()
                            selectedCountryCode = country.code
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(selectedCountryCode == country.code ? Design.Colors.primary.opacity(0.25) : Color.white.opacity(0.06))
                                        .frame(width: 42, height: 42)
                                    Image(systemName: country.icon)
                                        .font(.headline)
                                        .foregroundStyle(selectedCountryCode == country.code ? Design.Colors.primary : Design.Colors.textSecondary)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(country.name.loc)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(selectedCountryCode == country.code ? Color.white : Design.Colors.textSecondary)

                                    Text("%d top domains blocked".loc(country.domains.count))
                                        .font(.caption2)
                                        .foregroundStyle(selectedCountryCode == country.code ? Design.Colors.primary : Design.Colors.textTertiary)
                                }

                                Spacer()

                                if selectedCountryCode == country.code {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(Design.Colors.primary)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                                    .fill(selectedCountryCode == country.code ? Design.Colors.primary.opacity(0.12) : Color.white.opacity(0.04))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                                            .stroke(selectedCountryCode == country.code ? Design.Colors.primary.opacity(0.8) : Color.white.opacity(0.1), lineWidth: selectedCountryCode == country.code ? 1.5 : 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Design.Spacing.lg)
                .padding(.bottom, Design.Spacing.sm)
            }
            .smoothTopScrollFade(fadeLength: 24)

            // Fixed Bottom Button
            primaryActionButton("Continue".loc) {
                withAnimation(Design.Anim.spring) { currentStep = 3 }
            }
            .padding(.horizontal, Design.Spacing.lg)
            .padding(.bottom, Design.Spacing.md)
        }
    }

    // MARK: - Step 3: Sobriety Date

    private var dateStep: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Design.Spacing.md) {
                    VStack(spacing: 6) {
                        Text("When was your last gamble?".loc)
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Design.Colors.textPrimary)
                            .multilineTextAlignment(.center)

                        Text("Be honest with yourself. Every day from now on is a milestone for your freedom.".loc)
                            .font(.caption)
                            .foregroundStyle(Design.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, Design.Spacing.sm)

                    // Quick date selection pills
                    HStack(spacing: 8) {
                        quickDatePill(title: "Today".loc, date: .now)
                        quickDatePill(title: "Yesterday".loc, date: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now)
                        quickDatePill(title: "1 Week Ago".loc, date: Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now)
                        quickDatePill(title: "1 Month Ago".loc, date: Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now)
                    }
                    .padding(.horizontal, 4)

                    // Graphical Date Picker
                    DatePicker(
                        "Date",
                        selection: $startDate,
                        in: ...Date.now,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .tint(Design.Colors.primary)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: Design.Radius.card, style: .continuous)
                            .fill(Color.white.opacity(0.04))
                            .overlay(
                                RoundedRectangle(cornerRadius: Design.Radius.card, style: .continuous)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                    )

                    // Elapsed Days Preview Pill
                    let elapsedDays = max(0, Calendar.current.dateComponents([.day], from: startDate, to: .now).day ?? 0)
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.caption)
                        if elapsedDays == 0 {
                            Text("Your gamble-free journey begins today!".loc)
                                .font(.caption)
                                .fontWeight(.semibold)
                        } else {
                            Text("%d days achieved already – let's build on this!".loc(elapsedDays))
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundStyle(Design.Colors.gold)
                    .padding(.vertical, 4)
                }
                .padding(.horizontal, Design.Spacing.lg)
                .padding(.bottom, Design.Spacing.sm)
            }
            .smoothTopScrollFade(fadeLength: 24)

            // Fixed Bottom Button
            primaryActionButton("Continue".loc) {
                withAnimation(Design.Anim.spring) { currentStep = 4 }
            }
            .padding(.horizontal, Design.Spacing.lg)
            .padding(.bottom, Design.Spacing.md)
        }
    }

    private func quickDatePill(title: String, date: Date) -> some View {
        let isSelected = Calendar.current.isDate(startDate, inSameDayAs: date)
        return Button {
            sensoryService.selectionClick()
            withAnimation(Design.Anim.spring) {
                startDate = date
            }
        } label: {
            Text(title)
                .font(.caption2)
                .fontWeight(isSelected ? .bold : .medium)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(isSelected ? Design.Colors.primary : Color.white.opacity(0.06))
                .foregroundStyle(isSelected ? Design.Colors.textOnPrimary : Design.Colors.textSecondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Design.Colors.primary : Color.white.opacity(0.08), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 4: Past Spending & Pattern

    private var spendStep: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Design.Spacing.md) {
                    VStack(spacing: 6) {
                        Text("Past Gambling Pattern".loc)
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Design.Colors.textPrimary)
                            .multilineTextAlignment(.center)

                        Text("Because gambling often occurs in bursts, select your typical pattern for realistic savings tracking.".loc)
                            .font(.caption)
                            .foregroundStyle(Design.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, Design.Spacing.sm)

                    // Pattern Picker Segmented
                    Picker("Pattern", selection: $selectedSpendPattern) {
                        ForEach(SpendPattern.allCases) { pattern in
                            Text(pattern.shortTitle).tag(pattern)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 4)
                    .onChange(of: selectedSpendPattern) { _, newPattern in
                        sensoryService.selectionClick()
                        if newPattern == .monthly {
                            baseSpendAmount = 300.0
                        } else if newPattern == .weekly {
                            baseSpendAmount = 70.0
                        } else if newPattern == .daily {
                            baseSpendAmount = 15.0
                        } else {
                            baseSpendAmount = 0.0
                        }
                        dailySpend = newPattern.dailyEquivalent(amount: baseSpendAmount)
                    }

                    VStack(spacing: Design.Spacing.md) {
                        if selectedSpendPattern != .manualOnly {
                            Text(baseSpendAmount, format: .currency(code: preferences.currencyCode))
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                                .foregroundStyle(Design.Colors.primary)
                                .contentTransition(.numericText())
                                .animation(Design.Anim.normal, value: baseSpendAmount)

                            Text("Average spend per %@".loc(selectedSpendPattern.shortTitle.lowercased()))
                                .font(.caption)
                                .foregroundStyle(Design.Colors.textSecondary)

                            Slider(
                                value: $baseSpendAmount,
                                in: 0...sliderMaxForPattern,
                                step: sliderStepForPattern
                            )
                            .tint(Design.Colors.primary)
                            .padding(.horizontal)
                            .onChange(of: baseSpendAmount) { _, newVal in
                                dailySpend = selectedSpendPattern.dailyEquivalent(amount: newVal)
                            }

                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .font(.caption2)
                                Text("Equates to a continuous baseline of ~%@ per day.".loc(dailySpend.formatted(.currency(code: preferences.currencyCode))))
                                    .font(.caption)
                                    .bold()
                            }
                            .foregroundStyle(Design.Colors.gold)
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "shield.lefthalf.filled")
                                    .font(.system(size: 44))
                                    .foregroundStyle(Design.Colors.gold)

                                Text("Urge-Only Tracking".loc)
                                    .font(.headline)
                                    .foregroundStyle(Color.white)

                                Text("$0 baseline. Your savings tracker will grow exclusively through actively resisted wagers that you record.".loc)
                                    .font(.caption)
                                    .foregroundStyle(Design.Colors.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding(.vertical, Design.Spacing.lg)
                        }
                    }
                    .padding(.vertical, Design.Spacing.md)
                    .liquidGlass(cornerRadius: Design.Radius.card, padding: 0)
                }
                .padding(.horizontal, Design.Spacing.lg)
                .padding(.bottom, Design.Spacing.sm)
            }
            .smoothTopScrollFade(fadeLength: 24)

            // Fixed Bottom Button
            primaryActionButton("Continue".loc) {
                withAnimation(Design.Anim.spring) { currentStep = 5 }
            }
            .padding(.horizontal, Design.Spacing.lg)
            .padding(.bottom, Design.Spacing.md)
        }
    }

    private var sliderMaxForPattern: Double {
        switch selectedSpendPattern {
        case .monthly: return 2000.0
        case .weekly: return 500.0
        case .daily: return 200.0
        case .manualOnly: return 100.0
        }
    }

    private var sliderStepForPattern: Double {
        switch selectedSpendPattern {
        case .monthly: return 25.0
        case .weekly: return 10.0
        case .daily: return 5.0
        case .manualOnly: return 10.0
        }
    }

    // MARK: - Step 5: Completion & Summary

    private var completionStep: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Design.Spacing.lg) {
                    Spacer(minLength: 24)

                    // Animated Success Emblem
                    ZStack {
                        Circle()
                            .fill(Design.Colors.primary.opacity(0.18))
                            .frame(width: 100, height: 100)
                            .blur(radius: 14)

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(Design.Colors.primary)
                            .scaleEffect(showCheckmark ? 1.0 : 0.4)
                            .opacity(showCheckmark ? 1.0 : 0)
                            .animation(Design.Anim.spring, value: showCheckmark)
                    }

                    VStack(spacing: Design.Spacing.xs) {
                        Text("You're All Set!".loc)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(Design.Colors.textPrimary)

                        Text("Your protective shield is active and your journey to freedom begins right now.".loc)
                            .font(.caption)
                            .foregroundStyle(Design.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Summary Card
                    VStack(spacing: 12) {
                        summaryRow(
                            label: "Clean Since".loc,
                            value: startDate.formatted(date: .long, time: .omitted)
                        )

                        Divider().background(Color.white.opacity(0.1))

                        let countryName = CountryBlocklistCatalog.country(for: selectedCountryCode).name.loc
                        summaryRow(
                            label: "Protected Region".loc,
                            value: countryName
                        )

                        Divider().background(Color.white.opacity(0.1))

                        let estMonthly = dailySpend * 30.416
                        summaryRow(
                            label: "Est. Monthly Savings".loc,
                            value: estMonthly.formatted(.currency(code: preferences.currencyCode))
                        )
                    }
                    .padding(Design.Spacing.md)
                    .liquidGlass(cornerRadius: Design.Radius.card, padding: 0)

                    Spacer(minLength: 16)
                }
                .padding(.horizontal, Design.Spacing.lg)
            }
            .smoothTopScrollFade(fadeLength: 28)

            // Fixed Bottom Button
            primaryActionButton("Continue".loc) {
                completeOnboarding()
            }
            .padding(.horizontal, Design.Spacing.lg)
            .padding(.bottom, Design.Spacing.md)
        }
        .task {
            try? await Task.sleep(for: .milliseconds(250))
            showCheckmark = true
        }
    }

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Design.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Design.Colors.textPrimary)
        }
    }

    // MARK: - Actions & Persistence

    private func primaryActionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button {
            sensoryService.selectionClick()
            action()
        } label: {
            Text(title)
                .font(.headline)
                .foregroundStyle(Design.Colors.textOnPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Design.Colors.primary)
                .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous))
                .shadow(color: Design.Colors.primary.opacity(0.35), radius: 8, y: 4)
        }
    }

    private func loadExistingProfile() {
        if let existing = profile {
            startDate = existing.sobrietyStartDate
            selectedSpendPattern = existing.spendPattern
            baseSpendAmount = existing.estimatedBaseAmount > 0 ? existing.estimatedBaseAmount : 300.0
            dailySpend = existing.dailyGamblingSpend > 0 ? existing.dailyGamblingSpend : selectedSpendPattern.dailyEquivalent(amount: baseSpendAmount)
        }
        selectedCountryCode = CountryBlocklistCatalog.defaultCountryCode(for: preferences.languageCode)
    }

    private func completeOnboarding() {
        CountryBlocklistCatalog.setCountryCode(selectedCountryCode)
        shieldManager?.setCountry(selectedCountryCode)

        if let existing = profile {
            existing.sobrietyStartDate = startDate
            existing.dailyGamblingSpend = dailySpend
            existing.spendPattern = selectedSpendPattern
            existing.estimatedBaseAmount = baseSpendAmount
            existing.hasCompletedOnboarding = true
        } else {
            let newProfile = UserProfile(
                sobrietyStartDate: startDate,
                dailyGamblingSpend: dailySpend,
                spendPatternRaw: selectedSpendPattern.rawValue,
                estimatedBaseAmount: baseSpendAmount
            )
            newProfile.hasCompletedOnboarding = true
            modelContext.insert(newProfile)
        }

        try? modelContext.save()
        sensoryService.successFeedback()

        if subscriptionManager?.isPro != true {
            showingPaywall = true
        } else {
            dismiss()
        }
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
