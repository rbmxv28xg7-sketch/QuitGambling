import Foundation
import SwiftData

@Model
final class ReasonToQuit {
    var text: String = ""
    var createdDate: Date = Date.now

    init(text: String, createdDate: Date = .now) {
        self.text = text
        self.createdDate = createdDate
    }
}
