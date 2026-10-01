import SwiftUI
import UIKit

/// True Liquid Glass System: Warm, organic, translucent glass that absorbs and refracts the amber/terracotta background.
/// Completely eliminates muddy gray boxes by using pure light transmission and warm champagne specular reflections.
struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = Design.Radius.card
    var padding: CGFloat? = nil

    func body(content: Content) -> some View {
        content
            .ifLet(padding) { view, pad in
                view.padding(pad)
            }
            .background {
                ZStack {
                    // 1. Warm Liquid Glass Substrate (Exact same as 'Heute spielfrei bleiben' button)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial.opacity(0.35))
                        .shadow(color: Color.black.opacity(0.22), radius: 12, x: 0, y: 6)

                    // 2. Warm Liquid Glass Tint
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Design.Colors.champagne.opacity(0.12),
                                    Design.Colors.copper.opacity(0.06)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // 3. Top Specular Glaze (Navbar-grade glossy reflection)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: Color.white.opacity(0.20), location: 0.0),
                                    .init(color: Design.Colors.champagne.opacity(0.05), location: 0.35),
                                    .init(color: Color.clear, location: 0.70)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    // 4. Fine Champagne & Specular Edge Stroke
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                stops: [
                                    .init(color: Design.Colors.champagne.opacity(0.55), location: 0.0),
                                    .init(color: Color.white.opacity(0.20), location: 0.30),
                                    .init(color: Color.clear, location: 0.65),
                                    .init(color: Design.Colors.copper.opacity(0.35), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))

    }
}

extension View {
    /// Applies warm, translucent Liquid Glass styling that absorbs and refracts background light.
    func liquidGlass(
        cornerRadius: CGFloat = Design.Radius.card,
        padding: CGFloat? = nil
    ) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius, padding: padding))
    }

    /// Clean card style mapping to warm liquid glass
    func sereneCardStyle(padding: CGFloat = Design.Spacing.md) -> some View {
        self.liquidGlass(cornerRadius: Design.Radius.card, padding: padding)
    }

    /// Solid surface compatibility mapping
    func solidSurface(
        cornerRadius: CGFloat = Design.Radius.card,
        surfaceColor: Color = Design.Colors.surface,
        padding: CGFloat? = nil
    ) -> some View {
        self.liquidGlass(cornerRadius: cornerRadius, padding: padding)
    }

    /// Vision glass compatibility mapping
    func visionGlass(
        cornerRadius: CGFloat = Design.Radius.card,
        glowColor: Color? = nil,
        padding: CGFloat? = nil
    ) -> some View {
        self.liquidGlass(cornerRadius: cornerRadius, padding: padding)
    }

    @ViewBuilder
    fileprivate func ifLet<T, V: View>(_ value: T?, transform: (Self, T) -> V) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }

    /// Gives horizontal scroll views a smooth, continuous flow without harsh rectangular cutoffs.
    /// Cancels container padding so scrolling spans the container and dissolves gently at the edges.
    func smoothHorizontalScroll(
        bleedPadding: CGFloat = Design.Spacing.md,
        leadingFade: CGFloat = 16,
        trailingFade: CGFloat = 36
    ) -> some View {
        self.modifier(
            SmoothHorizontalScrollModifier(
                bleedPadding: bleedPadding,
                leadingFade: leadingFade,
                trailingFade: trailingFade
            )
        )
    }

    /// Gives vertical scroll views a smooth, continuous flow without harsh rectangular cutoffs.
    /// When at the very top, full opacity is maintained. When scrolled, a gentle top fade dissolves content smoothly.
    func smoothTopScrollFade(fadeLength: CGFloat = 28) -> some View {
        self.modifier(SmoothVerticalScrollModifier(topFade: fadeLength))
    }
}

/// Makes vertical scroll views fade gracefully at the top edge when scrolled,
/// avoiding harsh, abrupt rectangular cutoffs below navigation bars and custom headers.
struct SmoothVerticalScrollModifier: ViewModifier {
    var topFade: CGFloat

    @State private var isAtTop: Bool = true

    init(topFade: CGFloat = 28) {
        self.topFade = topFade
    }

    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: Bool.self) { geometry in
                geometry.contentOffset.y <= 2
            } action: { oldValue, newValue in
                if oldValue != newValue {
                    withAnimation(.easeInOut(duration: 0.20)) {
                        isAtTop = newValue
                    }
                }
            }
            .mask(
                VStack(spacing: 0) {
                    LinearGradient(
                        colors: [isAtTop ? .black : .clear, .black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: isAtTop ? 0 : topFade)

                    Rectangle()
                        .fill(Color.black)
                }
            )
    }
}

/// Makes horizontal scroll views bleed smoothly to container boundaries and adds
/// Makes horizontal scroll views bleed smoothly to container boundaries and adds
/// an adaptive dynamic alpha fade at the edges so content dissolves gracefully while scrolling,
/// but restores 100% normal appearance when scrolled all the way to the outside edges (leading or trailing).
struct SmoothHorizontalScrollModifier: ViewModifier {
    var bleedPadding: CGFloat
    var leadingFade: CGFloat
    var trailingFade: CGFloat

    @State private var isAtLeading: Bool = true
    @State private var isAtTrailing: Bool = false

    init(
        bleedPadding: CGFloat = Design.Spacing.md,
        leadingFade: CGFloat = 20,
        trailingFade: CGFloat = 36
    ) {
        self.bleedPadding = bleedPadding
        self.leadingFade = leadingFade
        self.trailingFade = trailingFade
    }

    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: ScrollEdgeState.self) { geometry in
                let maxOffsetX = max(0, geometry.contentSize.width - geometry.containerSize.width)
                if maxOffsetX <= 3 {
                    // Content fits without scrolling -> both edges normal
                    return ScrollEdgeState(isLeading: true, isTrailing: true)
                }
                let isLeading = geometry.contentOffset.x <= 3
                let isTrailing = geometry.contentOffset.x >= maxOffsetX - 3
                return ScrollEdgeState(isLeading: isLeading, isTrailing: isTrailing)
            } action: { oldValue, newValue in
                if oldValue != newValue {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        isAtLeading = newValue.isLeading
                        isAtTrailing = newValue.isTrailing
                    }
                }
            }
            .padding(.horizontal, -bleedPadding)
            .mask(
                HStack(spacing: 0) {
                    LinearGradient(
                        colors: [isAtLeading ? .black : .clear, .black],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: isAtLeading ? 0 : leadingFade)

                    Rectangle()
                        .fill(Color.black)

                    LinearGradient(
                        colors: [.black, isAtTrailing ? .black : .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: isAtTrailing ? 0 : trailingFade)
                }
            )
    }
}

private struct ScrollEdgeState: Equatable {
    var isLeading: Bool
    var isTrailing: Bool
}

// MARK: - Global Keyboard Dismissal System

/// Global gesture recognizer tag to avoid duplicate recognizers on the same UIWindow.
private final class GlobalKeyboardDismissGestureRecognizer: UITapGestureRecognizer {}

/// An invisible background view that installs a non-cancelling, non-delaying tap gesture
/// on the active UIWindow. Whenever the user taps anywhere outside an active text input,
/// the software keyboard is automatically dismissed.
public struct KeyboardDismissOverlay: UIViewRepresentable {
    public init() {}

    public func makeUIView(context: Context) -> KeyboardDismissUIView {
        let view = KeyboardDismissUIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }

    public func updateUIView(_ uiView: KeyboardDismissUIView, context: Context) {}
}

public final class KeyboardDismissUIView: UIView, UIGestureRecognizerDelegate {

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        attachGesture()
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        attachGesture()
    }

    private func attachGesture() {
        guard let window = self.window else { return }

        // Check if our custom gesture recognizer is already attached to this window
        if window.gestureRecognizers?.contains(where: { $0 is GlobalKeyboardDismissGestureRecognizer }) == true {
            return
        }

        let gesture = GlobalKeyboardDismissGestureRecognizer(target: self, action: #selector(handleWindowTap))
        gesture.cancelsTouchesInView = false
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        gesture.delegate = self
        window.addGestureRecognizer(gesture)
    }

    @objc private func handleWindowTap() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    // MARK: - UIGestureRecognizerDelegate

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // If the tap occurred inside an active text input (UITextField or UITextView),
        // do not trigger dismissal so cursor positioning and text selection work naturally.
        var currentView: UIView? = touch.view
        while let v = currentView {
            if v is UITextField || v is UITextView {
                return false
            }
            currentView = v.superview
        }
        return true
    }

    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // Always allow simultaneous recognition so buttons, scrolls, and other gestures work smoothly
        return true
    }
}

// MARK: - View Extension for Keyboard Dismissal

extension View {
    /// Dismisses the keyboard on tap outside text inputs and enables interactive keyboard dismissal on scrolls.
    public func dismissKeyboardOnTap() -> some View {
        self
            .background(KeyboardDismissOverlay())
            .scrollDismissesKeyboard(.interactively)
    }

    /// Explicitly closes the software keyboard programmatically.
    public func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

// MARK: - Pro Badge & Lock Visuals

public struct ProBadge: View {
    public var isCompact: Bool = false

    public init(isCompact: Bool = false) {
        self.isCompact = isCompact
    }

    public var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "crown.fill")
                .font(.system(size: isCompact ? 8 : 10, weight: .bold))
            Text("PRO")
                .font(.system(size: isCompact ? 9 : 11, weight: .black, design: .rounded))
        }
        .foregroundStyle(Color.black)
        .padding(.horizontal, isCompact ? 5 : 7)
        .padding(.vertical, isCompact ? 2 : 3)
        .background(
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.85, blue: 0.4), Color(red: 0.95, green: 0.70, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.2), radius: 2, y: 1)
    }
}

