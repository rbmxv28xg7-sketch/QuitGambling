import SwiftUI
import UIKit

// MARK: - Color Interpolation Helper
extension Color {
    func blend(to target: Color, fraction: Double) -> Color {
        let f = CGFloat(min(max(fraction, 0.0), 1.0))
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        UIColor(self).getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        UIColor(target).getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return Color(
            red: Double(r1 + (r2 - r1) * f),
            green: Double(g1 + (g2 - g1) * f),
            blue: Double(b1 + (b2 - b1) * f),
            opacity: Double(a1 + (a2 - a1) * f)
        )
    }
}

/// Animated Zen Companion Spirit for FreiSpiel.
/// Replaces the circle with an expressive, floating character based on the user's reference.
/// Features smooth 120 FPS continuous morphing between all 5 moods with fluid color blending,
/// organic dual-axis floating & swaying, living blinks, and interactive touch response.
struct ZenCompanionView: View {
    var moodProgress: Double // Continuous 1.0 to 5.0 for buttery-smooth transitions
    var screenSize: CGSize? = nil

    init(moodProgress: Double, screenSize: CGSize? = nil) {
        self.moodProgress = moodProgress
        self.screenSize = screenSize
    }

    init(mood: Int, screenSize: CGSize? = nil) {
        self.moodProgress = Double(mood)
        self.screenSize = screenSize
    }

    @State private var isFloating: Bool = false
    @State private var isSwaying: Bool = false
    @State private var isBlinking: Bool = false
    @State private var isWinking: Bool = false
    @State private var eyeLookOffset: CGSize = .zero
    @State private var isSquishTapped: Bool = false

    // MARK: - Reactive Drag, Tactile 3D Physical Tension & Soft-Silicone Dynamics
    @State private var rawDragTranslation: CGSize = .zero
    @State private var isDragging: Bool = false
    @State private var isShadowSpawned: Bool = true

    // Clamps and adds physical resistance (tethered 3D figurine on an elastic base)
    private var clampedDragOffset: CGSize {
        let maxHoriz: CGFloat = 55.0
        let maxUp: CGFloat = 42.0
        let maxDown: CGFloat = 42.0

        func softElastic(drag: CGFloat, maxLimit: CGFloat) -> CGFloat {
            guard drag != 0 else { return 0 }
            let sign: CGFloat = drag > 0 ? 1.0 : -1.0
            let x = abs(drag)
            // Soft yielding elastic response: yields easily to touch, then smoothly approaches limit
            let progress = x / (maxLimit * 1.25)
            let tension = maxLimit * (progress / (1.0 + progress * 0.75))
            return sign * min(tension, maxLimit)
        }

        let clampedX = softElastic(drag: rawDragTranslation.width, maxLimit: maxHoriz)
        let clampedY = rawDragTranslation.height >= 0
            ? softElastic(drag: rawDragTranslation.height, maxLimit: maxDown)
            : -softElastic(drag: abs(rawDragTranslation.height), maxLimit: maxUp)

        return CGSize(width: clampedX, height: clampedY)
    }

    // MARK: - Gummy Rubber Stretching Physics (Continuous Tensor Dynamics)
    // Dynamic angle of pull vector
    private var gummyAngle: Angle {
        guard clampedDragOffset.width != 0 || clampedDragOffset.height != 0 else { return .zero }
        return Angle(radians: Double(atan2(clampedDragOffset.height, clampedDragOffset.width)))
    }

    // Normalized tension magnitude (0.0 to 1.0)
    private var gummyTension: CGFloat {
        let dist = hypot(clampedDragOffset.width, clampedDragOffset.height)
        return min(dist / 48.0, 1.0)
    }

    // Elastic strain along pull vector (elongation)
    private var gummyStretchParallel: CGFloat {
        1.0 + gummyTension * 0.22
    }

    // Poisson transverse strain (contraction preserving volume)
    private var gummyCompressPerpendicular: CGFloat {
        1.0 - gummyTension * 0.11
    }

    // Face elastic strain along pull vector (facial features stretch elastically with skin)
    private var faceStretchParallel: CGFloat {
        1.0 + gummyTension * 0.32
    }

    // Face Poisson transverse contraction (features pinch perpendicular to pull)
    private var faceCompressPerpendicular: CGFloat {
        1.0 - gummyTension * 0.16
    }

    // Normalized pull tension (-1.0 ... 1.0)
    private var tensionX: CGFloat {
        min(max(clampedDragOffset.width / 55.0, -1.0), 1.0)
    }

    private var tensionY: CGFloat {
        min(max(clampedDragOffset.height / 42.0, -1.0), 1.0)
    }

    // Dynamic gaze: smoothly tracks towards the touch point
    private var effectiveEyeLookOffset: CGSize {
        if isDragging || rawDragTranslation != .zero {
            return CGSize(width: tensionX * 6.5, height: tensionY * 5.0)
        } else {
            return eyeLookOffset
        }
    }

    // Base scale stays stable because the exact pulled edge bulges out in the vector path!
    private var bodyScaleX: CGFloat {
        let squish = isSquishTapped ? 1.06 : 1.0
        return (isFloating ? 1.015 : 0.985) * squish
    }

    private var bodyScaleY: CGFloat {
        let squish = isSquishTapped ? 0.94 : 1.0
        return (isFloating ? 0.985 : 1.015) * squish
    }

    // Subtle 2D tilt leaning into drag
    private var bodyRotation: Double {
        if isDragging || rawDragTranslation != .zero {
            return Double(tensionX) * 3.5
        } else {
            return (isSwaying ? -2.5 : 2.5) + Double(moodProgress - 3.0) * 2.5
        }
    }

    // Subtle 3D perspective rotation: clean depth without warping flat layers
    private var tilt3DY: Double {
        if isDragging || rawDragTranslation != .zero {
            return Double(tensionX) * 4.5
        }
        return 0.0
    }

    private var tilt3DX: Double {
        if isDragging || rawDragTranslation != .zero {
            return Double(-tensionY) * 3.5
        }
        return 0.0
    }

    private var characterPositionX: CGFloat {
        let baseSway: CGFloat = isDragging ? 0.0 : ((isSwaying ? -5.0 : 5.0) + CGFloat(moodProgress - 3.0) * 5.5)
        return clampedDragOffset.width + baseSway
    }

    private var characterPositionY: CGFloat {
        let baseFloat: CGFloat = isDragging ? 0.0 : (isFloating ? -9.0 : 9.0)
        let squishOffset: CGFloat = isSquishTapped ? -14.0 : 0.0
        return clampedDragOffset.height + baseFloat + squishOffset
    }

    // MARK: - Harmonized Clean & Radiant Color Palettes with Seamless Blending
    struct CompanionTheme {
        let bright: Color
        let dark: Color
        let fold: Color
        let ambient: Color
        let faceColor: Color

        static func baseTheme(for index: Int) -> CompanionTheme {
            switch index {
            case 1:
                // Überfordert: Deep Twilight Slate & Astral Blue
                return CompanionTheme(
                    bright: Color(red: 0.68, green: 0.80, blue: 0.98),
                    dark: Color(red: 0.26, green: 0.40, blue: 0.72),
                    fold: Color(red: 0.12, green: 0.18, blue: 0.35),
                    ambient: Color(red: 0.32, green: 0.48, blue: 0.85).opacity(0.48),
                    faceColor: Color(red: 0.08, green: 0.12, blue: 0.28)
                )
            case 2:
                // Angespannt: Warm Copper & Smoked Terracotta
                return CompanionTheme(
                    bright: Color(red: 0.98, green: 0.68, blue: 0.50),
                    dark: Color(red: 0.85, green: 0.32, blue: 0.18),
                    fold: Color(red: 0.34, green: 0.12, blue: 0.06),
                    ambient: Color(red: 0.90, green: 0.36, blue: 0.20).opacity(0.50),
                    faceColor: Color(red: 0.24, green: 0.08, blue: 0.05)
                )
            case 3:
                // Stabil & Ruhig: Luminous Lime & Emerald Green (Exact reference aesthetic!)
                return CompanionTheme(
                    bright: Color(red: 0.86, green: 1.0, blue: 0.0),    // Vibrant Lime #D6FF00
                    dark: Color(red: 0.18, green: 0.82, blue: 0.12),    // Rich Emerald #28C818
                    fold: Color(red: 0.08, green: 0.26, blue: 0.06),    // Dark Forest Shadow
                    ambient: Color(red: 0.50, green: 0.96, blue: 0.12).opacity(0.52),
                    faceColor: Color(red: 0.04, green: 0.12, blue: 0.03)
                )
            case 4:
                // Zuversichtlich: Signature Amber Gold & Warm Honey
                return CompanionTheme(
                    bright: Color(red: 1.0, green: 0.90, blue: 0.30),    // Radiant Gold
                    dark: Color(red: 0.96, green: 0.58, blue: 0.08),    // Rich Amber
                    fold: Color(red: 0.40, green: 0.20, blue: 0.04),    // Amber Fold
                    ambient: Color(red: 0.98, green: 0.65, blue: 0.12).opacity(0.54),
                    faceColor: Color(red: 0.22, green: 0.10, blue: 0.02)
                )
            case 5:
                // Stark & Frei: Solar Champagne & Dawn Topaz
                return CompanionTheme(
                    bright: Color(red: 1.0, green: 0.98, blue: 0.68),    // Solar White-Gold
                    dark: Color(red: 1.0, green: 0.74, blue: 0.16),    // Dawn Topaz
                    fold: Color(red: 0.48, green: 0.28, blue: 0.04),
                    ambient: Color(red: 1.0, green: 0.84, blue: 0.25).opacity(0.60),
                    faceColor: Color(red: 0.24, green: 0.14, blue: 0.03)
                )
            default:
                return baseTheme(for: 4)
            }
        }

        static func theme(for progress: Double) -> CompanionTheme {
            let p = min(max(progress, 1.0), 5.0)
            let lower = Int(floor(p))
            let upper = min(lower + 1, 5)
            let fraction = p - Double(lower)

            let a = baseTheme(for: lower)
            let b = baseTheme(for: upper)

            if fraction <= 0.001 { return a }
            if fraction >= 0.999 { return b }

            return CompanionTheme(
                bright: a.bright.blend(to: b.bright, fraction: fraction),
                dark: a.dark.blend(to: b.dark, fraction: fraction),
                fold: a.fold.blend(to: b.fold, fraction: fraction),
                ambient: a.ambient.blend(to: b.ambient, fraction: fraction),
                faceColor: a.faceColor.blend(to: b.faceColor, fraction: fraction)
            )
        }
    }

    private var theme: CompanionTheme {
        CompanionTheme.theme(for: moodProgress)
    }

    var body: some View {
        ZStack {
            // 0. Soft Ground Contact Shadow (Vanishes on drag, spawns back when character lands)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.black.opacity(isShadowSpawned ? (isFloating ? 0.22 : 0.38) : 0.0),
                            Color.black.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 75
                    )
                )
                .frame(width: isFloating ? 130 : 155, height: 18)
                .scaleEffect(isShadowSpawned ? (isSquishTapped ? 1.15 : (isFloating ? 0.94 : 1.04)) : 0.20)
                .blur(radius: isFloating ? 8.5 : 6.0)
                .opacity(isShadowSpawned ? 1.0 : 0.0)
                .offset(x: 0, y: 114)

            // 1. Soft Ambient Diffuse Glow Aura (Radiant and pure)
            CompanionBodyShape()
                .fill(theme.ambient)
                .frame(width: 170, height: 215)
                .blur(radius: 36)
                .rotationEffect(-gummyAngle)
                .scaleEffect(
                    x: gummyStretchParallel * (isFloating ? 1.06 : 0.98),
                    y: gummyCompressPerpendicular * (isFloating ? 1.06 : 0.98),
                    anchor: .center
                )
                .rotationEffect(gummyAngle)
                .rotationEffect(.degrees(bodyRotation))
                .rotation3DEffect(.degrees(tilt3DY), axis: (x: 0, y: 1, z: 0), perspective: 0.35)
                .rotation3DEffect(.degrees(tilt3DX), axis: (x: 1, y: 0, z: 0), perspective: 0.35)
                .offset(x: characterPositionX, y: characterPositionY)
                .opacity(0.70)

            // 2. The Living Character (Gummy Silicone Elastic Physics)
            ZStack {
                // Back Layer: Underside Ribbon Fold (Bottom Left)
                CompanionFoldShape()
                    .fill(theme.fold)
                    .frame(width: 170, height: 215)

                // Front Layer: Main Character Body (Organic 3D Silicone Gummy Body)
                CompanionBodyShape()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: theme.bright, location: 0.0),
                                .init(color: theme.bright.opacity(0.96), location: 0.38),
                                .init(color: theme.dark, location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 170, height: 215)

                // Subtle inner top-left specular & bottom contour
                CompanionBodyShape()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.42),
                                Color.clear,
                                Color.black.opacity(0.18)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
                    .frame(width: 170, height: 215)
            }
            .frame(width: 170, height: 215)
            // Gummy rubber deformation tensor:
            .rotationEffect(-gummyAngle)
            .scaleEffect(x: gummyStretchParallel, y: gummyCompressPerpendicular, anchor: .center)
            .rotationEffect(gummyAngle)
            .overlay(
                // Reactive Animated Face (Gummy stretched in sync with drag)
                CompanionFaceView(
                    progress: moodProgress,
                    isBlinking: isBlinking,
                    isWinking: isWinking,
                    eyeLookOffset: effectiveEyeLookOffset,
                    color: theme.faceColor
                )
                .rotationEffect(-gummyAngle)
                .scaleEffect(x: faceStretchParallel, y: faceCompressPerpendicular, anchor: .center)
                .rotationEffect(gummyAngle)
                .offset(
                    x: clampedDragOffset.width * 0.28,
                    y: -26 + clampedDragOffset.height * 0.20
                )
            )
            .frame(width: 170, height: 215)
            .scaleEffect(x: bodyScaleX, y: bodyScaleY, anchor: .center)
            .rotationEffect(.degrees(bodyRotation))
            .rotation3DEffect(.degrees(tilt3DY), axis: (x: 0, y: 1, z: 0), perspective: 0.35)
            .rotation3DEffect(.degrees(tilt3DX), axis: (x: 1, y: 0, z: 0), perspective: 0.35)
            .offset(x: characterPositionX, y: characterPositionY)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 4)
                    .onChanged { gesture in
                        if !isDragging {
                            SensoryFeedbackService.shared.selectionClick()
                            withAnimation(.easeOut(duration: 0.16)) {
                                isShadowSpawned = false
                            }
                        }
                        isDragging = true
                        rawDragTranslation = gesture.translation
                    }
                    .onEnded { gesture in
                        let isQuickTap = hypot(gesture.translation.width, gesture.translation.height) < 6
                        // Gummy elastic recoil: crisp and soft return
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.58, blendDuration: 0.05)) {
                            rawDragTranslation = .zero
                            isDragging = false
                        }

                        if isQuickTap {
                            handleTapInteraction()
                        } else {
                            SensoryFeedbackService.shared.minigameTap()

                            // Spawn shadow smoothly back once character has returned to resting spot
                            Task {
                                try? await Task.sleep(for: .milliseconds(300))
                                withAnimation(.spring(response: 0.40, dampingFraction: 0.70)) {
                                    isShadowSpawned = true
                                }
                            }
                        }
                    }
            )
            .onTapGesture {
                handleTapInteraction()
            }
        }
        .frame(height: 245)
        .zIndex(isDragging ? 100 : 1)
        .onAppear {
            // Smooth vertical floating
            withAnimation(.easeInOut(duration: 2.3).repeatForever(autoreverses: true)) {
                isFloating = true
            }

            // Asymmetric horizontal sway & tilt for true organic fluid motion
            withAnimation(.easeInOut(duration: 3.1).repeatForever(autoreverses: true)) {
                isSwaying = true
            }

            // Living cycles: blinks, double-blinks, curious eye saccades
            startLivingCycles()
        }
    }

    private func handleTapInteraction() {
        SensoryFeedbackService.shared.selectionClick()
        withAnimation(.spring(response: 0.22, dampingFraction: 0.55)) {
            isSquishTapped = true
            isWinking = true
        }

        Task {
            try? await Task.sleep(for: .milliseconds(180))
            withAnimation(.spring(response: 0.32, dampingFraction: 0.60)) {
                isSquishTapped = false
                isWinking = false
            }
        }
    }

    private func startLivingCycles() {
        // 1. Natural Blinking & Double-Blink Cycle
        Task {
            while !Task.isCancelled {
                let interval = Double.random(in: 3.2...5.2)
                try? await Task.sleep(for: .seconds(interval))
                guard !Task.isCancelled else { break }

                withAnimation(.easeInOut(duration: 0.08)) {
                    isBlinking = true
                }
                try? await Task.sleep(for: .milliseconds(110))
                withAnimation(.easeInOut(duration: 0.10)) {
                    isBlinking = false
                }

                // 25% chance of an immediate cute double-blink
                if Double.random(in: 0...1) < 0.25 {
                    try? await Task.sleep(for: .milliseconds(120))
                    withAnimation(.easeInOut(duration: 0.07)) {
                        isBlinking = true
                    }
                    try? await Task.sleep(for: .milliseconds(90))
                    withAnimation(.easeInOut(duration: 0.09)) {
                        isBlinking = false
                    }
                }
            }
        }

        // 2. Gentle Curious Eye Saccades (Looking around)
        Task {
            while !Task.isCancelled {
                let lookInterval = Double.random(in: 4.0...6.5)
                try? await Task.sleep(for: .seconds(lookInterval))
                guard !Task.isCancelled else { break }

                let targetX = CGFloat.random(in: -3.0...3.0)
                let targetY = CGFloat.random(in: -1.5...2.5)

                withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) {
                    eyeLookOffset = CGSize(width: targetX, height: targetY)
                }

                let gazeDuration = Double.random(in: 1.2...2.2)
                try? await Task.sleep(for: .seconds(gazeDuration))
                guard !Task.isCancelled else { break }

                withAnimation(.spring(response: 0.32, dampingFraction: 0.80)) {
                    eyeLookOffset = .zero
                }
            }
        }
    }
}

// MARK: - Compatibility Alias
typealias ZenMindOrbView = ZenCompanionView

// MARK: - Character Vector Shapes

// MARK: - Character Vector Shapes (Iconic 3D Figurine Geometry)

/// Main Character Body: Pristine 3D geometric vector silhouette with smooth C^2 continuous curves.
/// Elastic deformation is applied via continuous gummy stretching physics.
struct CompanionBodyShape: InsettableShape {
    var insetAmount: CGFloat = 0

    func inset(by amount: CGFloat) -> CompanionBodyShape {
        var copy = self
        copy.insetAmount += amount
        return copy
    }

    func path(in rect: CGRect) -> Path {
        let w = rect.width - insetAmount * 2
        let h = rect.height - insetAmount * 2
        let rTop = w / 2.0
        let ox = rect.minX + insetAmount
        let oy = rect.minY + insetAmount

        var path = Path()

        let leftShoulder = CGPoint(x: ox, y: oy + rTop)
        let apex = CGPoint(x: ox + rTop, y: oy)
        let rightShoulder = CGPoint(x: ox + w, y: oy + rTop)

        path.move(to: leftShoulder)

        // 1. Left Dome to Apex (tangent strictly vertical at shoulder, strictly horizontal at apex)
        path.addCurve(
            to: apex,
            control1: CGPoint(x: ox, y: oy + rTop - rTop * 0.552),
            control2: CGPoint(x: apex.x - rTop * 0.552, y: oy)
        )

        // 2. Apex to Right Dome (strictly horizontal at apex, strictly vertical at shoulder)
        path.addCurve(
            to: rightShoulder,
            control1: CGPoint(x: apex.x + rTop * 0.552, y: oy),
            control2: CGPoint(x: ox + w, y: oy + rTop - rTop * 0.552)
        )

        // 3. Right Flank down to bottom lobe (continuous smooth line/convex curve, zero inflection!)
        let rightBottomFoot = CGPoint(x: ox + w, y: oy + h - 34)
        path.addCurve(
            to: rightBottomFoot,
            control1: CGPoint(x: ox + w, y: oy + rTop + (h - 34 - rTop) * 0.35),
            control2: CGPoint(x: ox + w, y: oy + rTop + (h - 34 - rTop) * 0.70)
        )

        // 4. Bottom-right rounded tip / foot
        path.addCurve(
            to: CGPoint(x: ox + w - 24, y: oy + h),
            control1: CGPoint(x: ox + w, y: oy + h - 8),
            control2: CGPoint(x: ox + w - 10, y: oy + h)
        )

        // 5. Saddle curve sweep up-left
        path.addCurve(
            to: CGPoint(x: ox + w * 0.54, y: oy + h - 22),
            control1: CGPoint(x: ox + w - 46, y: oy + h - 4),
            control2: CGPoint(x: ox + w * 0.65, y: oy + h - 18)
        )

        // 6. Front fold crest sweep down-left
        path.addCurve(
            to: CGPoint(x: ox + w * 0.28, y: oy + h - 4),
            control1: CGPoint(x: ox + w * 0.44, y: oy + h - 26),
            control2: CGPoint(x: ox + w * 0.38, y: oy + h - 8)
        )

        // 7. Bottom-left rounded edge
        path.addCurve(
            to: CGPoint(x: ox, y: oy + h - 30),
            control1: CGPoint(x: ox + w * 0.16, y: oy + h - 2),
            control2: CGPoint(x: ox, y: oy + h - 16)
        )

        // 8. Left Flank up to Left Shoulder (smooth single curve, vertical tangent into shoulder!)
        path.addCurve(
            to: leftShoulder,
            control1: CGPoint(x: ox, y: oy + h - 30 - (h - 30 - rTop) * 0.30),
            control2: CGPoint(x: ox, y: oy + h - 30 - (h - 30 - rTop) * 0.65)
        )

        path.closeSubpath()
        return path
    }
}

/// The Underside Ribbon Fold in the bottom left, giving the character 3D sheet depth.
struct CompanionFoldShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height

        var path = Path()
        let startPt = CGPoint(x: 0, y: h - 30)
        path.move(to: startPt)

        // Curve down to bottom belly
        path.addQuadCurve(
            to: CGPoint(x: w * 0.32, y: h + 2),
            control: CGPoint(x: w * 0.12, y: h + 8)
        )

        // Curve up into the under-fold hollow
        path.addQuadCurve(
            to: CGPoint(x: w * 0.58, y: h - 22),
            control: CGPoint(x: w * 0.48, y: h - 6)
        )

        path.addLine(to: startPt)
        path.closeSubpath()
        return path
    }
}

// MARK: - Reactive Character Face (100% Rigidly Anchored & Living)

struct CompanionFaceView: View {
    let progress: Double // 1.0 ... 5.0 continuous
    let isBlinking: Bool
    let isWinking: Bool
    let eyeLookOffset: CGSize
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            // Eyes Row
            HStack(spacing: 38) {
                MorphingCompanionEye(
                    progress: progress,
                    isBlinking: isBlinking || isWinking,
                    color: color
                )
                MorphingCompanionEye(
                    progress: progress,
                    isBlinking: isBlinking,
                    color: color
                )
            }
            .offset(eyeLookOffset)

            // Reactive Continuous Morphing Mouth
            CompanionMouth(progress: progress, color: color)
                .offset(x: eyeLookOffset.width * 0.35, y: eyeLookOffset.height * 0.35)
        }
    }
}

/// Individual Eye that morphs smoothly with continuous mood and blinks organically.
struct MorphingCompanionEye: View {
    let progress: Double // 1.0 ... 5.0
    let isBlinking: Bool
    let color: Color

    var body: some View {
        let p = min(max(progress, 1.0), 5.0)

        // Factor for droopy arc (1.0 at p=1.0, dissolves to 0.0 at p=2.0)
        let droopFactor = max(0.0, min(2.0 - p, 1.0))

        // Factor for happy arc (0.0 at p=4.0, dissolves to 1.0 at p=5.0)
        let joyFactor = max(0.0, min(p - 4.0, 1.0))

        // Factor for center dot eye (active between 1.0 and 5.0, fully opaque between 2.0 and 4.0)
        let dotOpacity = (1.0 - droopFactor) * (1.0 - joyFactor)

        // Dot size scales smoothly from 11pt (tense) to 13pt (calm/confident)
        let dotSize: CGFloat = {
            if p <= 2.0 {
                return 11.0
            } else if p <= 3.0 {
                return 11.0 + CGFloat(p - 2.0) * 2.0 // 11 to 13
            } else {
                return 13.0
            }
        }()

        ZStack {
            // 1. Droopy Tired Eye (Mood 1)
            if droopFactor > 0.001 {
                ArcShape(startAngle: 200, endAngle: 340)
                    .stroke(color, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                    .frame(width: 14, height: 10)
                    .offset(y: 2)
                    .opacity(droopFactor)
            }

            // 2. Focused / Peaceful Dot Eye (Mood 2, 3, 4)
            if dotOpacity > 0.001 {
                Circle()
                    .fill(color)
                    .frame(width: dotSize, height: dotSize)
                    .opacity(dotOpacity)
            }

            // 3. Joyful Beaming Crescent Eye (Mood 5)
            if joyFactor > 0.001 {
                ArcShape(startAngle: 190, endAngle: 350)
                    .stroke(color, style: StrokeStyle(lineWidth: 3.8, lineCap: .round))
                    .frame(width: 15, height: 11)
                    .offset(y: -1)
                    .opacity(joyFactor)
            }
        }
        .frame(width: 16, height: 14)
        // Living Blink: squashes naturally flat like an organic eyelid
        .scaleEffect(y: isBlinking ? 0.08 : 1.0, anchor: .center)
    }
}

// Backward-compatibility alias
typealias CompanionEye = MorphingCompanionEye

/// Reactive Mouth that expresses each mood with continuous curvature morphing.
struct CompanionMouth: View {
    let progress: Double
    let color: Color

    var body: some View {
        let p = min(max(progress, 1.0), 5.0)
        let strokeWidth: CGFloat = 3.2 + CGFloat(max(0, (p - 2.0) / 3.0)) * 0.7

        MorphingCompanionMouth(progress: progress)
            .stroke(color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
            .frame(width: 26, height: 14)
    }
}

/// Fluid morphing mouth bezier shape with animatableData for butter-smooth 120 FPS transitions.
struct MorphingCompanionMouth: Shape {
    var animatableData: Double

    init(progress: Double) {
        self.animatableData = progress
    }

    func path(in rect: CGRect) -> Path {
        let p = min(max(animatableData, 1.0), 5.0)

        // Continuous curvature interpolation:
        // p = 1.0 -> -0.80 (sad/overwhelmed frown)
        // p = 2.0 -> 0.00 (straight/tense line)
        // p = 3.0 -> +0.38 (peaceful calm smile)
        // p = 4.0 -> +0.70 (warm confident smile)
        // p = 5.0 -> +1.00 (wide joyful beaming smile)
        let curvature: Double = {
            if p < 2.0 {
                return -0.80 * (2.0 - p)
            } else {
                return (p - 2.0) / 3.0
            }
        }()

        let mouthWidth: CGFloat = 14.0 + CGFloat(max(0, curvature)) * 7.0 // 14pt (tense) to 21pt (joyful)
        let leftX = rect.midX - mouthWidth / 2.0
        let rightX = rect.midX + mouthWidth / 2.0
        let midY = rect.midY

        let endY = midY - CGFloat(curvature * 2.2)
        let ctrlY = midY + CGFloat(curvature * 7.5)

        var path = Path()
        path.move(to: CGPoint(x: leftX, y: endY))
        path.addQuadCurve(
            to: CGPoint(x: rightX, y: endY),
            control: CGPoint(x: rect.midX, y: ctrlY)
        )
        return path
    }
}

/// Reusable Arc Shape for eyes and smile curves.
struct ArcShape: Shape {
    var startAngle: Double
    var endAngle: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2.0,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle),
            clockwise: false
        )
        return path
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ZenCompanionView(mood: 3)
    }
}
