import Foundation
import AVFoundation

/// Service for ambient soundscapes during mindfulness exercises (e.g., Box-Breathing & Urge Surfing).
/// Provides continuous, seamless looping of soothing oceanic waves and flowing water with zero lag.
@MainActor
final class AmbientSoundService {
    static let shared = AmbientSoundService()

    // MARK: - Box Breathing (Ocean Waves)
    private var audioPlayer: AVAudioPlayer?
    var targetVolume: Float = 1.0

    // MARK: - Urge Surfing (Gentle Water Stream)
    private var urgeSurfingPlayer: AVAudioPlayer?
    var urgeSurfingTargetVolume: Float = 0.55

    private init() {
        // Do not activate audio session at launch to avoid suppressing Taptic Engine / haptics.
    }

    func configureAudioSession() {
        do {
            // .playback ensures sound is heard even if iPhone hardware silent switch is active
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try? session.setAllowHapticsAndSystemSoundsDuringRecording(true)
            try session.setActive(true)
        } catch {
            print("AmbientSoundService: Audio session configuration failed: \(error)")
        }
    }

    // MARK: - Box-Breathing Ocean Controls

    private func preparePlayer() {
        guard let url = Bundle.main.url(forResource: "sound_ocean", withExtension: "m4a") ??
                        Bundle.main.url(forResource: "sound_3_ocean_wave", withExtension: "m4a") else {
            print("AmbientSoundService: Could not locate ocean audio track in main bundle")
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1 // Seamless infinite hardware loop
            player.prepareToPlay()
            self.audioPlayer = player
        } catch {
            print("AmbientSoundService: Failed to initialize AVAudioPlayer: \(error)")
        }
    }

    /// Starts playing the ocean breathing sound smoothly aligned with the breathing start.
    func startBreathingSound(isMuted: Bool) {
        configureAudioSession()

        if audioPlayer == nil {
            preparePlayer()
        }
        guard let player = audioPlayer else { return }

        player.currentTime = 0.0
        player.numberOfLoops = -1
        player.volume = isMuted ? 0.0 : targetVolume
        player.play()
    }

    /// Fades out the sound smoothly and pauses playback.
    func stopBreathingSound() {
        guard let player = audioPlayer, player.isPlaying else { return }
        player.setVolume(0.0, fadeDuration: 0.8)
        Task {
            try? await Task.sleep(for: .seconds(0.85))
            if self.audioPlayer?.volume == 0.0 {
                self.audioPlayer?.pause()
                try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
            }
        }
    }

    /// Toggles mute dynamically without interrupting playback timing.
    func setMuted(_ muted: Bool, isBreathingActive: Bool) {
        guard let player = audioPlayer else { return }

        if isBreathingActive {
            if !player.isPlaying {
                player.play()
            }
            player.volume = muted ? 0.0 : targetVolume
        } else {
            player.setVolume(0.0, fadeDuration: 0.2)
        }
    }

    // MARK: - Urge Surfing Water Controls

    private func prepareUrgeSurfingPlayer() {
        guard let url = Bundle.main.url(forResource: "sound_urge_waves", withExtension: "m4a") ??
                        Bundle.main.url(forResource: "sound_ocean", withExtension: "m4a") else {
            print("AmbientSoundService: Could not locate sound_urge_waves in main bundle")
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1 // Seamless infinite hardware loop
            player.prepareToPlay()
            self.urgeSurfingPlayer = player
        } catch {
            print("AmbientSoundService: Failed to initialize AVAudioPlayer for urge surfing: \(error)")
        }
    }

    /// Starts playing the water soundscape for Urge Surfing.
    func startUrgeSurfingSound(isMuted: Bool) {
        configureAudioSession()

        if urgeSurfingPlayer == nil {
            prepareUrgeSurfingPlayer()
        }
        guard let player = urgeSurfingPlayer else { return }

        player.currentTime = 0.0
        player.numberOfLoops = -1
        player.volume = isMuted ? 0.0 : urgeSurfingTargetVolume
        player.play()
    }

    /// Pauses the water sound smoothly when the wave is paused.
    func pauseUrgeSurfingSound() {
        guard let player = urgeSurfingPlayer, player.isPlaying else { return }
        player.setVolume(0.0, fadeDuration: 0.4)
        Task {
            try? await Task.sleep(for: .seconds(0.45))
            if self.urgeSurfingPlayer?.volume == 0.0 {
                self.urgeSurfingPlayer?.pause()
            }
        }
    }

    /// Resumes the water sound smoothly when the wave is continued.
    func resumeUrgeSurfingSound(isMuted: Bool) {
        configureAudioSession()
        guard let player = urgeSurfingPlayer else {
            startUrgeSurfingSound(isMuted: isMuted)
            return
        }
        if !player.isPlaying {
            player.play()
        }
        player.setVolume(isMuted ? 0.0 : urgeSurfingTargetVolume, fadeDuration: 0.4)
    }

    /// Stops the water sound and resets playback position.
    func stopUrgeSurfingSound() {
        guard let player = urgeSurfingPlayer, player.isPlaying else { return }
        player.setVolume(0.0, fadeDuration: 0.6)
        Task {
            try? await Task.sleep(for: .seconds(0.65))
            if self.urgeSurfingPlayer?.volume == 0.0 {
                self.urgeSurfingPlayer?.pause()
                self.urgeSurfingPlayer?.currentTime = 0.0
                try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
            }
        }
    }

    /// Toggles mute for Urge Surfing dynamically.
    func setUrgeSurfingMuted(_ muted: Bool, isSurfingActive: Bool) {
        guard let player = urgeSurfingPlayer else { return }

        if isSurfingActive {
            if !player.isPlaying {
                player.play()
            }
            player.volume = muted ? 0.0 : urgeSurfingTargetVolume
        } else {
            player.setVolume(0.0, fadeDuration: 0.2)
        }
    }
}
