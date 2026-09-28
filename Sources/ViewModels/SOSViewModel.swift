import SwiftUI

@Observable
@MainActor
class SOSViewModel {
    enum BreathingPhase: Int, CaseIterable {
        case inhale = 0
        case holdIn = 1
        case exhale = 2
        case holdOut = 3
    }
    
    var breathingPhase: BreathingPhase = .inhale
    var breathingProgress: Double = 0.0
    var isBreathingActive: Bool = false
    var cycleCount: Int = 0
    
    var urgeSurfingRemaining: Int = 900
    var isUrgeSurfingActive: Bool = false
    
    func startBreathing() {
        isBreathingActive = true
    }
    
    func stopBreathing() {
        isBreathingActive = false
        cycleCount = 0
        breathingPhase = .inhale
        breathingProgress = 0
    }
    
    func startUrgeSurfing() {
        isUrgeSurfingActive = true
    }
    
    func stopUrgeSurfing() {
        isUrgeSurfingActive = false
        urgeSurfingRemaining = 900
    }
    
    var groundingStep: Int = 1
    var groundingItems: [Int: [String]] = [:]

    func targetCount(for step: Int) -> Int {
        switch step {
        case 1: return 5
        case 2: return 4
        case 3: return 3
        case 4: return 2
        case 5: return 1
        default: return 0
        }
    }

    func items(for step: Int) -> [String] {
        groundingItems[step] ?? []
    }

    func addGroundingItem(_ item: String, for step: Int) {
        let trimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var list = groundingItems[step] ?? []
        list.append(trimmed)
        groundingItems[step] = list
    }

    func removeGroundingItem(at index: Int, for step: Int) {
        guard var list = groundingItems[step], index < list.count else { return }
        list.remove(at: index)
        groundingItems[step] = list
    }

    func nextGroundingStep() {
        if groundingStep <= 5 {
            groundingStep += 1
        }
    }

    func resetGrounding() {
        groundingStep = 1
        groundingItems = [:]
    }
}
