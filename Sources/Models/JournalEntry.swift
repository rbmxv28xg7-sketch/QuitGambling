import Foundation
import SwiftData

@Model
final class JournalEntry {
    var date: Date = Date.now
    var text: String = ""
    var mood: Int = 3
    var gratitude: String = ""
    var hadCravings: Bool = false

    init(date: Date = .now, text: String = "", mood: Int = 3, gratitude: String = "", hadCravings: Bool = false) {
        self.date = date
        self.text = text
        self.mood = mood
        self.gratitude = gratitude
        self.hadCravings = hadCravings
    }
}
