import SwiftUI
import SwiftData

/// Root view managing streamlined 5-tab navigation with visionOS glass aesthetics and biometric privacy overlay.
struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: AppTab = .home
    @State private var moreNavigationPath = NavigationPath()
    @Environment(\.modelContext) private var modelContext
    @State private var showOnboarding = false
    @State private var onboardingInitialStep = 0
    @State private var showMorningCheckin = false
    @State private var showPeriodicPaywall = false
    @State private var privacyManager = PrivacyManager()
    @State private var notificationManager = NotificationManager()
    @State private var shieldManager = ShieldManager()
    @State private var subscriptionManager = SubscriptionManager()
    @State private var themeManager = ThemeManager.shared
    @State private var preferences = AppPreferences.shared

    var body: some View {
        ZStack {
            // 1. Deep Obsidian Base
            Color.black
                .ignoresSafeArea()

            // 2. Translucent TabView floating seamlessly above the unified background
            TabView(selection: $selectedTab) {
                Tab("Home".loc, systemImage: "sparkles", value: .home) {
                    DashboardView(selectedTab: $selectedTab)
                }

                Tab("Shield".loc, systemImage: "shield.checkered", value: .shield) {
                    NavigationStack {
                        ShieldDashboardView()
                    }
                }

                Tab("SOS".loc, systemImage: "heart.circle.fill", value: .sos) {
                    SOSView()
                }

                Tab("Tracker".loc, systemImage: "chart.bar.fill", value: .tracker) {
                    TrackerView()
                }

                Tab("More".loc, systemImage: "ellipsis.circle.fill", value: .more) {
                    MoreView(navigationPath: $moreNavigationPath)
                }
            }
            .tint(Design.Colors.primary)
            .scrollIndicators(.hidden)
            .onChange(of: selectedTab) { _, _ in
                SensoryFeedbackService.shared.selectionClick()
            }

            // Camouflage Screen Overlay
            if privacyManager.isCamouflageActive {
                CamouflageView(onExit: {
                    privacyManager.toggleCamouflage()
                }, privacyManager: privacyManager)
                .environment(privacyManager)
                .transition(.opacity)
                .zIndex(99)
            }

            // Biometric Lock Screen Overlay
            if !privacyManager.isUnlocked {
                lockScreenOverlay
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
        .environment(\.locale, Locale(identifier: preferences.languageCode))
        .environment(preferences)
        .environment(privacyManager)
        .environment(notificationManager)
        .environment(shieldManager)
        .environment(subscriptionManager)
        .preferredColorScheme(.dark)
        .dismissKeyboardOnTap()
        .scrollIndicators(.hidden)
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(initialStep: onboardingInitialStep)
                .id("onboarding_\(onboardingInitialStep)")
                .dismissKeyboardOnTap()
                .scrollIndicators(.hidden)
        }
        .fullScreenCover(isPresented: $showMorningCheckin) {
            DailyMorningCheckinView()
                .dismissKeyboardOnTap()
                .scrollIndicators(.hidden)
        }
        .fullScreenCover(isPresented: $showPeriodicPaywall) {
            PaywallView()
                .environment(subscriptionManager)
                .dismissKeyboardOnTap()
                .scrollIndicators(.hidden)
        }
        .task {
            subscriptionManager.attachDelegate()
            await subscriptionManager.updateCustomerStatus()
            await subscriptionManager.fetchOfferings()
        }
        .onOpenURL { url in
            print("APP_DEBUG: onOpenURL received: \(url)")
            if url.scheme == "quitgambling" {
                if url.host == "set-revenuecat-key", let key = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "key" })?.value {
                    SubscriptionManager.apiKey = key
                    SubscriptionManager.configure()
                    subscriptionManager.attachDelegate()
                    Task {
                        await subscriptionManager.updateCustomerStatus()
                        await subscriptionManager.fetchOfferings()
                    }
                } else if url.host == "open-camouflage" || url.absoluteString.contains("camouflage") {
                    privacyManager.activateCamouflage()
                } else if url.host == "open-checkin" {
                    selectedTab = .home
                    showMorningCheckin = true
                } else if url.host == "set-language", let lang = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "lang" })?.value {
                    preferences.languageCode = lang
                } else if url.host == "open-onboarding" || url.absoluteString.contains("onboarding") {
                    let step = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "step" })?.value.flatMap(Int.init) ?? 0
                    onboardingInitialStep = step
                    showOnboarding = true
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(400))
                        NotificationCenter.default.post(name: NSNotification.Name("SetOnboardingStep"), object: step)
                    }
                } else if url.host == "open-settings" || url.absoluteString.contains("settings") {
                    selectedTab = .more
                    moreNavigationPath = NavigationPath([MoreRoute.settings])
                } else if url.host == "open-themes" {
                    selectedTab = .more
                    moreNavigationPath = NavigationPath([MoreRoute.settings])
                    NotificationCenter.default.post(name: NSNotification.Name("ScrollToThemes"), object: nil)
                } else if url.host == "open-clinical-report" {
                    selectedTab = .more
                    moreNavigationPath = NavigationPath([MoreRoute.clinicalReport])
                } else if url.host == "disable-shield" {
                    shieldManager.disableShield()
                } else if url.host == "enable-shield" {
                    shieldManager.isShieldActive = true
                } else if url.host == "open-dns-settings" {
                    DNSProtectionService.shared.openDNSSettings()
                } else if url.host == "open-paywall" || url.absoluteString.contains("paywall") {
                    UserDefaults.standard.set(Date.now.timeIntervalSince1970, forKey: "last_morning_checkin_timestamp")
                    showMorningCheckin = false
                    showPeriodicPaywall = true
                } else if url.host == "open-promocode-sheet" {
                    UserDefaults.standard.set(Date.now.timeIntervalSince1970, forKey: "last_morning_checkin_timestamp")
                    showMorningCheckin = false
                    showPeriodicPaywall = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        NotificationCenter.default.post(name: NSNotification.Name("OpenPromoCodeSheet"), object: nil)
                    }
                } else if url.host == "test-periodic-paywall" {
                    showPeriodicPaywall = true
                } else if url.host == "trigger-periodic-paywall" {
                    #if DEBUG
                    PeriodicPaywallService.setDebugCount(9)
                    #endif
                    evaluatePeriodicPaywall()
                } else if url.host == "reset-periodic-paywall" {
                    PeriodicPaywallService.resetCounter()
                } else if url.host == "redeem" || url.host == "promocode", let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "code" })?.value {
                    _ = subscriptionManager.unlockWithPromoCode(code)
                } else if url.host == "reset-promo" {
                    subscriptionManager.resetPromoUnlock()
                } else if url.host == "more" || url.path.contains("more") {
                    selectedTab = .more
                } else if url.host == "home" {
                    selectedTab = .home
                    moreNavigationPath = NavigationPath()
                    showOnboarding = false
                    showMorningCheckin = false
                    showPeriodicPaywall = false
                } else if url.host == "tracker" {
                    selectedTab = .tracker
                }
            }
        }
        .task {
            // Check onboarding
            let descriptor = FetchDescriptor<UserProfile>()
            let profiles = (try? modelContext.fetch(descriptor)) ?? []
            if profiles.isEmpty {
                showOnboarding = true
            }

            // Check notifications
            await notificationManager.checkPermission()

            // Check shield authorization
            await shieldManager.checkAuthorization()

            // Trigger biometric check if locked
            if !privacyManager.isUnlocked {
                await privacyManager.authenticate()
            }

            // Morning Check-in auto-prompt on first open of the day
            if !showOnboarding && !showPeriodicPaywall && MorningCheckinService.shouldShowCheckinToday() {
                try? await Task.sleep(for: .seconds(0.5))
                if privacyManager.isUnlocked && !showPeriodicPaywall {
                    showMorningCheckin = true
                }
            } else {
                evaluatePeriodicPaywall()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                if privacyManager.isShakeToCamouflageEnabled {
                    ShakeMotionService.shared.startMonitoring()
                }
                if !privacyManager.isUnlocked {
                    Task {
                        await privacyManager.authenticate()
                        if privacyManager.isUnlocked {
                            evaluatePeriodicPaywall()
                        }
                    }
                } else {
                    evaluatePeriodicPaywall()
                }
            } else {
                ShakeMotionService.shared.stopMonitoring()
                privacyManager.lockApp()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in
            if privacyManager.isShakeToCamouflageEnabled && !privacyManager.isCamouflageActive && subscriptionManager.isPro {
                SensoryFeedbackService.shared.selectionClick()
                privacyManager.activateCamouflage()
            }
        }
        .onAppear {
            UIApplication.shared.applicationSupportsShakeToEdit = false
            privacyManager.syncCurrentAlternateIcon()
        }
    }

    // MARK: - Periodic Paywall Evaluation

    private func evaluatePeriodicPaywall() {
        guard !subscriptionManager.isPro else { return }
        guard !showOnboarding && !showMorningCheckin && !showPeriodicPaywall else { return }

        if PeriodicPaywallService.recordAppOpenAndCheckTrigger(isPro: subscriptionManager.isPro) {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(750))
                if !subscriptionManager.isPro && !showOnboarding && !showMorningCheckin && privacyManager.isUnlocked {
                    withAnimation(Design.Anim.spring) {
                        showPeriodicPaywall = true
                    }
                }
            }
        }
    }

    // MARK: - Lock Screen Overlay

    private var lockScreenOverlay: some View {
        ZStack {
            BioluminescentCanvasView()

            VStack(spacing: Design.Spacing.xl) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Design.Colors.bioluminescentEmerald.opacity(0.15))
                        .frame(width: 110, height: 110)
                        .blur(radius: 12)

                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Design.Colors.bioluminescentEmerald)
                        .shadow(color: Design.Colors.bioluminescentEmerald.opacity(0.5), radius: 10)
                }

                VStack(spacing: Design.Spacing.xs) {
                    Text("Quit Gambling Sanctuary")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                    Text("Please authenticate to enter your private space.")
                        .font(.subheadline)
                        .foregroundStyle(Design.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Design.Spacing.xl)
                }

                Spacer()

                Button {
                    Task {
                        await privacyManager.authenticate()
                    }
                } label: {
                    Label("Unlock Quit Gambling", systemImage: "faceid")
                        .font(.headline)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            Capsule()
                                .fill(Design.Colors.bioluminescentEmerald)
                                .shadow(color: Design.Colors.bioluminescentEmerald.opacity(0.4), radius: 12, y: 4)
                        )
                }
                .padding(.horizontal, Design.Spacing.xl)
                .padding(.bottom, Design.Spacing.xxl)
            }
        }
    }
}

enum AppTab: String, CaseIterable {
    case home, shield, sos, tracker, more
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, EmergencyContact.self], inMemory: true)
}
