import SwiftUI

/// Seamless looping video background with an organic, dreamy optical blur.
/// Eliminates muddy gray layers, allowing the rich amber, terracotta, and mahogany glow to radiate directly.
struct FlutedGlassBackgroundView: View {
    @State private var themeManager = ThemeManager.shared

    var body: some View {
        let isMonochrome = themeManager.selectedColorway.isMonochrome

        ZStack {
            if isMonochrome {
                // MARK: - Clean Monochrome (White & Gray)
                Color(red: 0.07, green: 0.08, blue: 0.10)
                    .ignoresSafeArea()

                LoopingVideoPlayerView()
                    .saturation(0.0)
                    .blur(radius: 14)
                    .ignoresSafeArea()

                RadialGradient(
                    colors: [
                        Color(red: 0.22, green: 0.24, blue: 0.28).opacity(0.85),
                        Color(red: 0.14, green: 0.15, blue: 0.18).opacity(0.40),
                        .clear
                    ],
                    center: .bottomTrailing,
                    startRadius: 40,
                    endRadius: 520
                )
                .ignoresSafeArea()

                Rectangle()
                    .fill(.ultraThinMaterial.opacity(0.35))
                    .overlay(
                        Color.white.opacity(0.04)
                    )
                    .ignoresSafeArea()

                RadialGradient(
                    colors: [
                        Color.black.opacity(0.08),
                        Color.black.opacity(0.22),
                        Color.black.opacity(0.55)
                    ],
                    center: .center,
                    startRadius: 160,
                    endRadius: 580
                )
                .ignoresSafeArea()
            } else {
                // MARK: - Vibrant Harmonious Colorways
                Color.black
                    .ignoresSafeArea()

                LoopingVideoPlayerView()
                    .hueRotation(themeManager.selectedColorway.hueRotation)
                    .blur(radius: 14)
                    .ignoresSafeArea()

                RadialGradient(
                    colors: [
                        themeManager.selectedColorway.tertiary.opacity(0.85),
                        themeManager.selectedColorway.tertiary.opacity(0.40),
                        .clear
                    ],
                    center: .bottomTrailing,
                    startRadius: 40,
                    endRadius: 520
                )
                .blendMode(.color)
                .ignoresSafeArea()

                Rectangle()
                    .fill(.ultraThinMaterial.opacity(0.36))
                    .overlay {
                        themeManager.selectedColorway.ambientTint
                            .opacity(0.10)
                            .blendMode(.color)
                    }
                    .ignoresSafeArea()

                RadialGradient(
                    colors: [
                        Color.black.opacity(0.12),
                        Color.black.opacity(0.25),
                        Color.black.opacity(0.60)
                    ],
                    center: .center,
                    startRadius: 160,
                    endRadius: 580
                )
                .ignoresSafeArea()
            }
        }
        .animation(Design.Anim.spring, value: themeManager.selectedColorway.id)
    }
}

#Preview {
    FlutedGlassBackgroundView()
}
