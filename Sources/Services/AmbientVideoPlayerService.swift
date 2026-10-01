import Foundation
import AVFoundation
import UIKit

/// Global singleton service managing a single, continuous, unified ambient video playback.
/// Ensures the video background is 100% in sync across all tabs, sheets, and transitions without restarting.
@MainActor
final class AmbientVideoPlayerService {
    static let shared = AmbientVideoPlayerService()

    let player: AVQueuePlayer
    private var playerLooper: AVPlayerLooper?

    private init() {
        guard let url = Bundle.main.url(forResource: "Timeline 1", withExtension: "mp4") ??
                        Bundle.main.url(forResource: "BackgroundVideo", withExtension: "mp4") else {
            self.player = AVQueuePlayer()
            return
        }

        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)

        // AVQueuePlayer MUST be initialized empty before creating AVPlayerLooper
        let queuePlayer = AVQueuePlayer()
        queuePlayer.isMuted = true
        queuePlayer.actionAtItemEnd = .none
        queuePlayer.preventsDisplaySleepDuringVideoPlayback = false

        // Hardware-accelerated seamless looping
        self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        self.player = queuePlayer

        queuePlayer.defaultRate = 0.65
        queuePlayer.play()
    }

    func resume() {
        if player.timeControlStatus != .playing {
            player.defaultRate = 0.65
            player.play()
        }
    }
}
