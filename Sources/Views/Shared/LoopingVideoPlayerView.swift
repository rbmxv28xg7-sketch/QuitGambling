import SwiftUI
import AVKit
import AVFoundation

/// High-performance video player view connecting directly to the globally synced AmbientVideoPlayerService.
/// Guarantees that the video background is 100% continuous, fluid, and identical across every single screen and tab swipe.
struct LoopingVideoPlayerView: UIViewRepresentable {
    var name: String = "Timeline 1"
    var ext: String = "mp4"
    var rate: Float = 0.65

    init(name: String = "Timeline 1", ext: String = "mp4", rate: Float = 0.65) {
        self.name = name
        self.ext = ext
        self.rate = rate
    }

    func makeUIView(context: Context) -> LoopingPlayerUIView {
        let view = LoopingPlayerUIView()
        AmbientVideoPlayerService.shared.resume()
        return view
    }

    func updateUIView(_ uiView: LoopingPlayerUIView, context: Context) {
        AmbientVideoPlayerService.shared.resume()
    }
}

final class LoopingPlayerUIView: UIView {
    override static var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        playerLayer.player = AmbientVideoPlayerService.shared.player
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.isOpaque = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            AmbientVideoPlayerService.shared.resume()
        }
    }
}
