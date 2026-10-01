import SwiftUI

/// Opal-inspired glowing 3D Freedom Gem with multi-layer geometric crystal facets and dynamic particle radiance.
struct FreedomGemView: View {
    let score: Int
    var size: CGFloat = 110

    @State private var glowRotation: Double = 0.0
    @State private var pulseScale: Double = 1.0

    private var gemGradient: [Color] {
        switch score {
        case 90...100:
            return [Design.Colors.gold, Color.yellow, Color.white]
        case 75...89:
            return [Design.Colors.primary, Design.Colors.primaryLight, Color.mint]
        case 50...74:
            return [Design.Colors.primaryLight, Design.Colors.secondary, Color.teal]
        default:
            return [Design.Colors.secondary, Design.Colors.accent, Color.orange]
        }
    }

    private var coreColor: Color {
        gemGradient.first ?? Design.Colors.primary
    }

    var body: some View {
        ZStack {
            // Ambient Radial Glow Rays
            Circle()
                .fill(
                    AngularGradient(
                        colors: [
                            coreColor.opacity(0.35),
                            .clear,
                            coreColor.opacity(0.25),
                            .clear,
                            coreColor.opacity(0.35)
                        ],
                        center: .center
                    )
                )
                .frame(width: size * 1.5, height: size * 1.5)
                .rotationEffect(.degrees(glowRotation))
                .blur(radius: 12)

            // Outer Soft Aura Ring
            Circle()
                .fill(coreColor.opacity(0.18))
                .frame(width: size * 1.25, height: size * 1.25)
                .scaleEffect(pulseScale)
                .blur(radius: 8)

            // Inner Crystal Facet Shape
            ZStack {
                // Background Base Rhombus/Gem
                Image(systemName: "suit.diamond.fill")
                    .font(.system(size: size * 0.95))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gemGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: coreColor.opacity(0.5), radius: 12, y: 4)

                // Top Facet Highlight
                Image(systemName: "suit.diamond")
                    .font(.system(size: size * 0.95))
                    .foregroundStyle(.white.opacity(0.45))
                    .blendMode(.overlay)

                // Central Sparkle / Star Core
                VStack(spacing: 0) {
                    Image(systemName: "sparkle")
                        .font(.system(size: size * 0.35))
                        .foregroundStyle(.white)
                        .shadow(color: .white.opacity(0.8), radius: 4)

                    Text("\(score)")
                        .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                        .contentTransition(.numericText())
                }
            }
            .scaleEffect(pulseScale)
            .ambientShimmer(isActive: true, duration: 2.2, delay: 3.0)
        }
        .frame(width: size * 1.4, height: size * 1.4)
        .task {
            withAnimation(.linear(duration: 20.0).repeatForever(autoreverses: false)) {
                glowRotation = 360.0
            }
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        FreedomGemView(score: 45)
        FreedomGemView(score: 78)
        FreedomGemView(score: 95)
    }
    .padding()
    .background(Design.Colors.background)
}
