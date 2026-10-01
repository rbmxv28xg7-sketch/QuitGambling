import SwiftUI

/// A multi-layer fluid sine wave animation representing emotional waves calming down.
struct AnimatedWaveView: View {
    /// Progress from 0.0 (active storm / full urge) to 1.0 (completely calm sea)
    var calmness: Double = 0.0

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let width = size.width
                let height = size.height
                let baseHeight = height * 0.55

                // Wave intensity diminishes as calmness increases
                let intensity = max(0.15, 1.0 - (calmness * 0.85))

                // Layer 1: Deep background wave (Ocean Navy / Slate Blue)
                let wave1Path = createWavePath(
                    width: width,
                    height: height,
                    baseHeight: baseHeight + 15,
                    amplitude: 22 * intensity,
                    frequency: 0.012,
                    phase: time * 1.2
                )
                context.fill(
                    wave1Path,
                    with: .linearGradient(
                        Gradient(colors: [
                            Color(red: 0.08, green: 0.32, blue: 0.68).opacity(0.45),
                            Color(red: 0.04, green: 0.18, blue: 0.45).opacity(0.20)
                        ]),
                        startPoint: CGPoint(x: 0, y: 0),
                        endPoint: CGPoint(x: 0, y: height)
                    )
                )

                // Layer 2: Midground wave (Cerulean / Azure Blue)
                let wave2Path = createWavePath(
                    width: width,
                    height: height,
                    baseHeight: baseHeight + 5,
                    amplitude: 18 * intensity,
                    frequency: 0.016,
                    phase: -time * 1.5 + 2.0
                )
                context.fill(
                    wave2Path,
                    with: .linearGradient(
                        Gradient(colors: [
                            Color(red: 0.12, green: 0.52, blue: 0.90).opacity(0.65),
                            Color(red: 0.06, green: 0.32, blue: 0.68).opacity(0.30)
                        ]),
                        startPoint: CGPoint(x: 0, y: 0),
                        endPoint: CGPoint(x: 0, y: height)
                    )
                )

                // Layer 3: Foreground wave (Luminous Cyan Crest / Ocean Blue)
                let wave3Path = createWavePath(
                    width: width,
                    height: height,
                    baseHeight: baseHeight,
                    amplitude: 14 * intensity,
                    frequency: 0.02,
                    phase: time * 1.8 + 4.0
                )
                context.fill(
                    wave3Path,
                    with: .linearGradient(
                        Gradient(colors: [
                            Color(red: 0.22, green: 0.72, blue: 0.98).opacity(0.85),
                            Color(red: 0.10, green: 0.48, blue: 0.88).opacity(0.40)
                        ]),
                        startPoint: CGPoint(x: 0, y: 0),
                        endPoint: CGPoint(x: 0, y: height)
                    )
                )
            }
        }
    }

    private func createWavePath(
        width: CGFloat,
        height: CGFloat,
        baseHeight: CGFloat,
        amplitude: CGFloat,
        frequency: CGFloat,
        phase: Double
    ) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0, y: baseHeight))

        let step: CGFloat = 4
        for x in stride(from: 0, through: width + step, by: step) {
            let relativeX = x * frequency
            let sine = sin(Double(relativeX) + phase)
            let cosine = cos(Double(relativeX * 0.5) + phase * 0.8) * 0.3
            let y = baseHeight + CGFloat(sine + cosine) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: width, y: height))
        path.closeSubpath()
        return path
    }
}

#Preview {
    VStack(spacing: 20) {
        AnimatedWaveView(calmness: 0.0)
            .frame(height: 180)
            .background(Design.Colors.background)
        AnimatedWaveView(calmness: 0.8)
            .frame(height: 180)
            .background(Design.Colors.background)
    }
}
