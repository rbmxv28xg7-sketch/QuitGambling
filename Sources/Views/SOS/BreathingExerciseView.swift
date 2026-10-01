import SwiftUI
import SwiftData

/// 4-4-4-4 Box Breathing exercise with multi-layer organic glowing aura rings,
/// continuous timeline countdown ring, 4-phase segmented bar, and haptic pulses.
struct BreathingExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: SOSViewModel
    @AppStorage("isBreathingSoundMuted") private var isMuted: Bool = false

    @State private var innerRingScale: CGFloat = 0.88
    @State private var midRingScale: CGFloat = 0.92
    @State private var outerRingScale: CGFloat = 0.96
    @State private var auraOpacity: Double = 0.25
    @State private var phaseStartTime: Date = .now
    @State private var showVictoryBanner: Bool = false

    init(viewModel: SOSViewModel = SOSViewModel()) {
        self.viewModel = viewModel
    }

    private var phaseTitle: String {
        switch viewModel.breathingPhase {
        case .inhale: return "Inhale".loc
        case .holdIn: return "Hold Breath".loc
        case .exhale: return "Exhale".loc
        case .holdOut: return "Hold Breath".loc
        }
    }

    private var orbPhaseTitle: String {
        switch viewModel.breathingPhase {
        case .inhale: return "Inhale".loc
        case .holdIn: return "Hold".loc
        case .exhale: return "Exhale".loc
        case .holdOut: return "Hold".loc
        }
    }

    private var textOnOrb: Color {
        switch ThemeManager.shared.selectedColorway {
        case .cleanMonochrome, .solarChampagne:
            return Color(red: 0.08, green: 0.09, blue: 0.12)
        default:
            return Color.white
        }
    }

    private var phaseInstruction: String {
        switch viewModel.breathingPhase {
        case .inhale: return "Inhale deeply through your nose".loc
        case .holdIn: return "Hold your breath calmly".loc
        case .exhale: return "Slowly exhale through your mouth".loc
        case .holdOut: return "Rest in the quiet stillness".loc
        }
    }

    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()

            TimelineView(.animation(paused: !viewModel.isBreathingActive)) { context in
                let elapsed: TimeInterval = viewModel.isBreathingActive ? max(0.0, context.date.timeIntervalSince(phaseStartTime)) : 0.0
                let progress = max(0.0, min(1.0, elapsed / 4.0))

                VStack(spacing: 0) {
                    // Header Instruction & 4-Segment Bar
                    VStack(spacing: 8) {
                        // Phase Title & Description (Consistent White Top Text)
                        VStack(spacing: 4) {
                            Text(viewModel.isBreathingActive ? phaseTitle : "Box Breathing".loc)
                                .font(.title2)
                                .bold()
                                .foregroundStyle(Color.white)

                            Text(viewModel.isBreathingActive ? phaseInstruction : "4s Inhale • Hold • Exhale • Hold".loc)
                                .font(.subheadline)
                                .foregroundStyle(Color.white.opacity(0.80))
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }
                        .padding(.top, Design.Spacing.xs)

                        // Sleek 4-Segment Progress Bar (Balken)
                        segmentedProgressBar(progress: progress)
                    }

                    Spacer()

                    // Cycle Pill Badge
                    Group {
                        if viewModel.isBreathingActive {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 11, weight: .bold))
                                Text("Round %d".loc(max(1, viewModel.cycleCount + 1)))
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(Color.white.opacity(0.90))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial.opacity(0.45))
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(Color.white.opacity(0.18), lineWidth: 1))
                        } else {
                            Color.clear
                        }
                    }
                    .frame(height: 24)

                    Spacer().frame(height: 8)

                    // Concentric Glowing Breathing Orb (Compact & Serene)
                    breathingOrbView()

                    Spacer()

                    // Bottom Controls & Victory Banner
                    bottomControlsView
                }
            }
        }
        .navigationTitle("Breathing Exercise".loc)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: viewModel.isBreathingActive) {
            guard viewModel.isBreathingActive else { return }

            while viewModel.isBreathingActive {
                // Phase 1: Inhale (4s) - expands smoothly
                await runPhase(.inhale, targetScale: 1.25, aura: 0.65)
                guard viewModel.isBreathingActive else { break }

                // Phase 2: Hold In (4s) - stays steady at 1.25 (zero jump!)
                await runPhase(.holdIn, targetScale: 1.25, aura: 0.65)
                guard viewModel.isBreathingActive else { break }

                // Phase 3: Exhale (4s) - contracts smoothly
                await runPhase(.exhale, targetScale: 0.88, aura: 0.25)
                guard viewModel.isBreathingActive else { break }

                // Phase 4: Hold Out (4s) - stays steady at 0.88 (zero jump!)
                await runPhase(.holdOut, targetScale: 0.88, aura: 0.25)
                guard viewModel.isBreathingActive else { break }

                withAnimation(Design.Anim.spring) {
                    viewModel.cycleCount += 1
                }
            }
        }
        .onDisappear {
            viewModel.stopBreathing()
            resetOrb()
            AmbientSoundService.shared.stopBreathingSound()
        }
    }

    // MARK: - 4-Segment Box Breathing Progress Bar (Balken)
    private func segmentedProgressBar(progress: Double) -> some View {
        HStack(spacing: 6) {
            ForEach(SOSViewModel.BreathingPhase.allCases, id: \.self) { phase in
                let isPast = viewModel.isBreathingActive && phase.rawValue < viewModel.breathingPhase.rawValue
                let isCurrent = viewModel.isBreathingActive && phase == viewModel.breathingPhase

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.18))

                        if isPast {
                            Capsule()
                                .fill(Design.Colors.primary)
                        } else if isCurrent {
                            Capsule()
                                .fill(Design.Colors.primary)
                                .frame(width: max(0, min(geo.size.width, geo.size.width * progress)))
                        }
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(.horizontal, Design.Spacing.lg)
        .padding(.top, 4)
    }

    // MARK: - Breathing Orb View (Compact & Unified Colors)
    private func breathingOrbView() -> some View {
        ZStack {
            // Outer Aura Ring
            Circle()
                .fill(Design.Colors.primary.opacity(auraOpacity * 0.30))
                .frame(width: 210, height: 210)
                .scaleEffect(viewModel.isBreathingActive ? outerRingScale : 0.96)
                .blur(radius: 16)

            // Middle Aura Ring
            Circle()
                .fill(Design.Colors.primaryLight.opacity(auraOpacity * 0.55))
                .frame(width: 175, height: 175)
                .scaleEffect(viewModel.isBreathingActive ? midRingScale : 0.92)
                .blur(radius: 10)

            // Core Orb
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Design.Colors.primary, Design.Colors.primaryLight],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 140, height: 140)
                .scaleEffect(viewModel.isBreathingActive ? innerRingScale : 0.88)
                .shadow(color: Design.Colors.primary.opacity(0.40), radius: 14, y: 4)

            // Centered Fixed Frame Text (No Jitter, No Displaced Height)
            VStack(spacing: 2) {
                if viewModel.isBreathingActive {
                    Text(orbPhaseTitle)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(textOnOrb)

                    Text("4s")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(textOnOrb.opacity(0.85))
                } else {
                    Image(systemName: "lungs.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(textOnOrb)
                        .padding(.bottom, 2)

                    Text("Box Breathing")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(textOnOrb)

                    Text("4-4-4-4")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(textOnOrb.opacity(0.80))
                }
            }
            .frame(width: 130, height: 70)
            .multilineTextAlignment(.center)
        }
        .frame(height: 230)
    }

    // MARK: - Bottom Controls View
    private var bottomControlsView: some View {
        VStack(spacing: Design.Spacing.sm) {
            HStack(spacing: 10) {
                // Main Action (Start Breathing / End Exercise)
                Button {
                    SensoryFeedbackService.shared.buttonTap()
                    withAnimation(Design.Anim.spring) {
                        if viewModel.isBreathingActive {
                            let cycles = viewModel.cycleCount
                            viewModel.stopBreathing()
                            resetOrb()
                            AmbientSoundService.shared.stopBreathingSound()
                            if cycles >= 1 {
                                withAnimation(Design.Anim.spring) {
                                    showVictoryBanner = true
                                }
                            }
                        } else {
                            showVictoryBanner = false
                            viewModel.startBreathing()
                            AmbientSoundService.shared.startBreathingSound(isMuted: isMuted)
                        }
                    }
                } label: {
                    Label(viewModel.isBreathingActive ? "End Exercise".loc : "Start Breathing".loc, systemImage: viewModel.isBreathingActive ? "stop.fill" : "play.fill")
                        .font(.headline)
                        .foregroundStyle(viewModel.isBreathingActive ? Color.white : Design.Colors.textOnPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(viewModel.isBreathingActive ? Design.Colors.sos : Design.Colors.primary)
                        .clipShape(.rect(cornerRadius: Design.Radius.md))
                }
                .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.breathingPhase)

                // Mute Button (One Tap = Mute / Unmute)
                Button {
                    withAnimation(Design.Anim.spring) {
                        isMuted.toggle()
                        AmbientSoundService.shared.setMuted(isMuted, isBreathingActive: viewModel.isBreathingActive)
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: Design.Radius.md)
                            .fill(.ultraThinMaterial.opacity(0.45))
                            .overlay(
                                RoundedRectangle(cornerRadius: Design.Radius.md)
                                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                            )

                        Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.3.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(isMuted ? Color.white.opacity(0.40) : Design.Colors.primary)
                    }
                    .frame(width: 50, height: 50)
                }
                .sensoryFeedback(.selection, trigger: isMuted)
                .accessibilityLabel(isMuted ? "Enable ocean sound" : "Mute ocean sound")
            }

            if showVictoryBanner {
                VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                    HStack {
                        Image(systemName: "shield.checkmark.fill")
                            .foregroundStyle(Design.Colors.primary)
                        Text("%d Cycles Completed".loc(viewModel.cycleCount))
                            .font(.headline)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    Text("Your parasympathetic nervous system is activated. Would you like to record this victory in your Tracker?".loc)
                        .font(.caption2)
                        .foregroundStyle(Design.Colors.textSecondary)

                    HStack {
                        Button("Save Victory in Tracker".loc) {
                            saveBreathingVictory()
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
        .padding(.bottom, Design.Spacing.md)
    }

    // MARK: - Animation Engine
    private func runPhase(_ phase: SOSViewModel.BreathingPhase, targetScale: CGFloat, aura: Double) async {
        viewModel.breathingPhase = phase
        phaseStartTime = .now
        SensoryFeedbackService.shared.breathingPhasePulse()

        let midScale = targetScale == 1.25 ? 1.32 : 0.92
        let outerScale = targetScale == 1.25 ? 1.40 : 0.96

        withAnimation(.easeInOut(duration: 4.0)) {
            innerRingScale = targetScale
            midRingScale = midScale
            outerRingScale = outerScale
            auraOpacity = aura
        }

        try? await Task.sleep(for: .seconds(4))
    }

    private func resetOrb() {
        withAnimation(.easeOut(duration: 0.4)) {
            innerRingScale = 0.88
            midRingScale = 0.92
            outerRingScale = 0.96
            auraOpacity = 0.25
        }
    }

    private func saveBreathingVictory() {
        let log = CravingLog(
            date: .now,
            intensity: 6,
            trigger: "Breathing Exercise (4-4-4-4)",
            mood: 4,
            notes: "\(viewModel.cycleCount) cycles of box breathing successfully completed.",
            wasRelapse: false
        )
        modelContext.insert(log)
        try? modelContext.save()
        SensoryFeedbackService.shared.successFeedback()
    }
}

#Preview {
    NavigationStack {
        BreathingExerciseView(viewModel: SOSViewModel())
    }
}
