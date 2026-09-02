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
            return "Kein Risikoverhalten"
        case 1...2:
            return "Geringes Risiko"
        case 3...7:
            return "Mäßiges Risiko"
        default:
            return "Problematisches Spielverhalten"
        }
    }

    var recommendation: String {
        switch score {
        case 0:
            return "Dein Spielverhalten zeigt derzeit keine Anzeichen für ein problematisches Muster. Bleibe weiterhin achtsam."
        case 1...2:
            return "Es gibt leichte Anzeichen für riskantes Verhalten. Nutze die Tracker- und Reflexionsfunktionen, um deine Gewohnheiten im Blick zu behalten."
        case 3...7:
            return "Dein Spielverhalten weist auf ein mäßiges Risikomuster hin, das zu Problemen führen kann. Wir empfehlen, feste Sperren (wie OASIS) und tägliche Pledges zu nutzen."
        default:
            return "Dein Testergebnis deutet auf ein problematisches Glücksspielmuster hin. Zögere nicht, sofortige Unterstützung über die BZgA-Hotline oder eine Beratungsstelle in Anspruch zu nehmen."
        }
    }

    init(date: Date = .now, score: Int = 0, answers: [Int] = [], notes: String = "") {
        self.date = date
        self.score = score
        self.answers = answers
        self.notes = notes
    }
}
