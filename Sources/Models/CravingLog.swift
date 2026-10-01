import Foundation
import SwiftData

@Model
final class CravingLog {
    var date: Date = Date.now
    var intensity: Int = 5
    var trigger: String = ""
    var mood: Int = 3
    var notes: String = ""
    var wasRelapse: Bool = false

    init(date: Date = .now, intensity: Int = 5, trigger: String = "", mood: Int = 3, notes: String = "", wasRelapse: Bool = false) {
        self.date = date
        self.intensity = intensity
        self.trigger = trigger
        self.mood = mood
        self.notes = notes
        self.wasRelapse = wasRelapse
    }
}
