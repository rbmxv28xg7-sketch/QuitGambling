import SwiftUI
import SwiftData

/// Minimalist, 1-Page Daily Morning Check-in.
/// Focused entirely on emotional awareness, clean aesthetics, and frictionless daily commitment.
struct DailyMorningCheckinView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var profiles: [UserProfile]
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]

    @State private var selectedMood: Int = 4
    @State private var moodProgress: Double = 4.0

    private var profile: UserProfile? {
        profiles.first
    }

    // MARK: - Dynamic Mood Copy
    private var moodTitle: String {
        switch selectedMood {
        case 1: return "Overwhelmed".loc
        case 2: return "Anxious".loc
        case 3: return "Stable & Calm".loc
        case 4: return "Optimistic".loc
        case 5: return "Strong & Free".loc
        default: return "Good".loc
        }
    }

    private var moodSubtitle: String {
        switch selectedMood {
        case 1: return "Don't let the pressure take control alone.".loc
        case 2: return "Pay close attention to your boundaries today.".loc
        case 3: return "A clear, grounded starting point for today.".loc
        case 4: return "Positive, empowering energy for your goals.".loc
        case 5: return "Full inner strength and clarity for your journey.".loc
        default: return ""
        }
    }

    private var moodColor: Color {
        let p = min(max(moodProgress, 1.0), 5.0)
        let lower = Int(floor(p))
        let upper = min(lower + 1, 5)
        let fraction = p - Double(lower)

        func baseColor(for index: Int) -> Color {
            switch index {
            case 1: return Color(red: 0.68, green: 0.78, blue: 0.94) // Quiet Twilight Mist
            case 2: return Color(red: 0.95, green: 0.55, blue: 0.42) // Warm Copper / Terracotta
            case 3: return Color(red: 0.78, green: 0.98, blue: 0.20) // Vibrant Zen Lime
            case 4: return Color(red: 0.98, green: 0.68, blue: 0.18) // Signature Amber Gold
            case 5: return Color(red: 1.0, green: 0.85, blue: 0.40)  // Solar Champagne Topaz
            default: return Design.Colors.amberGold
            }
        }

        let c1 = baseColor(for: lower)
        let c2 = baseColor(for: upper)
        return c1.blend(to: c2, fraction: fraction)
    }

    var body: some View {
        GeometryReader { screenGeo in
            ZStack {
                // Serene Fluted Glass & Dark Obsidian Base
                FlutedGlassBackgroundView()

                VStack(spacing: 0) {
                    // Top Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(greetingText)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Design.Colors.champagne)
                                .textCase(.uppercase)
                                .tracking(1.2)

                            Text("How are you feeling today?".loc)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white)
                        }

                        Spacer()

                        // Close Button
                        Button {
                            SensoryFeedbackService.shared.selectionClick()
                            completeCheckinAndDismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Design.Colors.textSecondary)
                                .frame(width: 34, height: 34)
                                .background(.ultraThinMaterial.opacity(0.40))
                                .clipShape(Circle())
                                .overlay(Circle().strokeBorder(Color.white.opacity(0.18), lineWidth: 0.8))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, Design.Spacing.lg)
                    .padding(.top, Design.Spacing.md)

                    Spacer(minLength: 16)

                    // Animated Zen Companion Spirit (Smooth 120 FPS Morphing & Reactive)
                    ZenCompanionView(
                        moodProgress: moodProgress,
                        screenSize: screenGeo.size
                    )
                    .zIndex(10)

                    // Large Dynamic Mood Title & Subtitle
                VStack(spacing: 6) {
                    Text(moodTitle)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(moodColor)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: selectedMood)

                    Text(moodSubtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Design.Spacing.xl)
                        .animation(.easeInOut(duration: 0.25), value: selectedMood)
                }
                .padding(.top, Design.Spacing.lg)

                Spacer(minLength: 24)

                // Primary Action: Hold to pledge staying gamble-free today
                CheckinHoldPledgeButton {
                    completeCheckinAndDismiss()
                }
                .padding(.horizontal, Design.Spacing.lg)
                .padding(.bottom, Design.Spacing.lg)

                // Butter-smooth Curved Mood Slider Dock with 120 FPS continuous tracking
                CurvedMoodDockView(
                    selectedMood: $selectedMood,
                    continuousProgress: $moodProgress
                )
                .padding(.horizontal, Design.Spacing.lg)
                .padding(.bottom, Design.Spacing.xl)
            }
        }
    }
    .onAppear {
        moodProgress = Double(selectedMood)
    }
}

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good Morning".loc
        case 12..<18: return "Good Afternoon".loc
        default: return "Good Evening".loc
        }
    }

    // MARK: - Save Check-in and Dismiss
    private func completeCheckinAndDismiss() {
        // 1. Mark UserProfile as pledged today
        if let p = profile {
            p.pledgedToday = true
            p.lastPledgeDate = .now
        }

        // 2. Create or Update JournalEntry for today
        let calendar = Calendar.current
        if let existingToday = entries.first(where: { calendar.isDateInToday($0.date) }) {
            existingToday.mood = selectedMood
        } else {
            let newEntry = JournalEntry(
                date: .now,
                text: "",
                mood: selectedMood,
                gratitude: "",
                hadCravings: selectedMood <= 2,
                wasRelapse: false,
                moneyLost: 0.0,
                tag: ""
            )
            modelContext.insert(newEntry)
        }

        try? modelContext.save()

        // 3. Mark in UserDefaults
        UserDefaults.standard.set(Date.now.timeIntervalSince1970, forKey: "last_morning_checkin_timestamp")

        dismiss()
    }
}

// MARK: - Helper to Check if Checkin Needed Today

enum MorningCheckinService {
    static func shouldShowCheckinToday() -> Bool {
        let lastTimestamp = UserDefaults.standard.double(forKey: "last_morning_checkin_timestamp")
        guard lastTimestamp > 0 else {
            return true // Never checked in
        }
        let lastDate = Date(timeIntervalSince1970: lastTimestamp)
        return !Calendar.current.isDateInToday(lastDate)
    }

    static func forceShowCheckin() {
        UserDefaults.standard.removeObject(forKey: "last_morning_checkin_timestamp")
    }
}

// MARK: - Hold-to-Pledge Action Button

struct CheckinHoldPledgeButton: View {
    var onConfirmed: () -> Void

    @State private var holdProgress: Double = 0.0
    @State private var isHolding: Bool = false
    @State private var isConfirmed: Bool = false

    var body: some View {
        ZStack {
            // Warm Liquid Glass Track Base
            Capsule()
                .fill(.ultraThinMaterial.opacity(0.35))
                .overlay(
                    Capsule()
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
                )
                .overlay(
                    Capsule()
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
                )
                .shadow(color: Color.black.opacity(0.25), radius: 12, y: 6)

            // Radiant Liquid Amber Fill
            GeometryReader { geo in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Design.Colors.warmFlame,
                                Design.Colors.amberGold
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * holdProgress, height: 54)
                    .animation(.linear(duration: 0.05), value: holdProgress)
            }
            .clipShape(Capsule())

            // Content Label with Dual-Layer Inverted Mask for 100% Contrast at any Fill Progress
            if isConfirmed {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Design.Colors.textOnPrimary)
                    Text("Daily Pledge Kept".loc)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Design.Colors.textOnPrimary)
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                // 1. Base Layer (White text on dark/transparent glass track)
                holdButtonContent(textColor: Color.white, iconColor: Design.Colors.amberGold)

                // 2. High-Contrast Overlay Layer (Masked to fill progress: dark text on bright fill!)
                GeometryReader { geo in
                    let fillWidth = geo.size.width * holdProgress
                    holdButtonContent(textColor: Design.Colors.textOnPrimary, iconColor: Design.Colors.textOnPrimary)
                        .frame(width: geo.size.width, height: 54)
                        .mask(alignment: .leading) {
                            Rectangle()
                                .frame(width: fillWidth, height: 54)
                        }
                }
                .allowsHitTesting(false)
            }
        }
        .frame(height: 54)
        .contentShape(Capsule())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isHolding && !isConfirmed {
                        startHolding()
                    }
                }
                .onEnded { _ in
                    if isHolding && !isConfirmed {
                        cancelHolding()
                    }
                }
        )
        .sensoryFeedback(.impact(weight: .medium), trigger: isHolding)
        .sensoryFeedback(.success, trigger: isConfirmed)
    }

    private func startHolding() {
        isHolding = true
        Task {
            let steps = 25
            let duration = 0.95 / Double(steps)
            for i in 1...steps {
                guard isHolding && !isConfirmed else { break }
                try? await Task.sleep(for: .seconds(duration))
                guard isHolding && !isConfirmed else { break }
                holdProgress = Double(i) / Double(steps)
                if i % 6 == 0 {
                    SensoryFeedbackService.shared.selectionClick()
                }
            }

            if isHolding && holdProgress >= 0.98 {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    isConfirmed = true
                }
                SensoryFeedbackService.shared.pledgeConfirmed()
                isHolding = false
                holdProgress = 1.0

                try? await Task.sleep(for: .milliseconds(500))
                onConfirmed()
            }
        }
    }

    private func cancelHolding() {
        isHolding = false
        withAnimation(.easeOut(duration: 0.2)) {
            holdProgress = 0
        }
    }

    @ViewBuilder
    private func holdButtonContent(textColor: Color, iconColor: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: isHolding ? "shield.fill" : "shield.checkered")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(iconColor)

            Text(isHolding ? "Confirming pledge...".loc : "Pledge to stay gamble-free today".loc)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Spacer(minLength: 4)

            if !isHolding {
                Text("Hold")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Design.Colors.champagne)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial.opacity(0.45))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(Design.Colors.champagne.opacity(0.30), lineWidth: 0.8)
                    )
            }
        }
        .padding(.horizontal, Design.Spacing.md)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        DailyMorningCheckinView()
            .modelContainer(for: [UserProfile.self, JournalEntry.self], inMemory: true)
    }
}
