import SwiftUI
import SwiftData

@main
struct FreiSpielApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            UserProfile.self,
            JournalEntry.self,
            CravingLog.self,
            MilestoneAchievement.self,
            SavingsGoal.self,
            ReasonToQuit.self,
            EmergencyContact.self,
            SelfAssessmentResult.self
        ])
    }
}
