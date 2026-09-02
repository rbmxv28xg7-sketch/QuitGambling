import Foundation
import SwiftData

@Model
final class MilestoneAchievement {
    var milestoneDays: Int = 0
    var dateAchieved: Date = Date.now

    init(milestoneDays: Int, dateAchieved: Date = .now) {
        self.milestoneDays = milestoneDays
        self.dateAchieved = dateAchieved
    }
}
