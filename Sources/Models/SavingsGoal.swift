import Foundation
import SwiftData

@Model
final class SavingsGoal {
    var name: String = ""
    var targetAmount: Double = 0
    var icon: String = "star.fill"

    init(name: String, targetAmount: Double, icon: String = "star.fill") {
        self.name = name
        self.targetAmount = targetAmount
        self.icon = icon
    }
}
