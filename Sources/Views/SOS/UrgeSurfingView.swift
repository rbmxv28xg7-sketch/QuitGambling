import SwiftUI
import SwiftData

/// 15-minute urge surfing mindfulness exercise with dynamic multi-layer wave simulation,
/// soothing ambient water soundscape, and an adaptive splitting control button.
struct UrgeSurfingView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: SOSViewModel
    @AppStorage("isUrgeSurfingSoundMuted") private var isMuted: Bool = false
    @State private var showVictoryBanner: Bool = false

    init(viewModel: SOSViewModel = SOSViewModel()) {
        self.viewModel = viewModel
    }

    private var timeString: String {
        let minutes = viewModel.urgeSurfingRemaining / 60
        let seconds = viewModel.urgeSurfingRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Progress from 0.0 (full urge / start) to 1.0 (calm / finished)
    private var calmnessProgress: Double {
        let elapsed = Double(900 - viewModel.urgeSurfingRemaining)
        return min(max(elapsed / 900.0, 0.0), 1.0)
    }

    private var isPaused: Bool {
        !viewModel.isUrgeSurfingActive && viewModel.urgeSurfingRemaining < 900
    }

    private var waveStageText: String {
        if !viewModel.isUrgeSurfingActive && viewModel.urgeSurfingRemaining == 900 {
            return "Start the timer when an urge arises.".loc
        }
        switch calmnessProgress {
        case 0..<0.25:
            return "Wave building up – stay calm and breathe".loc
        case 0.25..<0.5:
            return "Peak reached – every wave breaks soon".loc
        case 0.5..<0.85:
            return "Wave receding – you are in control".loc
        case 0.85..<1.0:
            return "Water turning still – you held steady".loc
        default:
            return "15-minute urge wave successfully conquered!".loc
        }
    }

    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()

            VStack(spacing: Design.Spacing.lg) {
                // Explanation Header
                Text("Watch the craving rise and fall like an ocean wave.".loc)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white.opacity(0.85))
                    .padding(.horizontal)
                    .padding(.top, Design.Spacing.sm)

                // Dynamic Wave Visualizer Card
                ZStack(alignment: .bottom) {
                    // Background Card
                    RoundedRectangle(cornerRadius: Design.Radius.xl)
                        .fill(Design.Colors.surface)
                        .frame(height: 280)
                        .shadow(color: .black.opacity(0.04), radius: 10, y: 4)

                    // Living Fluid Wave
                    AnimatedWaveView(calmness: viewModel.isUrgeSurfingActive ? calmnessProgress : 0.0)
                        .frame(height: 280)
                        .clipShape(.rect(cornerRadius: Design.Radius.xl))

                    // Floating Timer Centered
                    VStack {
                        Spacer()
                        Text(timeString)
                            .font(.system(size: 54, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white)
                            .shadow(color: Color.black.opacity(0.70), radius: 6, x: 0, y: 3)
                            .contentTransition(.numericText())
                        Spacer()
                    }
                    .frame(height: 280)

                    // Floating Stage Info Pill (strictly 1 line, positioned nicely lower)
                    Text(waveStageText)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.65))
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.40), radius: 4, y: 2)
                        .padding(.bottom, 16)
                }
                .padding(.horizontal)

                Spacer()

                // Control Buttons with Dynamic Island Expansion
                VStack(spacing: Design.Spacing.sm) {
                    HStack(spacing: 10) {
                        // 1. Main Action Button: Start Wave / Pause / Resume
                        Button {
                            SensoryFeedbackService.shared.buttonTap()
                            withAnimation(.spring(response: 0.36, dampingFraction: 0.70, blendDuration: 0.15)) {
                                if viewModel.isUrgeSurfingActive {
                                    viewModel.isUrgeSurfingActive = false
                                    AmbientSoundService.shared.pauseUrgeSurfingSound()
                                    if (900 - viewModel.urgeSurfingRemaining) >= 60 {
                                        showVictoryBanner = true
                                    }
                                } else if isPaused {
                                    showVictoryBanner = false
                                    viewModel.isUrgeSurfingActive = true
                                    AmbientSoundService.shared.resumeUrgeSurfingSound(isMuted: isMuted)
                                } else {
                                    showVictoryBanner = false
                                    viewModel.startUrgeSurfing()
                                    AmbientSoundService.shared.startUrgeSurfingSound(isMuted: isMuted)
                                }
                            }
                        } label: {
                            Label(
                                isPaused ? "Resume".loc : (viewModel.isUrgeSurfingActive ? "Pause".loc : "Start Wave".loc),
                                systemImage: isPaused ? "play.fill" : (viewModel.isUrgeSurfingActive ? "pause.fill" : "play.fill")
                            )
                            .font(.headline)
                            .foregroundStyle(Design.Colors.textOnPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(viewModel.isUrgeSurfingActive ? Design.Colors.gold : Design.Colors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }

                        // 2. Dynamic Island Expansion: Reset expands smoothly when paused
                        if isPaused {
                            Button {
                                SensoryFeedbackService.shared.buttonTap()
                                withAnimation(.spring(response: 0.36, dampingFraction: 0.70, blendDuration: 0.15)) {
                                    viewModel.stopUrgeSurfing()
                                    showVictoryBanner = false
                                    AmbientSoundService.shared.stopUrgeSurfingSound()
                                }
                            } label: {
                                Label("Reset".loc, systemImage: "arrow.counterclockwise")
                                    .font(.headline)
                                    .foregroundStyle(Color.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(.ultraThinMaterial.opacity(0.45))
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                                    )
                            }
                            .transition(
                                .asymmetric(
                                    insertion: .scale(scale: 0.15, anchor: .leading)
                                        .combined(with: .opacity),
                                    removal: .scale(scale: 0.15, anchor: .leading)
                                        .combined(with: .opacity)
                                )
                            )
                        }

                        // Mute Button for ambient water sound
                        Button {
                            withAnimation(Design.Anim.spring) {
                                isMuted.toggle()
                                AmbientSoundService.shared.setUrgeSurfingMuted(isMuted, isSurfingActive: viewModel.isUrgeSurfingActive)
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(.ultraThinMaterial.opacity(0.45))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                                    )

                                Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(isMuted ? Color.white.opacity(0.40) : Design.Colors.primary)
                            }
                            .frame(width: 52, height: 52)
                        }
                        .sensoryFeedback(.selection, trigger: isMuted)
                        .accessibilityLabel(isMuted ? "Enable ocean sound" : "Mute ocean sound")
                    }
                    .animation(.spring(response: 0.36, dampingFraction: 0.70, blendDuration: 0.15), value: isPaused)

                    if showVictoryBanner {
                        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                            HStack {
                                Image(systemName: "shield.checkmark.fill")
                                    .foregroundStyle(Design.Colors.primary)
                                Text("Craving Wave Conquered!".loc)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            Text("You stayed strong through the urge. Would you like to record this victory in your Tracker?".loc)
                                .font(.caption2)
                                .foregroundStyle(Design.Colors.textSecondary)

                            HStack {
                                Button("Save Victory in Tracker".loc) {
                                    SensoryFeedbackService.shared.buttonTap()
                                    saveUrgeSurfingVictory()
                                    withAnimation { showVictoryBanner = false }
                                }
                                .font(.subheadline)
                                .bold()
                                .foregroundStyle(Design.Colors.textOnPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Design.Colors.primary)
                                .clipShape(Capsule())

                                Button("Dismiss".loc) {
                                    SensoryFeedbackService.shared.selectionClick()
                                    withAnimation { showVictoryBanner = false }
                                }
                                .font(.caption)
                                .foregroundStyle(Design.Colors.textSecondary)
                                .padding(.leading, 8)
                            }
                            .padding(.top, 4)
                        }
                        .sereneCardStyle(padding: Design.Spacing.md)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, Design.Spacing.xl)
            }
        }
        .navigationTitle("Urge Surfing".loc)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: viewModel.isUrgeSurfingActive) {
            guard viewModel.isUrgeSurfingActive else { return }
            while viewModel.isUrgeSurfingActive && viewModel.urgeSurfingRemaining > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard viewModel.isUrgeSurfingActive else { break }
                viewModel.urgeSurfingRemaining -= 1
            }
            if viewModel.urgeSurfingRemaining == 0 {
                viewModel.isUrgeSurfingActive = false
                AmbientSoundService.shared.stopUrgeSurfingSound()
                withAnimation(Design.Anim.spring) {
                    showVictoryBanner = true
                }
            }
        }
        .onDisappear {
            viewModel.isUrgeSurfingActive = false
            AmbientSoundService.shared.stopUrgeSurfingSound()
        }
    }

    private func saveUrgeSurfingVictory() {
        let elapsed = 900 - viewModel.urgeSurfingRemaining
        let minutes = max(1, elapsed / 60)
        let log = CravingLog(
            date: .now,
            intensity: 7,
            trigger: "Urge Surfing (\(minutes) min)",
            mood: 4,
            notes: "Successfully navigated urge surfing session for \(minutes) min.",
            wasRelapse: false
        )
        modelContext.insert(log)
        try? modelContext.save()
        SensoryFeedbackService.shared.successFeedback()
    }
}

#Preview {
    NavigationStack {
        UrgeSurfingView(viewModel: SOSViewModel())
    }
}
