import SwiftUI
import SwiftData
import NetworkExtension

@main
struct QuitGamblingApp: App {


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
