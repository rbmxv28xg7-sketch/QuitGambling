import SwiftUI
import UIKit
import AudioToolbox
import CoreHaptics

/// High-resolution, multi-tier haptic feedback engine designed specifically for mindful addiction recovery.
/// Combines Apple's UIKit Taptic Engine with CoreHaptics for guaranteed physical vibrations
/// across all iOS devices, silent mode, and rapid drag interactions.
@Observable
@MainActor
final class SensoryFeedbackService {
    static let shared = SensoryFeedbackService()

    var isHapticsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isHapticsEnabled, forKey: "app_haptics_enabled")
        }
    }

    // CoreHaptics direct hardware engine
    private var hapticEngine: CHHapticEngine?
    private var isEngineReady: Bool = false

    // UIKit Taptic Engine Generators (Guaranteed physical tactile response)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let notificationFeedback = UINotificationFeedbackGenerator()

    init() {
        UserDefaults.standard.register(defaults: ["app_haptics_enabled": true])
        let saved = UserDefaults.standard.object(forKey: "app_haptics_enabled") as? Bool ?? true
        self.isHapticsEnabled = saved
        prepareGenerators()
        setupCoreHaptics()
    }

    func prepareGenerators() {
        selectionFeedback.prepare()
        lightImpact.prepare()
        mediumImpact.prepare()
        rigidImpact.prepare()
        softImpact.prepare()
        heavyImpact.prepare()
        notificationFeedback.prepare()
    }

    // MARK: - CoreHaptics Setup

    private func setupCoreHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            let engine = try CHHapticEngine()
            engine.isAutoShutdownEnabled = true
            engine.resetHandler = { [weak self] in
                Task { @MainActor [weak self] in
                    try? self?.hapticEngine?.start()
                }
            }
            engine.stoppedHandler = { _ in }
            try engine.start()
            self.hapticEngine = engine
            self.isEngineReady = true
        } catch {
            print("SensoryFeedbackService: CoreHaptics init error: \(error)")
        }
    }

    private func ensureEngineActive() -> Bool {
        guard let engine = hapticEngine else { return false }
        do {
            try engine.start()
            return true
        } catch {
            return false
        }
    }

    private func playCoreHapticTransient(intensity: Float, sharpness: Float) {
        guard isHapticsEnabled, ensureEngineActive(), let engine = hapticEngine else { return }
        do {
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: 0
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            // Silently fall back to UIKit
        }
    }

    // MARK: - Mindful Tactile Patterns (Universal Coverage)

    /// Taktiler Klick bei der Auswahl von Stimmungs-Pills, Tabs, NavigationLinks und Chips.
    func selectionClick() {
        guard isHapticsEnabled else { return }
        selectionFeedback.selectionChanged()
        selectionFeedback.prepare()
    }

    /// Feiner Klick beim Antippen von Buttons und interaktiven Elementen.
    func buttonTap() {
        guard isHapticsEnabled else { return }
        lightImpact.impactOccurred(intensity: 0.75)
        lightImpact.prepare()
    }

    /// Spürbarer Klick beim Antippen von Kacheln und Cards.
    func cardTap() {
        guard isHapticsEnabled else { return }
        mediumImpact.impactOccurred(intensity: 0.75)
        mediumImpact.prepare()
    }

    /// Feiner, spürbarer Klick bei Toggle- und Schalter-Bedienung.
    func toggleChanged() {
        guard isHapticsEnabled else { return }
        rigidImpact.impactOccurred(intensity: 0.85)
        rigidImpact.prepare()
    }

    /// Tief beruhigende Haptik-Sequenz beim täglichen Versprechen (Daily Pledge).
    func pledgeConfirmed() {
        guard isHapticsEnabled else { return }
        heavyImpact.impactOccurred(intensity: 1.0)
        Task {
            try? await Task.sleep(for: .milliseconds(140))
            self.notificationFeedback.notificationOccurred(.success)
            self.notificationFeedback.prepare()
        }
    }

    /// Bestätigung beim Speichern der 15-Sekunden Tages-Reflexion.
    func checkInSaved() {
        guard isHapticsEnabled else { return }
        notificationFeedback.notificationOccurred(.success)
        notificationFeedback.prepare()
    }

    /// Subtiler, organischer Atemimpuls beim Phasenwechsel der Box-Atmung.
    func breathingPhasePulse() {
        guard isHapticsEnabled else { return }
        softImpact.impactOccurred(intensity: 0.95)
        softImpact.prepare()
    }

    /// Kräftiger, sofort erdender Stoßimpuls bei der 15-Sekunden Notbremse im SOS-Koffer.
    func emergencyBrakeTriggered() {
        guard isHapticsEnabled else { return }
        heavyImpact.impactOccurred(intensity: 1.0)
        heavyImpact.prepare()
    }

    /// Meilenstein-Freischaltung mit spürbarem Sieges-Doppelklick.
    func milestoneAchieved() {
        guard isHapticsEnabled else { return }
        notificationFeedback.notificationOccurred(.success)
        heavyImpact.impactOccurred(intensity: 1.0)
        notificationFeedback.prepare()
        heavyImpact.prepare()
    }

    /// Feierlicher taktiler Erfolgsimpuls bei abgeschlossenen Beruhigungs- und Achtsamkeitsübungen.
    func successFeedback() {
        guard isHapticsEnabled else { return }
        notificationFeedback.notificationOccurred(.success)
        notificationFeedback.prepare()
    }

    /// Spürbarer Fehler- oder Warnimpuls bei falscher Eingabe oder Fehlschlag.
    func errorFeedback() {
        guard isHapticsEnabled else { return }
        notificationFeedback.notificationOccurred(.error)
        notificationFeedback.prepare()
    }

    // MARK: - Mindful Minigame Haptics (Connect, Memory, Stroop, Math)

    /// Feine, extrem reaktionsschnelle Haptik bei JEDEM einzelnen Feld im Connect-Minispiel.
    func connectGridStep() {
        guard isHapticsEnabled else { return }
        lightImpact.impactOccurred(intensity: 0.75)
        lightImpact.prepare()
    }

    /// Feiner, präziser taktiler Klick beim Antippen einer Kachel, eines Buchstabens oder einer Zifferntaste im Minispiel.
    func minigameTap() {
        guard isHapticsEnabled else { return }
        rigidImpact.impactOccurred(intensity: 0.9)
        rigidImpact.prepare()
    }

    /// Dezenter, befriedigender Klick bei einem Teilerfolg (z. B. Buchstabenpaar verbunden, Aufgabe gelöst, richtige Kachel).
    func minigameStepSuccess() {
        guard isHapticsEnabled else { return }
        mediumImpact.impactOccurred(intensity: 1.0)
        mediumImpact.prepare()
    }

    /// Feiner, sanfter Hinweisimpuls bei Fehlschlag oder falscher Eingabe (Doppel-Klick).
    func minigameSubtleMistake() {
        guard isHapticsEnabled else { return }
        rigidImpact.impactOccurred(intensity: 0.95)
        Task {
            try? await Task.sleep(for: .milliseconds(70))
            self.rigidImpact.impactOccurred(intensity: 0.6)
            self.rigidImpact.prepare()
        }
    }

    /// Befriedigender Abschlussimpuls bei gewonnenem Minispiel.
    func minigameGameWon() {
        guard isHapticsEnabled else { return }
        notificationFeedback.notificationOccurred(.success)
        heavyImpact.impactOccurred(intensity: 1.0)
        notificationFeedback.prepare()
        heavyImpact.prepare()
    }

    /// Ernstes, achtsames Haptik-Signal beim Erfassen eines Rückfalls.
    func relapseRecorded() {
        guard isHapticsEnabled else { return }
        notificationFeedback.notificationOccurred(.warning)
        heavyImpact.impactOccurred(intensity: 0.9)
        notificationFeedback.prepare()
        heavyImpact.prepare()
    }
}
