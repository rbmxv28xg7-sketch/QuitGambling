import Foundation
import SwiftData

/// Records a specific, acute gambling impulse that was successfully prevented (e.g. avoided depositing €100 during an urge).
@Model
final class PreventedLossEntry: Identifiable {
    var id: UUID = UUID()
    var date: Date = Date.now
    var amount: Double = 0
    var note: String = ""
    var contextTag: String = "Manuell"

    init(id: UUID = UUID(), date: Date = .now, amount: Double = 0, note: String = "", contextTag: String = "Manuell") {
        self.id = id
        self.date = date
        self.amount = amount
        self.note = note
        self.contextTag = contextTag
    }
}
