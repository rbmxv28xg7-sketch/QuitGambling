import SwiftUI

@Observable
@MainActor
class SOSViewModel {
    enum BreathingPhase {
        case inhale, holdIn, exhale, holdOut
    }
    
    var breathingPhase: BreathingPhase = .inhale
    var breathingProgress: Double = 0.0
    var isBreathingActive: Bool = false
    var cycleCount: Int = 0
    
    var urgeSurfingRemaining: Int = 900
    var isUrgeSurfingActive: Bool = false
    
    var groundingStep: Int = 1
    
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
    
    func nextGroundingStep() {
        if groundingStep < 5 {
            groundingStep += 1
        }
    }
    
    func resetGrounding() {
        groundingStep = 1
    }
}
