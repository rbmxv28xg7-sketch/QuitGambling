import SwiftUI
import SwiftData
import NetworkExtension

@main
struct QuitGamblingApp: App {

    init() {
        // Disable system 'Shake to Undo' prompt so physical shaking activates camouflage cleanly
        UIApplication.shared.applicationSupportsShakeToEdit = false

        // Initialize RevenueCat SDK for Shipathon 2026
        SubscriptionManager.configure()

        Task {
            await DNSProtectionService.shared.checkStatus()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .scrollIndicators(.hidden)
        }
        .modelContainer(for: [
            UserProfile.self,
            JournalEntry.self,
            CravingLog.self,
            MilestoneAchievement.self,
            SavingsGoal.self,
            ReasonToQuit.self,
            EmergencyContact.self,
            SelfAssessmentResult.self,
            TriggerZone.self,
            PreventedLossEntry.self
        ])
    }
}
