import SwiftUI

/// Butter-smooth, physically curved mood slider dock.
/// Features a rail-following glass puck that tilts along the curve,
/// identical background smileys positioned along the arc,
/// and a real-time fluid morphing expression during drag.
struct CurvedMoodDockView: View {
    @Binding var selectedMood: Int
    var continuousProgress: Binding<Double>? = nil
    var onMoodChanged: ((Int) -> Void)? = nil

    init(
        selectedMood: Binding<Int>,
        continuousProgress: Binding<Double>? = nil,
        onMoodChanged: ((Int) -> Void)? = nil
    ) {
        self._selectedMood = selectedMood
        self.continuousProgress = continuousProgress
        self.onMoodChanged = onMoodChanged
    }

    @State private var dragX: CGFloat? = nil
    @State private var isDragging: Bool = false
    @State private var continuousValue: CGFloat = 4.0

    private let moodCount = 5
    private let dockHeight: CGFloat = 84
    private let trackHeight: CGFloat = 64
    private let archHeight: CGFloat = 16

    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let itemWidth = totalWidth / CGFloat(moodCount)
            let minX = itemWidth * 0.5
            let maxX = totalWidth - (itemWidth * 0.5)

            // Current puck X: tracks finger directly while dragging, snaps to sector center when idle
            let puckX: CGFloat = {
                if let drag = dragX {
                    return min(max(drag, minX), maxX)
                } else {
                    return calculateNodeX(for: selectedMood, itemWidth: itemWidth)
                }
            }()

            let puckY = calculateCurveY(at: puckX, totalWidth: totalWidth)
            let puckAngle = calculateTangentAngle(at: puckX, totalWidth: totalWidth)

            ZStack {
                // 1. Arched Glass Dock Track (Curved bridge silhouette, 100% constant thickness & silky pill ends)
                CurvedBridgeShape(archHeight: archHeight, trackHeight: trackHeight)
                    .fill(.ultraThinMaterial.opacity(0.48))
                    .overlay(
                        CurvedBridgeShape(archHeight: archHeight, trackHeight: trackHeight)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.34),
                                        Color.white.opacity(0.18),
                                        Color.white.opacity(0.26)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1.2
                            )
                    )
                    .shadow(color: Color.black.opacity(0.22), radius: 14, y: 6)

                // 2. The 5 Passive Background Smileys (Positioned exactly dead-center on the curve)
                ForEach(1...moodCount, id: \.self) { level in
                    let nodeX = calculateNodeX(for: level, itemWidth: itemWidth)
                    let nodeY = calculateCurveY(at: nodeX, totalWidth: totalWidth)
                    let nodeAngle = calculateTangentAngle(at: nodeX, totalWidth: totalWidth)

                    MorphingMoodFace(
                        progress: CGFloat(level),
                        isSelected: false
                    )
                    .frame(width: 32, height: 32)
                    .rotationEffect(.degrees(nodeAngle))
                    .position(x: nodeX, y: nodeY)
                }

                // 3. Fluid Sliding & Tilting Glass Puck with Real-time Morphing Face
                ZStack {
                    // Puck Glass Body: perfectly proportioned to sit centered inside the 64pt track
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.96))
                        .frame(width: 54, height: 48)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .strokeBorder(Color.white, lineWidth: 1.5)
                        )
                        .shadow(color: Color.white.opacity(0.40), radius: 8, y: 0)
                        .shadow(color: Color.black.opacity(0.18), radius: 6, y: 3)

                    // Morphing Face inside Puck (Updates continuously in real time!)
                    MorphingMoodFace(
                        progress: continuousValue,
                        isSelected: true
                    )
                    .frame(width: 30, height: 30)
                }
                .rotationEffect(.degrees(puckAngle))
                .position(x: puckX, y: puckY)
                .animation(isDragging ? .interactiveSpring(response: 0.12, dampingFraction: 0.85) : .spring(response: 0.35, dampingFraction: 0.72), value: puckX)
                .animation(isDragging ? .interactiveSpring(response: 0.12, dampingFraction: 0.85) : .spring(response: 0.35, dampingFraction: 0.72), value: puckY)
                .animation(isDragging ? .interactiveSpring(response: 0.12, dampingFraction: 0.85) : .spring(response: 0.35, dampingFraction: 0.72), value: puckAngle)
            }
            .contentShape(Rectangle())
            // Drag & Tap Gesture
            .highPriorityGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        let clampedX = min(max(value.location.x, minX), maxX)
                        dragX = clampedX

                        // Smooth continuous value between 1.0 and 5.0
                        let normalizedProgress = (clampedX - minX) / (maxX - minX)
                        let newContinuous = 1.0 + (normalizedProgress * 4.0)
                        continuousValue = newContinuous
                        continuousProgress?.wrappedValue = Double(newContinuous)

                        let nearestIndex = min(max(Int(round(newContinuous)), 1), moodCount)
                        if nearestIndex != selectedMood {
                            selectedMood = nearestIndex
                            SensoryFeedbackService.shared.selectionClick()
                            onMoodChanged?(nearestIndex)
                        }
                    }
                    .onEnded { value in
                        let clampedX = min(max(value.location.x, minX), maxX)
                        let normalizedProgress = (clampedX - minX) / (maxX - minX)
                        let finalIndex = min(max(Int(round(1.0 + normalizedProgress * 4.0)), 1), moodCount)

                        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                            selectedMood = finalIndex
                            continuousValue = CGFloat(finalIndex)
                            continuousProgress?.wrappedValue = Double(finalIndex)
                            dragX = nil
                            isDragging = false
                        }
                        SensoryFeedbackService.shared.selectionClick()
                        onMoodChanged?(finalIndex)
                    }
            )
            .onAppear {
                continuousValue = CGFloat(selectedMood)
                continuousProgress?.wrappedValue = Double(selectedMood)
            }
            .onChange(of: selectedMood) { _, newVal in
                if !isDragging {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        continuousValue = CGFloat(newVal)
                        continuousProgress?.wrappedValue = Double(newVal)
                    }
                }
            }
        }
        .frame(height: dockHeight)
    }

    // MARK: - Curve Geometry Math (Dead-center vertical alignment)
    private func calculateNodeX(for level: Int, itemWidth: CGFloat) -> CGFloat {
        (CGFloat(level - 1) * itemWidth) + (itemWidth / 2.0)
    }

    private func calculateCurveY(at x: CGFloat, totalWidth: CGFloat) -> CGFloat {
        let norm = (x - (totalWidth / 2.0)) / (totalWidth / 2.0) // -1.0 to 1.0
        let archOffset = (1.0 - (norm * norm)) * archHeight // Peaks at center
        // Matches the vertical centerline of CurvedBridgeShape
        return (dockHeight / 2.0) + (archHeight / 2.0) - archOffset
    }

    private func calculateTangentAngle(at x: CGFloat, totalWidth: CGFloat) -> Double {
        let halfWidth = totalWidth / 2.0
        let norm = (x - halfWidth) / halfWidth
        let slope = Double((2.0 * norm * archHeight) / halfWidth)
        return atan(slope) * (180.0 / .pi)
    }
}

// MARK: - Arched Bridge Track Shape (Mathematically smooth and perfectly uniform)

struct CurvedBridgeShape: InsettableShape {
    var archHeight: CGFloat = 16
    var trackHeight: CGFloat = 64
    var insetAmount: CGFloat = 0

    func inset(by amount: CGFloat) -> CurvedBridgeShape {
        var copy = self
        copy.insetAmount += amount
        return copy
    }

    func path(in rect: CGRect) -> Path {
        let r = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let w = r.width
        let effectiveTrackHeight = trackHeight - (insetAmount * 2.0)
        let R = effectiveTrackHeight / 2.0
        let k = R * 0.55228475

        let leftX = r.minX + R
        let rightX = r.maxX - R
        let midX = r.midX

        func yCenter(_ x: CGFloat) -> CGFloat {
            let norm = (x - midX) / (w / 2.0)
            let arch = (1.0 - (norm * norm)) * archHeight
            return r.midY + (archHeight / 2.0) - arch
        }

        func slopeCenter(_ x: CGFloat) -> CGFloat {
            let norm = (x - midX) / (w / 2.0)
            return (2.0 * norm * archHeight) / (w / 2.0)
        }

        // Right end geometry
        let thetaR = atan(slopeCenter(rightX))
        let cosR = cos(thetaR)
        let sinR = sin(thetaR)
        let ycR = yCenter(rightX)
        let pTopRight = CGPoint(x: rightX + R * sinR, y: ycR - R * cosR)
        let pBotRight = CGPoint(x: rightX - R * sinR, y: ycR + R * cosR)
        let apexR = CGPoint(x: rightX + R * cosR, y: ycR + R * sinR)

        // Left end geometry
        let thetaL = atan(slopeCenter(leftX))
        let cosL = cos(thetaL)
        let sinL = sin(thetaL)
        let ycL = yCenter(leftX)
        let pTopLeft = CGPoint(x: leftX + R * sinL, y: ycL - R * cosL)
        let pBotLeft = CGPoint(x: leftX - R * sinL, y: ycL + R * cosL)
        let apexL = CGPoint(x: leftX - R * cosL, y: ycL - R * sinL)

        // Top & bottom curve control points
        let topMidY = yCenter(midX) - R
        let topCtrlY = 2.0 * topMidY - 0.5 * (pTopLeft.y + pTopRight.y)
        let topCtrl = CGPoint(x: midX, y: topCtrlY)

        let botMidY = yCenter(midX) + R
        let botCtrlY = 2.0 * botMidY - 0.5 * (pBotLeft.y + pBotRight.y)
        let botCtrl = CGPoint(x: midX, y: botCtrlY)

        var path = Path()

        // 1. Top curve
        path.move(to: pTopLeft)
        path.addQuadCurve(to: pTopRight, control: topCtrl)

        // 2. Right cap (2 cubic bezier quadrants rotated by thetaR)
        let c1 = CGPoint(x: pTopRight.x + k * cosR, y: pTopRight.y + k * sinR)
        let c2 = CGPoint(x: apexR.x + k * sinR, y: apexR.y - k * cosR)
        path.addCurve(to: apexR, control1: c1, control2: c2)

        let c3 = CGPoint(x: apexR.x - k * sinR, y: apexR.y + k * cosR)
        let c4 = CGPoint(x: pBotRight.x + k * cosR, y: pBotRight.y + k * sinR)
        path.addCurve(to: pBotRight, control1: c3, control2: c4)

        // 3. Bottom curve
        path.addQuadCurve(to: pBotLeft, control: botCtrl)

        // 4. Left cap (2 cubic bezier quadrants rotated by thetaL)
        let lc1 = CGPoint(x: pBotLeft.x - k * cosL, y: pBotLeft.y - k * sinL)
        let lc2 = CGPoint(x: apexL.x - k * sinL, y: apexL.y + k * cosL)
        path.addCurve(to: apexL, control1: lc1, control2: lc2)

        let lc3 = CGPoint(x: apexL.x + k * sinL, y: apexL.y - k * cosL)
        let lc4 = CGPoint(x: pTopLeft.x - k * cosL, y: pTopLeft.y - k * sinL)
        path.addCurve(to: pTopLeft, control1: lc3, control2: lc4)

        path.closeSubpath()
        return path
    }
}

// MARK: - Fluid Morphing Mood Face (Canvas-rendered with continuous interpolation)

struct MorphingMoodFace: View {
    let progress: CGFloat // Continuous 1.0 ... 5.0
    let isSelected: Bool
    var colorOverride: Color? = nil

    // Dynamic color tint on puck
    private var faceColor: Color {
        if let override = colorOverride {
            return override
        }
        if isSelected {
            let clamped = min(max(progress, 1.0), 5.0)
            if clamped <= 2.0 {
                let t = clamped - 1.0
                return blendColor(from: Color(red: 0.92, green: 0.40, blue: 0.40), to: Color(red: 0.95, green: 0.62, blue: 0.35), fraction: t)
            } else if clamped <= 3.0 {
                let t = clamped - 2.0
                return blendColor(from: Color(red: 0.95, green: 0.62, blue: 0.35), to: Color(red: 0.65, green: 0.72, blue: 0.82), fraction: t)
            } else if clamped <= 4.0 {
                let t = clamped - 3.0
                return blendColor(from: Color(red: 0.65, green: 0.72, blue: 0.82), to: Color(red: 0.45, green: 0.82, blue: 0.60), fraction: t)
            } else {
                let t = clamped - 4.0
                return blendColor(from: Color(red: 0.45, green: 0.82, blue: 0.60), to: Color(red: 0.32, green: 0.88, blue: 0.54), fraction: t)
            }
        } else {
            return Color.white.opacity(0.48)
        }
    }

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let clamped = min(max(progress, 1.0), 5.0)

            // Normalized curvature: -1.0 (deep sad) to +1.0 (deep smile)
            let curvature = (clamped - 3.0) / 2.0

            // 1. Two Eyes
            let eyeRadius: CGFloat = isSelected ? 2.2 : 2.0
            let eyeY: CGFloat = h * 0.38
            let leftEyeX = w * 0.32
            let rightEyeX = w * 0.68

            // Eye Squint factor: only active as progress approaches 5.0 (clamped > 4.2)
            let squintFactor = max(0.0, min((clamped - 4.2) / 0.8, 1.0))

            if squintFactor < 0.99 {
                // Regular Round Dot Eyes
                let dotAlpha = 1.0 - squintFactor
                var leftEyeContext = context
                leftEyeContext.opacity = dotAlpha
                let leftRect = CGRect(x: leftEyeX - eyeRadius, y: eyeY - eyeRadius, width: eyeRadius * 2, height: eyeRadius * 2)
                let rightRect = CGRect(x: rightEyeX - eyeRadius, y: eyeY - eyeRadius, width: eyeRadius * 2, height: eyeRadius * 2)
                leftEyeContext.fill(Path(ellipseIn: leftRect), with: .color(faceColor))
                leftEyeContext.fill(Path(ellipseIn: rightRect), with: .color(faceColor))
            }

            if squintFactor > 0.01 {
                // Joyful Curved Eyes (⌒ ⌒) morphing in
                var arcContext = context
                arcContext.opacity = squintFactor

                var leftArc = Path()
                leftArc.move(to: CGPoint(x: leftEyeX - 3.5, y: eyeY + 1))
                leftArc.addQuadCurve(
                    to: CGPoint(x: leftEyeX + 3.5, y: eyeY + 1),
                    control: CGPoint(x: leftEyeX, y: eyeY - 3.5)
                )

                var rightArc = Path()
                rightArc.move(to: CGPoint(x: rightEyeX - 3.5, y: eyeY + 1))
                rightArc.addQuadCurve(
                    to: CGPoint(x: rightEyeX + 3.5, y: eyeY + 1),
                    control: CGPoint(x: rightEyeX, y: eyeY - 3.5)
                )

                let strokeStyle = StrokeStyle(lineWidth: isSelected ? 2.2 : 2.0, lineCap: .round)
                arcContext.stroke(leftArc, with: .color(faceColor), style: strokeStyle)
                arcContext.stroke(rightArc, with: .color(faceColor), style: strokeStyle)
            }

            // 2. Real-time Morphing Mouth Path
            let mouthY: CGFloat = h * 0.66
            let mouthWidth: CGFloat = w * 0.38 + abs(curvature) * (w * 0.08)
            let halfMouth = mouthWidth / 2.0

            let leftX = (w / 2.0) - halfMouth
            let rightX = (w / 2.0) + halfMouth

            // Endpoint Y adjusts subtly with emotion
            let endY = mouthY - (curvature * 2.0)
            // Center control point Y: bends down for smile (+), bends up for frown (-)
            let controlY = mouthY + (curvature * 8.0)

            var mouthPath = Path()
            mouthPath.move(to: CGPoint(x: leftX, y: endY))
            mouthPath.addQuadCurve(
                to: CGPoint(x: rightX, y: endY),
                control: CGPoint(x: w / 2.0, y: controlY)
            )

            context.stroke(
                mouthPath,
                with: .color(faceColor),
                style: StrokeStyle(lineWidth: isSelected ? 2.4 : 2.1, lineCap: .round)
            )
        }
        .scaleEffect(isSelected ? 1.08 : 1.0)
    }

    private func blendColor(from c1: Color, to c2: Color, fraction: CGFloat) -> Color {
        let f = min(max(fraction, 0.0), 1.0)
        return Color(
            UIColor(c1).interpolate(to: UIColor(c2), fraction: f)
        )
    }
}

// MARK: - Color Interpolation Helper

private extension UIColor {
    func interpolate(to target: UIColor, fraction: CGFloat) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        target.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return UIColor(
            red: r1 + (r2 - r1) * fraction,
            green: g1 + (g2 - g1) * fraction,
            blue: b1 + (b2 - b1) * fraction,
            alpha: a1 + (a2 - a1) * fraction
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CurvedMoodDockView(selectedMood: .constant(4))
            .padding(.horizontal, 24)
    }
}
