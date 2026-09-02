import SwiftUI
import LocalAuthentication

/// Service managing biometric app authentication (FaceID/TouchID) and privacy camouflage mode.
@Observable
@MainActor
final class PrivacyManager {
    var isUnlocked: Bool = true
    var isBiometricsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isBiometricsEnabled, forKey: "isBiometricsEnabled")
            if isBiometricsEnabled {
                isUnlocked = true
            }
        }
    }
    var isCamouflageActive: Bool = false

    init() {
        self.isBiometricsEnabled = UserDefaults.standard.bool(forKey: "isBiometricsEnabled")
        // If biometrics are enabled, start in locked state
        if UserDefaults.standard.bool(forKey: "isBiometricsEnabled") {
            self.isUnlocked = false
        } else {
            self.isUnlocked = true
        }
    }

    func authenticate() async {
        guard isBiometricsEnabled else {
            isUnlocked = true
            return
        }

        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Entsperre FreiSpiel für deine persönliche Sicherheit und Privatsphäre."
            do {
                let success = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
                if success {
                    isUnlocked = true
                }
            } catch {
                isUnlocked = false
            }
        } else {
            // Fallback if no biometrics/passcode are available on the device
            isUnlocked = true
        }
    }

    func lockApp() {
        if isBiometricsEnabled {
            isUnlocked = false
        }
    }

    func toggleCamouflage() {
        withAnimation(Design.Anim.normal) {
            isCamouflageActive.toggle()
        }
    }
}
