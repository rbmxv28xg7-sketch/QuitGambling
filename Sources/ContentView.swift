import SwiftUI
import SwiftData

/// Root view managing tab navigation, biometric privacy overlay, camouflage mode, and onboarding.
struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    @Environment(\.modelContext) private var modelContext
    @State private var showOnboarding = false
    @State private var privacyManager = PrivacyManager()
    @State private var notificationManager = NotificationManager()

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                Tab("Home", systemImage: "house.fill", value: .home) {
                    DashboardView()
                }

                Tab("Tracker", systemImage: "chart.bar.fill", value: .tracker) {
                    TrackerView()
                }

                Tab("SOS", systemImage: "heart.circle.fill", value: .sos) {
                    SOSView()
                }

                Tab("Journal", systemImage: "book.fill", value: .journal) {
                    JournalView()
                }

                Tab("Mehr", systemImage: "ellipsis.circle.fill", value: .more) {
                    MoreView()
                }
            }
            .tint(Design.Colors.primary)
            .environment(privacyManager)
            .environment(notificationManager)

            // Camouflage Screen Overlay
            if privacyManager.isCamouflageActive {
                CamouflageView {
                    privacyManager.toggleCamouflage()
                }
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
        .sheet(isPresented: $showOnboarding) {
            OnboardingView()
                .interactiveDismissDisabled()
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

            // Trigger biometric check if locked
            if !privacyManager.isUnlocked {
                await privacyManager.authenticate()
            }
        }
    }

    // MARK: - Lock Screen Overlay

    private var lockScreenOverlay: some View {
        ZStack {
            Design.Colors.background
                .ignoresSafeArea()

            VStack(spacing: Design.Spacing.xl) {
                Spacer()

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Design.Colors.primary)

                VStack(spacing: Design.Spacing.xs) {
                    Text("FreiSpiel geschützt")
                        .font(.title2)
                        .bold()
                    Text("Bitte authentifiziere dich, um deine privaten Daten anzuzeigen.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Design.Spacing.lg)
                }

                Spacer()

                Button {
                    Task {
                        await privacyManager.authenticate()
                    }
                } label: {
                    Label("App entsperren", systemImage: "faceid")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Design.Colors.primary)
                        .clipShape(.rect(cornerRadius: Design.Radius.md))
                }
                .padding(.horizontal, Design.Spacing.xl)
                .padding(.bottom, Design.Spacing.xl)
            }
        }
    }
}

enum AppTab: String, CaseIterable {
    case home, tracker, sos, journal, more
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, EmergencyContact.self], inMemory: true)
}
