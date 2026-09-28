import SwiftUI

/// ViewModifier providing a gentle, ambient light shimmer effect across cards or badges.
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1.0
    var isActive: Bool = true
    var duration: Double = 2.5
    var delay: Double = 3.0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    if isActive {
                        let width = geo.size.width
                        LinearGradient(
                            colors: [
                                .clear,
                                Color.white.opacity(0.25),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(width: width * 0.8)
                        .rotationEffect(.degrees(20))
                        .offset(x: phase * (width * 2) - (width * 0.5))
                        .blendMode(.plusLighter)
                        .mask(content)
                    }
                }
            )
            .task {
                guard isActive else { return }
                while !Task.isCancelled {
                    withAnimation(.easeInOut(duration: duration)) {
                        phase = 1.0
                    }
                    try? await Task.sleep(for: .seconds(duration))
                    phase = -1.0
                    try? await Task.sleep(for: .seconds(delay))
                }
            }
    }
}

extension View {
    /// Applies a gentle ambient shimmer highlight across the view.
    func ambientShimmer(isActive: Bool = true, duration: Double = 2.2, delay: Double = 3.5) -> some View {
        self.modifier(ShimmerModifier(isActive: isActive, duration: duration, delay: delay))
    }
}

#Preview {
    RoundedRectangle(cornerRadius: 16)
        .fill(Design.Colors.gold.gradient)
        .frame(width: 200, height: 100)
        .ambientShimmer()
        .padding()
}
