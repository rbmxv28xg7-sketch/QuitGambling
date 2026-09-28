import SwiftUI

/// Animated visual representing the user's recovery progress as a living, gently swaying plant or tree.
struct GrowingPlantView: View {
    let daysClean: Int
    var size: CGFloat = 80

    @State private var swayAngle: Double = -3.0
    @State private var breatheScale: Double = 0.98

    @MainActor
    enum PlantStage {
        case seed       // 0-2 days
        case sprout     // 3-13 days
        case sapling    // 14-29 days
        case oakTree    // 30-179 days
        case crownTree  // 180+ days

        var iconName: String {
            switch self {
            case .seed: return "leaf.circle.fill"
            case .sprout: return "leaf.fill"
            case .sapling: return "tree.fill"
            case .oakTree: return "tree.fill"
            case .crownTree: return "crown.fill"
            }
        }

        var stageLabel: String {
            switch self {
            case .seed: return "New Seedling"
            case .sprout: return "Tender Sprout"
            case .sapling: return "Young Sapling"
            case .oakTree: return "Strong Oak"
            case .crownTree: return "Flourishing Tree"
            }
        }

        var primaryColor: Color {
            switch self {
            case .seed: return Design.Colors.primaryLight
            case .sprout: return Design.Colors.primary
            case .sapling: return Design.Colors.primary
            case .oakTree: return Design.Colors.secondary
            case .crownTree: return Design.Colors.gold
            }
        }
    }

    private var stage: PlantStage {
        switch daysClean {
        case 0...2: return .seed
        case 3...13: return .sprout
        case 14...29: return .sapling
        case 30...179: return .oakTree
        default: return .crownTree
        }
    }

    var body: some View {
        VStack(spacing: Design.Spacing.xs) {
            ZStack {
                // Soft glowing ambient background aura
                Circle()
                    .fill(stage.primaryColor.opacity(0.18))
                    .frame(width: size * 1.25, height: size * 1.25)
                    .scaleEffect(breatheScale)
                    .blur(radius: 8)

                // Living Plant Shape
                Group {
                    switch stage {
                    case .seed:
                        seedVisual
                    case .sprout:
                        sproutVisual
                    case .sapling:
                        saplingVisual
                    case .oakTree:
                        oakTreeVisual
                    case .crownTree:
                        crownTreeVisual
                    }
                }
                .rotationEffect(.degrees(swayAngle), anchor: .bottom)
                .scaleEffect(breatheScale)
            }
            .frame(width: size * 1.3, height: size * 1.3)

            Text(stage.stageLabel)
                .font(.caption2)
                .bold()
                .foregroundStyle(stage.primaryColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(stage.primaryColor.opacity(0.12))
                .clipShape(.capsule)
        }
        .task {
            // Gentle continuous wind swaying and breathing
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                swayAngle = 3.0
            }
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                breatheScale = 1.04
            }
        }
    }

    // MARK: - Stage Visuals

    private var seedVisual: some View {
        Image(systemName: "leaf.circle.fill")
            .font(.system(size: size * 0.75))
            .foregroundStyle(
                LinearGradient(
                    colors: [Design.Colors.primaryLight, Design.Colors.primary],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }

    private var sproutVisual: some View {
        HStack(spacing: -8) {
            Image(systemName: "leaf.fill")
                .font(.system(size: size * 0.6))
                .foregroundStyle(Design.Colors.primary)
                .rotationEffect(.degrees(-18))
            Image(systemName: "leaf.fill")
                .font(.system(size: size * 0.7))
                .foregroundStyle(Design.Colors.primaryLight)
                .rotationEffect(.degrees(22))
        }
    }

    private var saplingVisual: some View {
        Image(systemName: "tree.fill")
            .font(.system(size: size * 0.85))
            .foregroundStyle(
                LinearGradient(
                    colors: [Design.Colors.primaryLight, Design.Colors.primary],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }

    private var oakTreeVisual: some View {
        ZStack {
            Image(systemName: "tree.fill")
                .font(.system(size: size * 0.95))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Design.Colors.primary, Design.Colors.secondary],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Image(systemName: "leaf.fill")
                .font(.system(size: size * 0.3))
                .foregroundStyle(Design.Colors.gold.opacity(0.8))
                .offset(x: 10, y: -15)
        }
    }

    private var crownTreeVisual: some View {
        ZStack {
            Image(systemName: "tree.fill")
                .font(.system(size: size * 0.95))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Design.Colors.gold, Design.Colors.primary],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ambientShimmer()

            Image(systemName: "sparkles")
                .font(.system(size: size * 0.4))
                .foregroundStyle(Design.Colors.gold)
                .offset(y: -size * 0.35)
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        GrowingPlantView(daysClean: 1)
        GrowingPlantView(daysClean: 7)
        GrowingPlantView(daysClean: 21)
        GrowingPlantView(daysClean: 45)
        GrowingPlantView(daysClean: 200)
    }
    .padding()
}
