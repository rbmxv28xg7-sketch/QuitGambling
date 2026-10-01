import SwiftUI

// MARK: - Minigame Session Manager
// Keeps active game sessions alive across view lifecycles, app backgrounding,
// multitasking switcher gestures, and lock screen transitions.

@Observable
@MainActor
final class MemoryGameSession {
    enum Phase: Equatable {
        case memorizing
        case flipping
        case playing
        case completed
    }

    var isGameActive: Bool = false
    var phase: Phase = .memorizing
    var activeIndices: Set<Int> = []
    var revealedIndices: Set<Int> = []
    var countdownSeconds: Int = 5
    var tileAngles: [Double] = Array(repeating: 0.0, count: 25)
    var wrongTileIndex: Int? = nil
    var hasFirstTapped: Bool = false

    func reset() {
        isGameActive = false
        phase = .memorizing
        activeIndices.removeAll()
        revealedIndices.removeAll()
        countdownSeconds = 5
        tileAngles = Array(repeating: 0.0, count: 25)
        wrongTileIndex = nil
        hasFirstTapped = false
    }

    func startNewGame(totalTiles: Int = 25, targetCount: Int = 7) {
        var set = Set<Int>()
        while set.count < targetCount {
            set.insert(Int.random(in: 0..<totalTiles))
        }
        activeIndices = set
        revealedIndices.removeAll()
        tileAngles = Array(repeating: 0.0, count: totalTiles)
        wrongTileIndex = nil
        hasFirstTapped = false
        countdownSeconds = 5
        phase = .memorizing
        isGameActive = true
    }
}

@Observable
@MainActor
final class ConnectGameSession {
    struct ActivePair: Identifiable {
        let label: String
        let color: Color
        let start: Int
        let end: Int
        var id: String { label }
    }

    var isGameActive: Bool = false
    var activePairs: [ActivePair] = []
    var endpointMap: [Int: ActivePair] = [:]
    var connectedPaths: [String: [Int]] = [:]

    func reset() {
        isGameActive = false
        activePairs.removeAll()
        endpointMap.removeAll()
        connectedPaths.removeAll()
    }
}

@Observable
@MainActor
final class StroopGameSession {
    struct StroopColor: Identifiable, Equatable {
        let id: String
        let name: String
        let color: Color
    }

    var isGameActive: Bool = false
    var currentRound: Int = 1
    var currentWord: StroopColor? = nil
    var currentInk: StroopColor? = nil
    var displayedColors: [StroopColor] = []
    var remainingTime: TimeInterval = 3.0

    func reset() {
        isGameActive = false
        currentRound = 1
        currentWord = nil
        currentInk = nil
        displayedColors.removeAll()
        remainingTime = 3.0
    }
}

@Observable
@MainActor
final class MultiplicationGameSession {
    struct Question: Identifiable, Equatable {
        let id: UUID
        let a: Int
        let b: Int
        var answer: Int { a * b }

        init(a: Int, b: Int) {
            self.id = UUID()
            self.a = a
            self.b = b
        }
    }

    var isGameActive: Bool = false
    var questions: [Question] = []
    var currentQuestionIndex: Int = 0
    var userInputs: [String] = ["", "", ""]

    func reset() {
        isGameActive = false
        questions = []
        currentQuestionIndex = 0
        userInputs = ["", "", ""]
    }
}

@Observable
@MainActor
final class WordSearchGameSession {
    var isGameActive: Bool = false
    var currentWordIndex: Int = 0
    var selectedCells: [Int] = []
    var wordsToFind: [String] = ["RIGHT", "EIGHT", "BACK", "SWIFT", "THIN"].shuffled()

    func reset() {
        isGameActive = false
        currentWordIndex = 0
        selectedCells.removeAll()
        wordsToFind = ["RIGHT", "EIGHT", "BACK", "SWIFT", "THIN"].shuffled()
    }
}

@Observable
@MainActor
final class MinigameSessionManager {
    static let shared = MinigameSessionManager()

    var memory = MemoryGameSession()
    var connect = ConnectGameSession()
    var stroop = StroopGameSession()
    var multiplication = MultiplicationGameSession()
    var words = WordSearchGameSession()

    private init() {}

    func resetAll() {
        memory.reset()
        connect.reset()
        stroop.reset()
        multiplication.reset()
        words.reset()
    }
}
