import Foundation
import SwiftData

@Model
final class JournalEntry {
    var date: Date = Date.now
    var text: String = ""
    var mood: Int = 3
    var gratitude: String = ""
    var hadCravings: Bool = false
    var wasRelapse: Bool = false
    var moneyLost: Double = 0.0
    var tag: String = ""

    init(
        date: Date = .now,
        text: String = "",
        mood: Int = 3,
        gratitude: String = "",
        hadCravings: Bool = false,
        wasRelapse: Bool = false,
        moneyLost: Double = 0.0,
        tag: String = ""
    ) {
        self.date = date
        self.text = text
        self.mood = mood
        self.gratitude = gratitude
        self.hadCravings = hadCravings
        self.wasRelapse = wasRelapse
        self.moneyLost = moneyLost
        self.tag = tag
    }
}
