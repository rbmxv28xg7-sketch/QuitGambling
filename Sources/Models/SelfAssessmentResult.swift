import Foundation
import SwiftData

/// Model storing the result of a Problem Gambling Severity Index (PGSI) self-assessment.
@Model
final class SelfAssessmentResult: Identifiable {
    var date: Date = Date.now
    var score: Int = 0
    var answers: [Int] = []
    var notes: String = ""

    var riskCategory: String {
        switch score {
        case 0:
            return "Non-problem gambling"
        case 1...2:
            return "Low risk"
        case 3...7:
            return "Moderate risk"
        default:
            return "Problem gambling"
        }
    }

    var recommendation: String {
        switch score {
        case 0:
            return "Your habits show no signs of problem gambling. Continue staying mindful and focused on your goals."
        case 1...2:
            return "There are mild indicators of risk. Use the daily tracker and reflections to stay in control of your habits."
        case 3...7:
            return "Your responses indicate moderate risk that may lead to difficulty. We recommend activating full shield blocks and daily pledges."
        default:
            return "Your score indicates problem gambling patterns. Please reach out to confidential support resources or call a gambling helpline (see Help)."
        }
    }

    init(date: Date = .now, score: Int = 0, answers: [Int] = [], notes: String = "") {
        self.date = date
        self.score = score
        self.answers = answers
        self.notes = notes
    }
}
