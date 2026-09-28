import SwiftUI
import LocalAuthentication
import AudioToolbox

enum CamouflageStyle: String, CaseIterable, Identifiable {
    case calculator = "Calculator"
    case notes = "Notes"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .calculator: return "plus.slash.minus"
        case .notes: return "note.text"
        }
    }
}

/// Service managing biometric app authentication (FaceID/TouchID), alternate app icons, and privacy camouflage mode.
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

    var selectedCamouflageStyle: CamouflageStyle {
        didSet {
            UserDefaults.standard.set(selectedCamouflageStyle.rawValue, forKey: "selectedCamouflageStyle")
        }
    }

    var camouflagePIN: String {
        didSet {
            UserDefaults.standard.set(camouflagePIN, forKey: "camouflagePIN")
        }
    }

    var isShakeToCamouflageEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isShakeToCamouflageEnabled, forKey: "isShakeToCamouflageEnabled")
            if isShakeToCamouflageEnabled {
                ShakeMotionService.shared.startMonitoring()
            } else {
                ShakeMotionService.shared.stopMonitoring()
            }
        }
    }

    var currentAlternateIcon: String? {
        didSet {
            UserDefaults.standard.set(currentAlternateIcon, forKey: "savedAlternateIconName")
        }
    }

    init() {
        let biometrics = UserDefaults.standard.bool(forKey: "isBiometricsEnabled")
        self.isBiometricsEnabled = biometrics
        self.isUnlocked = !biometrics

        let savedStyle = UserDefaults.standard.string(forKey: "selectedCamouflageStyle") ?? CamouflageStyle.calculator.rawValue
        self.selectedCamouflageStyle = CamouflageStyle(rawValue: savedStyle) ?? .calculator

        self.camouflagePIN = UserDefaults.standard.string(forKey: "camouflagePIN") ?? "1234"

        let shakeEnabled: Bool
        if UserDefaults.standard.object(forKey: "isShakeToCamouflageEnabled") == nil {
            shakeEnabled = true
        } else {
            shakeEnabled = UserDefaults.standard.bool(forKey: "isShakeToCamouflageEnabled")
        }
        self.isShakeToCamouflageEnabled = shakeEnabled

        self.currentAlternateIcon = UIApplication.shared.alternateIconName ?? UserDefaults.standard.string(forKey: "savedAlternateIconName")

        if shakeEnabled {
            ShakeMotionService.shared.startMonitoring()
        }
    }

    func authenticate() async {
        _ = await performAuthentication()
    }

    func performAuthentication() async -> Bool {
        guard isBiometricsEnabled else {
            isUnlocked = true
            return true
        }

        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Unlock Quit Gambling for your personal safety and privacy."
            do {
                let success = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
                if success {
                    isUnlocked = true
                    return true
                }
            } catch {
                isUnlocked = false
                return false
            }
        } else {
            isUnlocked = true
            return true
        }
        return false
    }

    private var isPro: Bool {
        UserDefaults.standard.bool(forKey: "isProSubscribed")
    }

    func lockApp() {
        guard isPro else { return }
        if isBiometricsEnabled {
            isUnlocked = false
        }
    }

    func toggleCamouflage() {
        if !isCamouflageActive && !isPro {
            return
        }
        withAnimation(Design.Anim.normal) {
            isCamouflageActive.toggle()
        }
    }

    func activateCamouflage() {
        guard isPro else { return }
        withAnimation(Design.Anim.normal) {
            isCamouflageActive = true
        }
    }

    func dismissCamouflage() {
        withAnimation(Design.Anim.normal) {
            isCamouflageActive = false
        }
    }

    /// Change the iOS Home Screen alternate app icon (nil for default)
    func setAlternateAppIcon(_ iconName: String?) async {
        if iconName != nil && !isPro {
            return
        }
        guard UIApplication.shared.supportsAlternateIcons else {
            print("[PrivacyManager] UIApplication.shared.supportsAlternateIcons is false!")
            return
        }
        do {
            try await UIApplication.shared.setAlternateIconName(iconName)
            self.currentAlternateIcon = iconName
        } catch {
            print("[PrivacyManager] Failed to set alternate icon: \(error.localizedDescription)")
        }
    }
}

// MARK: - Shake Detection Notification

extension NSNotification.Name {
    static let deviceDidShakeNotification = NSNotification.Name("QuitGamblingDeviceDidShakeNotification")
}

