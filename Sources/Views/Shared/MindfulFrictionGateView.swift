import SwiftUI

/// Mindful Friction Gate: A mandatory 15-second breathing pause that breaks the gambling dopamine tunnel.
/// Used both in SOS Notbremse and as a mindful barrier when attempting to deactivate the screen shield.
struct MindfulFrictionGateView: View {
    @Environment(\.dismiss) private var dismiss

    var title: String = "15-Second Emergency Brake"
    var subtitle: String = "Breathe in and out slowly. Let the urge subside."
    var duration: Int = 10
    var confirmButtonTitle: String? = nil
    var onConfirmOverride: (() -> Void)? = nil
    var onVictory: ((String?) -> Void)? = nil

    private var initialDuration: Int { duration }
    @State private var timeRemaining: Int
    @State private var selectedEmotion: String? = nil
    @State private var orbScale: CGFloat = 0.92
    @State private var isCompleted: Bool = false

    init(
        title: String = "15-Second Emergency Brake",
        subtitle: String = "Breathe in and out slowly. Let the urge subside.",
        duration: Int = 10,
        confirmButtonTitle: String? = nil,
        onConfirmOverride: (() -> Void)? = nil,
        onVictory: ((String?) -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.duration = duration
        self.confirmButtonTitle = confirmButtonTitle
        self.onConfirmOverride = onConfirmOverride
        self.onVictory = onVictory
        self._timeRemaining = State(initialValue: duration)
    }

    private let emotions = [
        ("Stress", "bolt.fill"),
        ("Boredom", "clock.fill"),
        ("Loneliness", "person.fill.questionmark"),
        ("Frustration", "flame.fill"),
        ("Financial Stress", "banknote.fill"),
        ("Habit", "repeat")
    ]

    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()

            VStack(spacing: Design.Spacing.md) {
                // MARK: - Header
                VStack(spacing: 4) {
                    Text(isCompleted ? (confirmButtonTitle != nil ? "Pause Finished" : "Stayed Strong!") : title)
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Color.white)
                        .shadow(color: Color.black.opacity(0.40), radius: 2, y: 1)

                    Text(isCompleted ? (confirmButtonTitle != nil ? "Decide with a clear mind." : "You successfully resisted the impulse.") : subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .shadow(color: Color.black.opacity(0.35), radius: 1.5, y: 1)
                }
                .padding(.top, Design.Spacing.lg)

                Spacer()

                // MARK: - Center Orb / Victory Shield
                if isCompleted {
                    VStack(spacing: Design.Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Design.Colors.amberGold.opacity(0.20))
                                .frame(width: 150, height: 150)
                                .blur(radius: 10)

                            Circle()
                                .strokeBorder(Design.Colors.amberGold.opacity(0.50), lineWidth: 2)
                                .frame(width: 130, height: 130)

                            Image(systemName: "shield.checkmark.fill")
                                .font(.system(size: 64))
                                .foregroundStyle(Design.Colors.amberGold)
                        }

                        Text(confirmButtonTitle != nil ? "Reflected for 15 Seconds" : "Impulse Stopped")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white)

                        Text(confirmButtonTitle != nil ? "Do you really want to disable protection?" : "Your victory was logged in the tracker.")
                            .font(.subheadline)
                            .foregroundStyle(Color.white.opacity(0.85))
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    ZStack {
                        // Ambient Pulsing Glow
                        Circle()
                            .fill(
                                RadialGradient(
                                     colors: [
                                         Design.Colors.sos.opacity(0.30),
                                         Color.clear
                                     ],
                                     center: .center,
                                     startRadius: 30,
                                     endRadius: 90
                                 )
                             )
                             .frame(width: 180, height: 180)
                             .scaleEffect(orbScale)
                             .blur(radius: 12)

                        // Track Ring
                        Circle()
                            .stroke(Color.white.opacity(0.12), lineWidth: 7)
                            .frame(width: 140, height: 140)

                        // Active Countdown Ring
                        Circle()
                            .trim(from: 0.0, to: CGFloat(timeRemaining) / CGFloat(initialDuration))
                            .stroke(
                                LinearGradient(
                                     colors: [
                                         Design.Colors.warmFlame,
                                         Design.Colors.sos
                                     ],
                                     startPoint: .topLeading,
                                     endPoint: .bottomTrailing
                                 ),
                                 style: StrokeStyle(lineWidth: 7, lineCap: .round)
                             )
                             .frame(width: 140, height: 140)
                             .rotationEffect(.degrees(-90))
                             .animation(.linear(duration: 1.0), value: timeRemaining)

                        VStack(spacing: 2) {
                            Text("\(timeRemaining)")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white)
                                .contentTransition(.numericText())
                                .shadow(color: Color.black.opacity(0.40), radius: 2, y: 1)

                            Text("Seconds")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(Design.Colors.champagne)
                        }
                    }
                    .frame(height: 180)
                }

                Spacer()

                // MARK: - Emotion Reflection
                if !isCompleted {
                    VStack(alignment: .leading, spacing: Design.Spacing.xs) {
                        Text("What is triggering the urge?")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.90))
                            .padding(.horizontal)

                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: Design.Spacing.sm) {
                            ForEach(emotions, id: \.0) { name, icon in
                                Button {
                                    SensoryFeedbackService.shared.selectionClick()
                                    selectedEmotion = name
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: icon)
                                            .font(.caption)
                                        Text(name)
                                            .font(.caption)
                                            .bold()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background {
                                        if selectedEmotion == name {
                                            RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                                                .fill(Design.Colors.primary.opacity(0.35))
                                        } else {
                                            RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                                                .fill(.ultraThinMaterial.opacity(0.35))
                                        }
                                    }
                                    .foregroundStyle(selectedEmotion == name ? Design.Colors.amberGold : Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                                            .strokeBorder(
                                                selectedEmotion == name ? Design.Colors.amberGold : Color.white.opacity(0.18),
                                                lineWidth: selectedEmotion == name ? 1.5 : 0.8
                                            )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()

                // MARK: - Action Buttons
                if isCompleted {
                    if let confirmTitle = confirmButtonTitle {
                        // Shield deactivation mode
                        VStack(spacing: Design.Spacing.sm) {
                            Button {
                                SensoryFeedbackService.shared.successFeedback()
                                dismiss()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "shield.checkmark.fill")
                                        .font(.headline)
                                    Text("I'll Stay Protected")
                                        .font(.headline)
                                        .bold()
                                }
                                .foregroundStyle(Design.Colors.textOnPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Design.Colors.primary)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)

                            Button {
                                onConfirmOverride?()
                                dismiss()
                            } label: {
                                Text(confirmTitle)
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundStyle(Design.Colors.sos)
                                    .padding(.vertical, 6)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, Design.Spacing.lg)
                    } else {
                        // SOS Notbremse mode: Single clean victory button
                        Button {
                            SensoryFeedbackService.shared.successFeedback()
                            onVictory?(selectedEmotion)
                            dismiss()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.headline)
                                Text("Done & Return")
                                    .font(.headline)
                                    .bold()
                            }
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background {
                                ZStack {
                                    RoundedRectangle(cornerRadius: Design.Radius.card, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Design.Colors.warmFlame,
                                                    Design.Colors.amberGold
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    RoundedRectangle(cornerRadius: Design.Radius.card, style: .continuous)
                                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.card, style: .continuous))
                            .shadow(color: Design.Colors.amberGold.opacity(0.30), radius: 10, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                        .padding(.bottom, Design.Spacing.lg)
                    }
                } else {
                    Text("Pause in progress \(timeRemaining)s...")
                        .font(.caption)
                        .foregroundStyle(Design.Colors.textSecondary)
                        .padding(.bottom, Design.Spacing.lg)
                }
            }
        }
        .task {
            withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
                orbScale = 1.14
            }

            while timeRemaining > 0 {
                try? await Task.sleep(for: .seconds(1))
                timeRemaining -= 1
            }

            SensoryFeedbackService.shared.successFeedback()
            withAnimation(Design.Anim.spring) {
                isCompleted = true
            }
        }
    }
}

#Preview {
    MindfulFrictionGateView()
}
