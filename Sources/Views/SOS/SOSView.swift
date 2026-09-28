import SwiftUI
import SwiftData

// MARK: - SOS View

enum SOSDestination: String, Hashable, Identifiable {
    case breathing
    case urgeSurfing
    case grounding
    case deads
    case reasons
    case buddy
    case hotlines

    var id: String { rawValue }
}

/// SOS Emergency Hub: Immediate crisis intervention, focus minigames, soothing exercises, and life-lines.
struct SOSView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @State private var hotlineStore = HotlineStore.shared
    @State private var viewModel = SOSViewModel()
    @State private var activeMinigame: FocusMinigameType? = nil
    @State private var activeDestination: SOSDestination? = nil
    @State private var showingPreventedLossSheet = false

    @Query private var contacts: [EmergencyContact]
    @Query private var cravingLogs: [CravingLog]

    private var buddy: EmergencyContact? { contacts.first }

    var body: some View {
        NavigationStack {
            ZStack {
                FlutedGlassBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Design.Spacing.lg) {
                        // MARK: - Reassuring Header (Short & Calm)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("You are not alone.".loc)
                                .font(.headline)
                                .bold()
                                .foregroundStyle(Color.white)
                                .shadow(color: Color.black.opacity(0.40), radius: 2, y: 1)

                            Text("Immediate urge relief & crisis support.".loc)
                                .font(.caption)
                                .foregroundStyle(Color.white.opacity(0.85))
                                .shadow(color: Color.black.opacity(0.35), radius: 1.5, y: 1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                        // MARK: - Direct Quick Action Bar (Hotline & Buddy)
                        quickContactActionBar
                            .padding(.horizontal)

                        // MARK: - Acute Victory Action: Prevented Loss Booster
                        Button {
                            showingPreventedLossSheet = true
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Design.Colors.gold.opacity(0.20))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "checkmark.shield.fill")
                                        .font(.body)
                                        .foregroundStyle(Design.Colors.gold)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Urge defeated? Record your win".loc)
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundStyle(Color.white)
                                    Text("Log prevented bet directly as saved money".loc)
                                        .font(.caption2)
                                        .foregroundStyle(Design.Colors.textSecondary)
                                }

                                Spacer()

                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(Design.Colors.gold)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                                    .fill(Design.Colors.gold.opacity(0.12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                                            .strokeBorder(Design.Colors.gold.opacity(0.35), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)

                        // MARK: - Section 1: Focus Minigames (Impulse Interruption)
                        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                            Text("Focus & Brain Games".loc)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white)
                                .shadow(color: Color.black.opacity(0.35), radius: 1.5, y: 1)
                                .padding(.horizontal)

                            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: Design.Spacing.md) {
                                Button {
                                    SensoryFeedbackService.shared.selectionClick()
                                    activeMinigame = .stroop
                                } label: {
                                    SOSCard(
                                        title: "Stroop Test".loc,
                                        subtitle: "Pick color, not the word".loc,
                                        icon: "paintpalette.fill",
                                        tintColor: Design.Colors.primary
                                    )
                                }
                                .buttonStyle(.plain)

                                Button {
                                    SensoryFeedbackService.shared.selectionClick()
                                    activeMinigame = .memory
                                } label: {
                                    SOSCard(
                                        title: "Tile Memory".loc,
                                        subtitle: "Memorize the pattern".loc,
                                        icon: "square.grid.3x3.fill",
                                        tintColor: Design.Colors.primary
                                    )
                                }
                                .buttonStyle(.plain)

                                Button {
                                    SensoryFeedbackService.shared.selectionClick()
                                    activeMinigame = .connect
                                } label: {
                                    SOSCard(
                                        title: "Connect".loc,
                                        subtitle: "Link letter pairs".loc,
                                        icon: "point.filled.topleft.down.curvedto.point.bottomright.up",
                                        tintColor: Design.Colors.primary
                                    )
                                }
                                .buttonStyle(.plain)

                                Button {
                                    SensoryFeedbackService.shared.selectionClick()
                                    activeMinigame = .multiplication
                                } label: {
                                    SOSCard(
                                        title: "Mental Math".loc,
                                        subtitle: "Arithmetic challenge".loc,
                                        icon: "multiply.circle.fill",
                                        tintColor: Design.Colors.primary
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal)
                        }

                        // MARK: - Section 2: Immediate Exercises
                        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                            Text("Immediate Exercises".loc)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white)
                                .shadow(color: Color.black.opacity(0.35), radius: 1.5, y: 1)
                                .padding(.horizontal)

                            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: Design.Spacing.md) {
                                Button {
                                    SensoryFeedbackService.shared.selectionClick()
                                    activeDestination = .breathing
                                } label: {
                                    SOSCard(
                                        title: "Box Breathing".loc,
                                        subtitle: "Lower heart rate".loc,
                                        icon: "lungs.fill",
                                        tintColor: Design.Colors.primary
                                    )
                                }
                                .buttonStyle(.plain)

                                Button {
                                    SensoryFeedbackService.shared.selectionClick()
                                    activeDestination = .urgeSurfing
                                } label: {
                                    SOSCard(
                                        title: "Urge Surfing".loc,
                                        subtitle: "Ride the craving wave".loc,
                                        icon: "water.waves",
                                        tintColor: Design.Colors.primary
                                    )
                                }
                                .buttonStyle(.plain)

                                Button {
                                    SensoryFeedbackService.shared.selectionClick()
                                    activeDestination = .grounding
                                } label: {
                                    SOSCard(
                                        title: "5-4-3-2-1 Grounding".loc,
                                        subtitle: "Sensory refocus".loc,
                                        icon: "figure.mind.and.body",
                                        tintColor: Design.Colors.primary
                                    )
                                }
                                .buttonStyle(.plain)

                                Button {
                                    SensoryFeedbackService.shared.selectionClick()
                                    activeDestination = .deads
                                } label: {
                                    SOSCard(
                                        title: "D.E.A.D.S.".loc,
                                        subtitle: "5 coping strategies".loc,
                                        icon: "shield.fill",
                                        tintColor: Design.Colors.primary
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal)
                        }

                        // MARK: - Section 3: Support Network & Motivation
                        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                            Text("Support Network & Motivation".loc)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white)
                                .shadow(color: Color.black.opacity(0.35), radius: 1.5, y: 1)
                                .padding(.horizontal)

                            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: Design.Spacing.md) {
                                Button {
                                    SensoryFeedbackService.shared.selectionClick()
                                    activeDestination = .reasons
                                } label: {
                                    SOSCard(
                                        title: "My Reasons".loc,
                                        subtitle: "Personal motivation".loc,
                                        icon: "heart.text.square.fill",
                                        tintColor: Design.Colors.primary
                                    )
                                }
                                .buttonStyle(.plain)

                                Button {
                                    SensoryFeedbackService.shared.selectionClick()
                                    activeDestination = .buddy
                                } label: {
                                    SOSCard(
                                        title: buddy == nil ? "Emergency Buddy".loc : (buddy?.name ?? "Buddy".loc),
                                        subtitle: buddy == nil ? "Set up trusted contact".loc : "Manage contact details".loc,
                                        icon: "person.2.fill",
                                        tintColor: Design.Colors.primary
                                    )
                                }
                                .buttonStyle(.plain)

                                Button {
                                    SensoryFeedbackService.shared.selectionClick()
                                    activeDestination = .hotlines
                                } label: {
                                    SOSCard(
                                        title: "All Hotlines".loc,
                                        subtitle: "\(HotlineService.hotlines(for: HotlineService.detectedCountryCode).countryName) & USA",
                                        icon: "phone.fill",
                                        tintColor: Design.Colors.primary
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, Design.Spacing.sm)
                    .padding(.bottom, 96)
                }
                .navigationTitle("SOS Emergency Hub".loc)
                .navigationDestination(item: $activeDestination) { destination in
                    switch destination {
                    case .breathing:
                        BreathingExerciseView(viewModel: viewModel)
                    case .urgeSurfing:
                        UrgeSurfingView(viewModel: viewModel)
                    case .grounding:
                        GroundingExerciseView(viewModel: viewModel)
                    case .deads:
                        DEADSStrategyView()
                    case .reasons:
                        ReasonsCardDeckView()
                    case .buddy:
                        EmergencyBuddyView()
                    case .hotlines:
                        HotlineListView()
                    }
                }
                .fullScreenCover(item: $activeMinigame) { game in
                    MinigameHostModal(selectedGame: game)
                        .scrollIndicators(.hidden)
                }
                .sheet(isPresented: $showingPreventedLossSheet) {
                    AddPreventedLossSheet(defaultContextTag: "SOS Emergency")
                        .scrollIndicators(.hidden)
                }
                .scrollIndicators(.hidden)
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Direct Quick Contact Bar
    private var quickContactActionBar: some View {
        HStack(spacing: Design.Spacing.sm) {
            // Starred Hotlines Menu
            let starred = hotlineStore.starredHotlines()

            Menu {
                if !starred.isEmpty {
                    Section("Favorites (Speed Dial)".loc) {
                        ForEach(starred) { item in
                            Button {
                                SensoryFeedbackService.shared.selectionClick()
                                let clean = item.number.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
                                if let url = URL(string: "tel:\(clean)") {
                                    openURL(url)
                                }
                            } label: {
                                Label("\(item.name) (\(item.number))", systemImage: "star.fill")
                            }
                        }
                    }

                    Divider()
                }

                NavigationLink(destination: HotlineListView()) {
                    Label(starred.isEmpty ? "View Hotlines & Star...".loc : "All Hotlines & Favorites...".loc, systemImage: "list.star")
                }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(Design.Colors.sos)
                    Text(starred.count == 1 ? starred[0].name : "24/7 Hotline".loc)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Design.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(.ultraThinMaterial.opacity(0.40))
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.20), lineWidth: 0.8))
            }

            // Buddy Single-Line Capsule
            if let buddy {
                Menu {
                    Button {
                        SensoryFeedbackService.shared.selectionClick()
                        callContact(buddy)
                    } label: {
                        Label("Call %@".loc(buddy.name), systemImage: "phone.fill")
                    }

                    Button {
                        SensoryFeedbackService.shared.selectionClick()
                        sendSMS(buddy)
                    } label: {
                        Label("Send SMS".loc, systemImage: "message.fill")
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(Design.Colors.primary)
                        Text(buddy.name)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(.ultraThinMaterial.opacity(0.40))
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.20), lineWidth: 0.8))
                }
            } else {
                Button {
                    SensoryFeedbackService.shared.selectionClick()
                    activeDestination = .buddy
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 13))
                            .foregroundStyle(Design.Colors.primaryLight)
                        Text("Buddy".loc)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(.ultraThinMaterial.opacity(0.40))
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.20), lineWidth: 0.8))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func callContact(_ contact: EmergencyContact) {
        let cleanPhone = contact.phoneNumber.filter { "0123456789+".contains($0) }
        if let url = URL(string: "tel:\(cleanPhone)") {
            openURL(url)
        }
    }

    private func sendSMS(_ contact: EmergencyContact) {
        let cleanPhone = contact.phoneNumber.filter { "0123456789+".contains($0) }
        let encodedMessage = contact.customMessage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "sms:\(cleanPhone)&body=\(encodedMessage)") {
            openURL(url)
        }
    }
}

// MARK: - SOS Grid Card

struct SOSCard: View {
    let title: String
    let subtitle: String
    let icon: String
    var tintColor: Color = Design.Colors.primary

    var body: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(tintColor.opacity(0.18))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(tintColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.white)
                    .shadow(color: Color.black.opacity(0.40), radius: 1.5, y: 1)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.white.opacity(0.88))
                    .shadow(color: Color.black.opacity(0.35), radius: 1.5, y: 1)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .sereneCardStyle(padding: Design.Spacing.md)
        .contentShape(Rectangle())
    }
}

// MARK: - FOCUS MINIGAMES SUITE (OPAL-STYLE COGNITIVE DISPLACEMENT)

enum FocusMinigameType: String, CaseIterable, Identifiable {
    case stroop = "Stroop"
    case memory = "Memory"
    case connect = "Connect"
    case multiplication = "Multiplication"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .stroop: "Stroop Test"
        case .memory: "Tile Memory"
        case .connect: "Connect"
        case .multiplication: "Mental Math"
        }
    }
}

// MARK: - Minigame Host Modal (Opal Look & Feel)

struct MinigameHostModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State var selectedGame: FocusMinigameType
    @State private var hasWon = false

    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()

            VStack(spacing: 0) {
                // Top Navigation Bar (Close & Switcher)
                HStack {
                    Button {
                        SensoryFeedbackService.shared.selectionClick()
                        MinigameSessionManager.shared.resetAll()
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial.opacity(0.50))
                                .frame(width: 38, height: 38)
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color.white)
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    // Game Switcher Menu
                    Menu {
                        ForEach(FocusMinigameType.allCases) { game in
                            Button {
                                SensoryFeedbackService.shared.selectionClick()
                                MinigameSessionManager.shared.resetAll()
                                withAnimation(Design.Anim.smooth) {
                                    selectedGame = game
                                    hasWon = false
                                }
                            } label: {
                                Label(game.title, systemImage: "gamecontroller.fill")
                            }
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial.opacity(0.50))
                                .frame(width: 38, height: 38)
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)

                if hasWon {
                    victoryView
                } else {
                    Spacer(minLength: 8)

                    Group {
                        switch selectedGame {
                        case .stroop:
                            StroopGameView(onWin: handleWin)
                        case .memory:
                            TileMemoryGameView(onWin: handleWin)
                        case .connect:
                            ConnectGameView(onWin: handleWin)
                        case .multiplication:
                            MultiplicationGameView(onWin: handleWin)
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))

                    Spacer(minLength: 8)

                    // Bottom Skip Button (only while playing)
                    Button {
                        SensoryFeedbackService.shared.selectionClick()
                        MinigameSessionManager.shared.resetAll()
                        dismiss()
                    } label: {
                        Text("Skip".loc)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(Design.Colors.textSecondary)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 14)
                }
            }
        }
    }

    private var victoryView: some View {
        VStack(spacing: Design.Spacing.lg) {
            Spacer()

            // Luminous Aurora Spotlight & Floating Gem
            ZStack {
                // Top radial aura glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(red: 0.15, green: 0.85, blue: 0.45).opacity(0.35), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .blur(radius: 20)

                // Faceted liquid glass card
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(.ultraThinMaterial.opacity(0.70))
                    .frame(width: 110, height: 110)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.50), Color.white.opacity(0.10)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color.black.opacity(0.45), radius: 16, y: 8)

                // Radiant Checkmark
                Image(systemName: "checkmark")
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.20, green: 0.90, blue: 0.55))
                    .shadow(color: Color(red: 0.20, green: 0.90, blue: 0.55).opacity(0.75), radius: 12)
            }

            VStack(spacing: Design.Spacing.sm) {
                // Eyebrow
                Text("IMPULSE DISRUPTED".loc)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(Color(red: 0.20, green: 0.90, blue: 0.55))

                // Title
                Text("Urge Overcome".loc)
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.white)
                    .shadow(color: Color.black.opacity(0.40), radius: 2, y: 1)

                // Subtitle
                Text("You interrupted the automatic gambling impulse and gave your mind time to maintain control.".loc)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, Design.Spacing.md)
            }

            // Stat chip
            HStack(spacing: 8) {
                Image(systemName: "shield.checkmark.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(red: 0.20, green: 0.90, blue: 0.55))

                Text("Saved as a resisted craving in Tracker".loc)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.90))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial.opacity(0.40))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.8)
            )

            Spacer()

            // Action Buttons
            VStack(spacing: 12) {
                Button {
                    SensoryFeedbackService.shared.selectionClick()
                    MinigameSessionManager.shared.resetAll()
                    dismiss()
                } label: {
                    Text("I Stay Free".loc)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Design.Colors.textOnPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Design.Colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous))
                        .shadow(color: Design.Colors.primary.opacity(0.30), radius: 10, y: 4)
                }
                .buttonStyle(.plain)

                Button {
                    SensoryFeedbackService.shared.selectionClick()
                    MinigameSessionManager.shared.resetAll()
                    withAnimation(Design.Anim.smooth) {
                        hasWon = false
                    }
                } label: {
                    Text("Play Another Game for Distraction".loc)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Design.Colors.textSecondary)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Design.Spacing.lg)
            .padding(.bottom, Design.Spacing.md)
        }
        .padding(.horizontal)
    }

    private func handleWin() {
        SensoryFeedbackService.shared.minigameGameWon()
        MinigameSessionManager.shared.resetAll()
        let log = CravingLog(
            date: .now,
            intensity: 6,
            trigger: "Focus Game (\(selectedGame.title))",
            mood: 4,
            notes: "Urge successfully averted with cognitive distraction.",
            wasRelapse: false
        )
        modelContext.insert(log)
        try? modelContext.save()

        withAnimation(Design.Anim.spring) {
            hasWon = true
        }
    }
}

// MARK: - 1. STROOP MINIGAME VIEW

struct StroopGameView: View {
    var onWin: () -> Void

    init(onWin: @escaping () -> Void) {
        self.onWin = onWin
    }

    typealias StroopColor = StroopGameSession.StroopColor

    private let allColors: [StroopColor] = [
        StroopColor(id: "red", name: "Red", color: Color(red: 255/255.0, green: 78/255.0, blue: 107/255.0)),       // #FF4E6B
        StroopColor(id: "yellow", name: "Yellow", color: Color(red: 254/255.0, green: 198/255.0, blue: 0/255.0)),    // #FEC600
        StroopColor(id: "green", name: "Green", color: Color(red: 1/255.0, green: 199/255.0, blue: 165/255.0)),     // #01C7A5
        StroopColor(id: "purple", name: "Purple", color: Color(red: 171/255.0, green: 145/255.0, blue: 254/255.0)),   // #AB91FE
        StroopColor(id: "orange", name: "Orange", color: Color(red: 254/255.0, green: 118/255.0, blue: 89/255.0)),  // #FE7659
        StroopColor(id: "blue", name: "Blue", color: Color(red: 161/255.0, green: 197/255.0, blue: 254/255.0))      // #A1C5FE
    ]

    @Environment(\.scenePhase) private var scenePhase
    private var session = MinigameSessionManager.shared.stroop

    @State private var shakeTrigger = 0
    @State private var roundStartTime: Date = .now
    @State private var isTimerRunning: Bool = true
    @State private var timerTask: Task<Void, Never>? = nil

    private let totalRounds = 5
    private let roundDuration: TimeInterval = 3.0

    var body: some View {
        VStack(spacing: Design.Spacing.md) {
            // Header
            VStack(spacing: 6) {
                Text("Stroop Test".loc)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)

                Text("Select the text color, not the word".loc)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Design.Colors.textSecondary)
            }
            .padding(.horizontal)

            // Abgerundete Box, umgeben von einem Zeitstrahl (gegen den Uhrzeigersinn ablaufend über ca. 3 Sek.)
            TimelineView(.animation) { context in
                let elapsed: TimeInterval = {
                    if isTimerRunning {
                        return max(0.0, context.date.timeIntervalSince(roundStartTime))
                    } else {
                        return roundDuration - session.remainingTime
                    }
                }()
                let progress = max(0.0, min(1.0, 1.0 - (elapsed / roundDuration)))

                ZStack {
                    // Box-Hintergrund
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial.opacity(0.35))

                    // Dezent sichtbare Basis-Linie
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 3)

                    // Zeitstrahl: voll bei 1.0, läuft gegen den Uhrzeigersinn ab
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color.white.opacity(0.80),
                            style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                        )

                    // In der Mitte: Name einer zufälligen Farbe in der Farbe einer anderen
                    if let word = session.currentWord, let ink = session.currentInk {
                        VStack(spacing: 6) {
                            Text(word.name.loc)
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                                .foregroundStyle(ink.color)
                                .shadow(color: Color.black.opacity(0.35), radius: 2, y: 1)

                            Text("%d of %d".loc(session.currentRound, totalRounds))
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(Design.Colors.textSecondary)
                        }
                    }
                }
                .frame(width: 324, height: 180)
            }
            .keyframeAnimator(initialValue: CGFloat.zero, trigger: shakeTrigger) { content, offset in
                content.offset(x: offset)
            } keyframes: { _ in
                KeyframeTrack {
                    CubicKeyframe(-10, duration: 0.05)
                    CubicKeyframe(10, duration: 0.06)
                    CubicKeyframe(-7, duration: 0.05)
                    CubicKeyframe(7, duration: 0.05)
                    CubicKeyframe(-3, duration: 0.04)
                    CubicKeyframe(3, duration: 0.04)
                    CubicKeyframe(0, duration: 0.04)
                }
            }

            // Unter der Box: "Welche Farbe wird oben angezeigt?"
            VStack(spacing: Design.Spacing.md) {
                Text("Which color is shown above?".loc)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.85))

                // Die 6 verschiedenen Farben in Kreisen (neue Reihenfolge nach jedem Raten)
                HStack(spacing: 12) {
                    ForEach(session.displayedColors) { choice in
                        Button {
                            handleColorSelect(choice)
                        } label: {
                            Circle()
                                .fill(choice.color)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 1.5)
                                )
                                .shadow(color: choice.color.opacity(0.45), radius: 6, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: session.displayedColors)
            }
            .padding(.top, Design.Spacing.xs)
        }
        .onAppear {
            if !session.isGameActive {
                session.isGameActive = true
                session.displayedColors = allColors.shuffled()
                generatePuzzle()
                roundStartTime = .now
                startTimer(duration: roundDuration)
            } else {
                resumeTimer()
            }
        }
        .sensoryFeedback(.impact(weight: .medium, intensity: 1.0), trigger: session.currentRound)
        .sensoryFeedback(.warning, trigger: shakeTrigger)
        .onDisappear {
            timerTask?.cancel()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase != .active {
                pauseTimer()
            } else if newPhase == .active && session.isGameActive {
                resumeTimer()
            }
        }
    }

    private func startTimer(duration: TimeInterval) {
        timerTask?.cancel()
        session.remainingTime = duration
        isTimerRunning = true
        timerTask = Task {
            try? await Task.sleep(for: .milliseconds(Int(duration * 1000)))
            guard !Task.isCancelled, isTimerRunning else { return }
            handleTimeout()
        }
    }

    private func pauseTimer() {
        timerTask?.cancel()
        isTimerRunning = false
        let elapsed = Date.now.timeIntervalSince(roundStartTime)
        session.remainingTime = max(0.2, roundDuration - elapsed)
    }

    private func resumeTimer() {
        roundStartTime = Date.now.addingTimeInterval(-(roundDuration - session.remainingTime))
        startTimer(duration: session.remainingTime)
    }

    private func generatePuzzle() {
        let wordCandidate = allColors.randomElement() ?? allColors[0]
        session.currentWord = wordCandidate
        let otherColors = allColors.filter { $0.id != wordCandidate.id }
        session.currentInk = otherColors.randomElement() ?? allColors[1]
    }

    private func handleColorSelect(_ choice: StroopColor) {
        guard let currentInk = session.currentInk else { return }
        if choice.id == currentInk.id {
            SensoryFeedbackService.shared.minigameStepSuccess()
            if session.currentRound >= totalRounds {
                timerTask?.cancel()
                session.reset()
                onWin()
            } else {
                session.currentRound += 1
                generatePuzzle()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    session.displayedColors = allColors.shuffled()
                }
                roundStartTime = .now
                startTimer(duration: roundDuration)
            }
        } else {
            handleTimeout()
        }
    }

    private func handleTimeout() {
        SensoryFeedbackService.shared.minigameSubtleMistake()
        shakeTrigger += 1
        withAnimation(Design.Anim.smooth) {
            session.currentRound = 1
        }
        generatePuzzle()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            session.displayedColors = allColors.shuffled()
        }
        roundStartTime = .now
        startTimer(duration: roundDuration)
    }
}

// MARK: - 2. TILE MEMORY MINIGAME VIEW

struct FlipCardView<Front: View, Back: View>: View, Animatable {
    var angle: Double
    @ViewBuilder var front: () -> Front
    @ViewBuilder var back: () -> Back

    nonisolated var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    var body: some View {
        ZStack {
            let normalized = abs(angle).truncatingRemainder(dividingBy: 360)
            if normalized < 90 || normalized > 270 {
                front()
            } else {
                back()
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
        }
        .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
    }
}

struct TileMemoryGameView: View {
    var onWin: () -> Void

    init(onWin: @escaping () -> Void) {
        self.onWin = onWin
    }

    @Environment(\.scenePhase) private var scenePhase
    @State private var themeManager = ThemeManager.shared
    private var session = MinigameSessionManager.shared.memory

    private let rows = 5
    private let cols = 5
    private let totalTiles = 25
    private let targetCount = 7

    @State private var tileShakeTriggers: [Int] = Array(repeating: 0, count: 25)
    @State private var memorizeTask: Task<Void, Never>? = nil
    @State private var tenSecondTimeoutTask: Task<Void, Never>? = nil

    private var themeGradient: LinearGradient {
        let cw = themeManager.selectedColorway
        if cw.isMonochrome {
            return LinearGradient(
                colors: [Color.white, Color(red: 0.88, green: 0.90, blue: 0.94)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [cw.primaryLight, cw.primary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var themeGlowColor: Color {
        let cw = themeManager.selectedColorway
        if cw.isMonochrome {
            return Color.white.opacity(0.30)
        } else {
            return cw.primary.opacity(0.35)
        }
    }

    var body: some View {
        VStack(spacing: Design.Spacing.md) {
            // Header
            VStack(spacing: 6) {
                Text("Tile Memory".loc)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)

                Group {
                    if session.phase == .memorizing {
                        Text("%ds left to memorize".loc(session.countdownSeconds))
                    } else if session.phase == .flipping {
                        Text("0s left to memorize".loc)
                    } else {
                        Text("%d of %d revealed".loc(session.revealedIndices.count, targetCount))
                    }
                }
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Design.Colors.textSecondary)
            }
            .padding(.horizontal)

            // 5x5 Grid
            VStack(spacing: 8) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 8) {
                        ForEach(0..<cols, id: \.self) { col in
                            let index = row * cols + col
                            tileButton(for: index)
                        }
                    }
                }
            }
            .padding(16)
            .frame(width: 324, height: 324)
            .background(.ultraThinMaterial.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .onAppear {
            if !session.isGameActive {
                startNewGame()
            } else {
                if session.phase == .memorizing {
                    resumeCountdown()
                } else if session.phase == .flipping {
                    for idx in 0..<totalTiles {
                        session.tileAngles[idx] = 180
                    }
                    session.phase = .playing
                } else if session.phase == .playing && session.hasFirstTapped && session.revealedIndices.isEmpty {
                    startTenSecondTimeout()
                }
            }
        }
        .onDisappear {
            memorizeTask?.cancel()
            tenSecondTimeoutTask?.cancel()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase != .active {
                memorizeTask?.cancel()
                tenSecondTimeoutTask?.cancel()
            } else if newPhase == .active && session.isGameActive {
                if session.phase == .memorizing {
                    resumeCountdown()
                } else if session.phase == .flipping {
                    for idx in 0..<totalTiles {
                        session.tileAngles[idx] = 180
                    }
                    session.phase = .playing
                } else if session.phase == .playing && session.hasFirstTapped && session.revealedIndices.isEmpty {
                    startTenSecondTimeout()
                }
            }
        }
        .sensoryFeedback(.impact(weight: .medium, intensity: 1.0), trigger: session.revealedIndices.count)
        .sensoryFeedback(.warning, trigger: session.wrongTileIndex)
        .sensoryFeedback(.success, trigger: session.phase == .completed)
    }

    private func tileButton(for index: Int) -> some View {
        let isTarget = session.activeIndices.contains(index)
        let isWrong = (session.wrongTileIndex == index)

        return Button {
            handleTileTap(index)
        } label: {
            FlipCardView(angle: session.tileAngles[index]) {
                // Front Face (when angle < 90)
                ZStack {
                    if isTarget {
                        themeGradient
                    } else {
                        Color.white.opacity(0.08)
                    }
                }
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .strokeBorder(isTarget ? Color.white.opacity(0.25) : Color.white.opacity(0.08), lineWidth: 1.0)
                )
                .shadow(color: isTarget ? themeGlowColor : Color.clear, radius: 4)
            } back: {
                // Back Face (when angle >= 90)
                ZStack {
                    if isWrong {
                        Color(red: 0.95, green: 0.25, blue: 0.25).opacity(0.65)
                    } else {
                        Color.white.opacity(0.08)
                    }
                }
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .strokeBorder(isWrong ? Color.red.opacity(0.85) : Color.white.opacity(0.08), lineWidth: 1.0)
                )
                .shadow(color: isWrong ? Color.red.opacity(0.25) : Color.clear, radius: 4)
            }
            .keyframeAnimator(initialValue: CGFloat.zero, trigger: tileShakeTriggers[index]) { content, offset in
                content.offset(x: offset)
            } keyframes: { _ in
                KeyframeTrack {
                    CubicKeyframe(-6, duration: 0.05)
                    CubicKeyframe(6, duration: 0.06)
                    CubicKeyframe(-4, duration: 0.05)
                    CubicKeyframe(4, duration: 0.05)
                    CubicKeyframe(-2, duration: 0.04)
                    CubicKeyframe(2, duration: 0.04)
                    CubicKeyframe(0, duration: 0.04)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(session.phase != .playing || session.revealedIndices.contains(index))
    }

    private func startNewGame() {
        memorizeTask?.cancel()
        tenSecondTimeoutTask?.cancel()
        session.startNewGame(totalTiles: totalTiles, targetCount: targetCount)
        resumeCountdown()
    }

    private func resumeCountdown() {
        memorizeTask?.cancel()
        guard session.phase == .memorizing else { return }
        memorizeTask = Task {
            while session.countdownSeconds > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled, session.phase == .memorizing else { return }
                session.countdownSeconds -= 1
            }
            guard !Task.isCancelled, session.phase == .memorizing else { return }

            withAnimation(.easeInOut(duration: 0.2)) {
                session.phase = .flipping
            }

            // Staggered wave flip: left to right, row by row (etwas langsamer & geschmeidiger)
            for idx in 0..<totalTiles {
                guard !Task.isCancelled, session.phase == .flipping else { return }
                withAnimation(.easeInOut(duration: 0.52)) {
                    session.tileAngles[idx] = 180
                }
                try? await Task.sleep(for: .milliseconds(42))
            }

            try? await Task.sleep(for: .milliseconds(520))
            guard !Task.isCancelled, session.phase == .flipping else { return }

            withAnimation(Design.Anim.smooth) {
                session.phase = .playing
            }
        }
    }

    private func startTenSecondTimeout() {
        tenSecondTimeoutTask?.cancel()
        tenSecondTimeoutTask = Task {
            try? await Task.sleep(for: .seconds(10))
            guard !Task.isCancelled, session.phase == .playing else { return }

            // "wenn man 10 Sekunden nach dem ersten Klick nichts richtig hat, soll ein neues Muster zum Einprägen gezeigt werden."
            if session.revealedIndices.isEmpty {
                SensoryFeedbackService.shared.minigameSubtleMistake()
                startNewGame()
            }
        }
    }

    private func handleTileTap(_ index: Int) {
        guard session.phase == .playing else { return }
        guard !session.revealedIndices.contains(index) else { return }

        // Start 10-second timer on first click
        if !session.hasFirstTapped {
            session.hasFirstTapped = true
            startTenSecondTimeout()
        }

        if session.activeIndices.contains(index) {
            session.revealedIndices.insert(index)
            tenSecondTimeoutTask?.cancel()

            withAnimation(.spring(response: 0.55, dampingFraction: 0.76)) {
                session.tileAngles[index] = 0
            }

            if session.revealedIndices.count == targetCount {
                withAnimation(Design.Anim.smooth) {
                    session.phase = .completed
                }
                SensoryFeedbackService.shared.minigameGameWon()
                Task {
                    try? await Task.sleep(for: .milliseconds(600))
                    session.reset()
                    onWin()
                }
            } else {
                SensoryFeedbackService.shared.minigameStepSuccess()
            }
        } else {
            SensoryFeedbackService.shared.minigameSubtleMistake()
            session.wrongTileIndex = index
            tileShakeTriggers[index] += 1

            Task {
                try? await Task.sleep(for: .milliseconds(400))
                if session.wrongTileIndex == index {
                    withAnimation(.easeOut(duration: 0.2)) {
                        session.wrongTileIndex = nil
                    }
                }
            }
        }
    }
}

// MARK: - 3. CONNECT MINIGAME VIEW

struct ConnectGameView: View {
    var onWin: () -> Void

    init(onWin: @escaping () -> Void) {
        self.onWin = onWin
    }

    @Environment(\.scenePhase) private var scenePhase
    private var session = MinigameSessionManager.shared.connect

    private let size = 6
    private let totalTiles = 36
    private let spacing: CGFloat = 6
    private let cellSize: CGFloat = 44
    private let boardWidth: CGFloat = 294 // 6 * 44 + 5 * 6 = 294

    struct BoardPreset {
        struct PairPreset {
            let start: Int
            let end: Int
        }
        let pairs: [PairPreset]
    }

    typealias ActivePair = ConnectGameSession.ActivePair

    // Die 6 Farben wie bei Stroop
    private let stroopColors: [Color] = [
        Color(red: 255/255.0, green: 78/255.0, blue: 107/255.0), // Rot #FF4E6B
        Color(red: 254/255.0, green: 198/255.0, blue: 0/255.0),   // Gelb #FEC600
        Color(red: 1/255.0, green: 199/255.0, blue: 165/255.0),  // Grün #01C7A5
        Color(red: 171/255.0, green: 145/255.0, blue: 254/255.0),// Lila #AB91FE
        Color(red: 254/255.0, green: 118/255.0, blue: 89/255.0), // Orange #FE7659
        Color(red: 161/255.0, green: 197/255.0, blue: 254/255.0) // Blau #A1C5FE
    ]

    private let letterPool = ["A", "B", "C", "D", "E"]

    // 12 vielfältige, mathematisch verifizierte 6x6 Layouts mit je 5 Buchstaben-Paaren (A, B, C, D, E wie bei Opal)
    private let boardPresets: [BoardPreset] = [
        // Preset 1
        BoardPreset(pairs: [
            .init(start: 1, end: 30),
            .init(start: 4, end: 33),
            .init(start: 8, end: 25),
            .init(start: 10, end: 27),
            .init(start: 2, end: 21)
        ]),
        // Preset 2
        BoardPreset(pairs: [
            .init(start: 2, end: 24),
            .init(start: 3, end: 29),
            .init(start: 7, end: 32),
            .init(start: 10, end: 34),
            .init(start: 13, end: 20)
        ]),
        // Preset 3
        BoardPreset(pairs: [
            .init(start: 0, end: 26),
            .init(start: 6, end: 31),
            .init(start: 5, end: 32),
            .init(start: 11, end: 35),
            .init(start: 17, end: 29)
        ]),
        // Preset 4
        BoardPreset(pairs: [
            .init(start: 0, end: 18),
            .init(start: 5, end: 29),
            .init(start: 13, end: 33),
            .init(start: 15, end: 22),
            .init(start: 2, end: 26)
        ]),
        // Preset 5
        BoardPreset(pairs: [
            .init(start: 0, end: 32),
            .init(start: 3, end: 35),
            .init(start: 8, end: 26),
            .init(start: 11, end: 29),
            .init(start: 14, end: 21)
        ]),
        // Preset 6
        BoardPreset(pairs: [
            .init(start: 4, end: 0),
            .init(start: 19, end: 25),
            .init(start: 5, end: 8),
            .init(start: 32, end: 26),
            .init(start: 13, end: 23)
        ]),
        // Preset 7
        BoardPreset(pairs: [
            .init(start: 3, end: 12),
            .init(start: 33, end: 28),
            .init(start: 30, end: 19),
            .init(start: 26, end: 32),
            .init(start: 13, end: 27)
        ]),
        // Preset 8
        BoardPreset(pairs: [
            .init(start: 20, end: 34),
            .init(start: 13, end: 6),
            .init(start: 25, end: 12),
            .init(start: 24, end: 32),
            .init(start: 29, end: 35)
        ]),
        // Preset 9
        BoardPreset(pairs: [
            .init(start: 12, end: 0),
            .init(start: 1, end: 28),
            .init(start: 29, end: 4),
            .init(start: 20, end: 8),
            .init(start: 34, end: 35)
        ]),
        // Preset 10
        BoardPreset(pairs: [
            .init(start: 33, end: 26),
            .init(start: 19, end: 6),
            .init(start: 7, end: 13),
            .init(start: 20, end: 4),
            .init(start: 9, end: 10)
        ]),
        // Preset 11
        BoardPreset(pairs: [
            .init(start: 13, end: 9),
            .init(start: 2, end: 18),
            .init(start: 17, end: 16),
            .init(start: 25, end: 24),
            .init(start: 3, end: 11)
        ]),
        // Preset 12
        BoardPreset(pairs: [
            .init(start: 11, end: 14),
            .init(start: 33, end: 18),
            .init(start: 19, end: 22),
            .init(start: 7, end: 4),
            .init(start: 13, end: 0)
        ])
    ]

    // In-progress swipe
    @State private var currentDragPath: [Int] = []
    @State private var currentDragLetter: String? = nil
    @State private var hasCompletedCurrentDrag = false
    @State private var dragStepCount: Int = 0

    // Shake
    @State private var wrongCells: Set<Int> = []
    @State private var cellShakeTriggers: [Int] = Array(repeating: 0, count: 36)

    var body: some View {
        VStack(spacing: Design.Spacing.md) {
            // Header
            VStack(spacing: 6) {
                Text("Connect".loc)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)

                Text("%d of %d pairs linked".loc(session.connectedPaths.count, session.activePairs.count))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Design.Colors.textSecondary)
            }
            .padding(.horizontal)

            // 6x6 Connect Board Card
            ZStack(alignment: .topLeading) {
                // 1. Grid of dark tile backgrounds
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(cellSize), spacing: spacing), count: size),
                    spacing: spacing
                ) {
                    ForEach(0..<totalTiles, id: \.self) { index in
                        tileBackgroundView(for: index)
                    }
                }
                .frame(width: boardWidth, height: boardWidth)

                // 2. Connected paths layer
                ForEach(Array(session.connectedPaths.keys), id: \.self) { letter in
                    if let path = session.connectedPaths[letter],
                       let pair = session.activePairs.first(where: { $0.label == letter }),
                       path.count > 1 {
                        pipePath(for: path)
                            .stroke(
                                pair.color,
                                style: StrokeStyle(lineWidth: cellSize * 0.36, lineCap: .round, lineJoin: .round)
                            )
                    }
                }

                // 3. Active drag path layer
                if let letter = currentDragLetter,
                   let pair = session.activePairs.first(where: { $0.label == letter }) {
                    if currentDragPath.count > 1 {
                        pipePath(for: currentDragPath)
                            .stroke(
                                pair.color,
                                style: StrokeStyle(lineWidth: cellSize * 0.36, lineCap: .round, lineJoin: .round)
                            )
                    }
                    if currentDragPath.count > 1, let lastIdx = currentDragPath.last {
                        Circle()
                            .fill(pair.color)
                            .frame(width: cellSize * 0.44, height: cellSize * 0.44)
                            .shadow(color: pair.color.opacity(0.45), radius: 6)
                            .position(center(for: lastIdx))
                    }
                }

                // 4. Endpoint letter discs
                ForEach(Array(session.endpointMap.keys), id: \.self) { index in
                    if let pair = session.endpointMap[index] {
                        endpointView(
                            pair: pair,
                            index: index
                        )
                    }
                }
            }
            .frame(width: boardWidth, height: boardWidth)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        handleDragChanged(location: value.location)
                    }
                    .onEnded { _ in
                        handleDragEnded()
                    }
            )
            .padding(15)
            .frame(width: 324, height: 324)
            .background(.ultraThinMaterial.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .sensoryFeedback(.impact(weight: .medium, intensity: 1.0), trigger: currentDragLetter)
        .sensoryFeedback(.success, trigger: session.connectedPaths.count)
        .sensoryFeedback(trigger: dragStepCount) { _, _ in
            SensoryFeedbackService.shared.isHapticsEnabled ? .impact(weight: .light, intensity: 0.8) : nil
        }
        .onAppear {
            if !session.isGameActive {
                setupBoard()
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase != .active {
                if currentDragLetter != nil && !hasCompletedCurrentDrag {
                    currentDragPath = []
                    currentDragLetter = nil
                }
                hasCompletedCurrentDrag = false
            }
        }
    }

    private func transformGridIndex(_ index: Int, mode: Int) -> Int {
        let r = index / size
        let c = index % size
        let (nr, nc): (Int, Int) = {
            switch mode {
            case 1:  return (c, (size - 1) - r)                   // 90° Drehung
            case 2:  return ((size - 1) - r, (size - 1) - c)     // 180° Drehung
            case 3:  return ((size - 1) - c, r)                   // 270° Drehung
            case 4:  return (r, (size - 1) - c)                   // Horizontal spiegeln
            case 5:  return ((size - 1) - r, c)                   // Vertikal spiegeln
            case 6:  return (c, r)                                // Diagonale (Transponieren)
            case 7:  return ((size - 1) - c, (size - 1) - r)     // Anti-Diagonale
            default: return (r, c)                                // Normal
            }
        }()
        return nr * size + nc
    }

    private func setupBoard() {
        let preset = boardPresets.randomElement() ?? boardPresets[0]
        let symmetryMode = Int.random(in: 0..<8)
        let shuffledColors = stroopColors.shuffled()
        let shuffledLetters = letterPool.shuffled()
        let shuffledPairs = preset.pairs.shuffled()

        var pairs: [ActivePair] = []
        var map: [Int: ActivePair] = [:]

        for (index, p) in shuffledPairs.enumerated() {
            let label = shuffledLetters[index % shuffledLetters.count]
            let color = shuffledColors[index % shuffledColors.count]

            // Koordinaten-Transformation (Drehung & Spiegelung)
            let tStart = transformGridIndex(p.start, mode: symmetryMode)
            let tEnd = transformGridIndex(p.end, mode: symmetryMode)

            // Start & Endpunkt zufällig vertauschen
            let (finalStart, finalEnd) = Bool.random() ? (tStart, tEnd) : (tEnd, tStart)

            let pair = ActivePair(label: label, color: color, start: finalStart, end: finalEnd)
            pairs.append(pair)
            map[finalStart] = pair
            map[finalEnd] = pair
        }

        session.activePairs = pairs
        session.endpointMap = map
        session.connectedPaths = [:]
        session.isGameActive = true
        currentDragPath = []
        currentDragLetter = nil
        hasCompletedCurrentDrag = false
        wrongCells = []
    }

    private func center(for index: Int) -> CGPoint {
        let col = index % size
        let row = index / size
        let x = CGFloat(col) * (cellSize + spacing) + cellSize / 2
        let y = CGFloat(row) * (cellSize + spacing) + cellSize / 2
        return CGPoint(x: x, y: y)
    }

    private func pipePath(for indices: [Int]) -> Path {
        var path = Path()
        guard let first = indices.first else { return path }
        path.move(to: center(for: first))
        for idx in indices.dropFirst() {
            path.addLine(to: center(for: idx))
        }
        return path
    }

    private func tileBackgroundView(for index: Int) -> some View {
        let isWrong = wrongCells.contains(index)
        let fillColor = isWrong ? Color.red.opacity(0.35) : Color.white.opacity(0.08)
        let strokeColor = isWrong ? Color.red.opacity(0.65) : Color.white.opacity(0.06)

        return RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(fillColor)
            .frame(width: cellSize, height: cellSize)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(strokeColor, lineWidth: 1.0)
            )
            .keyframeAnimator(initialValue: CGFloat.zero, trigger: cellShakeTriggers[index]) { content, offset in
                content.offset(x: offset)
            } keyframes: { _ in
                KeyframeTrack {
                    CubicKeyframe(-5, duration: 0.05)
                    CubicKeyframe(5, duration: 0.06)
                    CubicKeyframe(-3, duration: 0.05)
                    CubicKeyframe(3, duration: 0.05)
                    CubicKeyframe(-1, duration: 0.04)
                    CubicKeyframe(1, duration: 0.04)
                    CubicKeyframe(0, duration: 0.04)
                }
            }
    }

    private func endpointView(
        pair: ActivePair,
        index: Int
    ) -> some View {
        let isDraggingThis = (currentDragLetter == pair.label)
        let pt = center(for: index)

        return ZStack {
            // Runder Farbfleck exakt wie bei Opal
            Circle()
                .fill(pair.color)
                .frame(width: cellSize * 0.72, height: cellSize * 0.72)

            // Buchstabe mittig und gut lesbar
            Text(pair.label)
                .font(.system(size: cellSize * 0.40, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
        }
        .scaleEffect(isDraggingThis ? 1.08 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isDraggingThis)
        .position(pt)
        .keyframeAnimator(initialValue: CGFloat.zero, trigger: cellShakeTriggers[index]) { content, offset in
            content.offset(x: offset)
        } keyframes: { _ in
            KeyframeTrack {
                CubicKeyframe(-5, duration: 0.05)
                CubicKeyframe(5, duration: 0.06)
                CubicKeyframe(-3, duration: 0.05)
                CubicKeyframe(3, duration: 0.05)
                CubicKeyframe(-1, duration: 0.04)
                CubicKeyframe(1, duration: 0.04)
                CubicKeyframe(0, duration: 0.04)
            }
        }
    }

    private func handleDragChanged(location: CGPoint) {
        if hasCompletedCurrentDrag { return }

        guard location.x >= 0, location.x < boardWidth, location.y >= 0, location.y < boardWidth else { return }

        let step = cellSize + spacing
        let col = Int(round((location.x - cellSize / 2) / step))
        let row = Int(round((location.y - cellSize / 2) / step))
        guard col >= 0, col < size, row >= 0, row < size else { return }
        let cellIndex = row * size + col

        if currentDragLetter == nil {
            // Touch auf einen Buchstaben-Endpunkt
            if let pair = session.endpointMap[cellIndex] {
                session.connectedPaths.removeValue(forKey: pair.label)
                currentDragLetter = pair.label
                currentDragPath = [cellIndex]
                SensoryFeedbackService.shared.minigameTap()
            }
        } else if let letter = currentDragLetter, let pair = session.activePairs.first(where: { $0.label == letter }) {
            guard let lastIndex = currentDragPath.last else { return }
            if cellIndex == lastIndex { return }

            // Schnelle Gesten: Zwischenschritte Manhattan-interpolieren, damit keine Touch-Frames verschluckt werden
            let steps = interpolateSteps(from: lastIndex, to: cellIndex)
            for stepCell in steps {
                if !processStep(stepCell, for: letter, pair: pair) {
                    break
                }
            }
        }
    }

    private func interpolateSteps(from fromIdx: Int, to toIdx: Int) -> [Int] {
        var result: [Int] = []
        var curR = fromIdx / size
        var curC = fromIdx % size
        let targetR = toIdx / size
        let targetC = toIdx % size

        while curC != targetC {
            curC += (targetC > curC ? 1 : -1)
            result.append(curR * size + curC)
        }
        while curR != targetR {
            curR += (targetR > curR ? 1 : -1)
            result.append(curR * size + curC)
        }
        return result
    }

    @discardableResult
    private func processStep(_ cellIndex: Int, for letter: String, pair: ActivePair) -> Bool {
        guard let lastIndex = currentDragPath.last else { return false }
        if cellIndex == lastIndex { return true }

        let r1 = lastIndex / size, c1 = lastIndex % size
        let row = cellIndex / size, col = cellIndex % size
        let isAdjacent = (abs(r1 - row) + abs(c1 - col) == 1)
        guard isAdjacent else { return false }

        // Rückwärts wischen (Backtracking): Schritt zurücknehmen
        if currentDragPath.count > 1 && cellIndex == currentDragPath[currentDragPath.count - 2] {
            currentDragPath.removeLast()
            dragStepCount &+= 1
            SensoryFeedbackService.shared.connectGridStep()
            return true
        }

        // Wenn man auf eigene Kachel im Pfad trifft: bis dahin stutzen
        if let existingPos = currentDragPath.firstIndex(of: cellIndex) {
            currentDragPath = Array(currentDragPath.prefix(upTo: existingPos + 1))
            dragStepCount &+= 1
            SensoryFeedbackService.shared.connectGridStep()
            return true
        }

        // Nicht über andere Buchstaben wischen
        if let otherPair = session.endpointMap[cellIndex], otherPair.label != letter {
            triggerWrongFeedback()
            return false
        }

        // Nicht über andere fertige Wege wischen
        for (otherLetter, path) in session.connectedPaths where otherLetter != letter {
            if path.contains(cellIndex) {
                return false
            }
        }

        // Kachel überquert: zum Pfad hinzufügen
        currentDragPath.append(cellIndex)

        // Ziel-Endpunkt erreicht?
        let isStart = (cellIndex == pair.start && currentDragPath.first == pair.end)
        let isEnd = (cellIndex == pair.end && currentDragPath.first == pair.start)
        if (isStart || isEnd) && currentDragPath.count > 1 {
            completeConnection(for: letter, path: currentDragPath)
            return false
        } else {
            dragStepCount &+= 1
            SensoryFeedbackService.shared.connectGridStep()
        }

        return true
    }

    private func completeConnection(for letter: String, path: [Int]) {
        // Pfad dauerhaft speichern & Geste bis zum Loslassen schützen
        session.connectedPaths[letter] = path
        hasCompletedCurrentDrag = true
        currentDragLetter = nil
        currentDragPath = []

        // Alle Paare verbunden?
        if session.connectedPaths.count == session.activePairs.count && !session.activePairs.isEmpty {
            SensoryFeedbackService.shared.minigameGameWon()
            Task {
                try? await Task.sleep(for: .milliseconds(450))
                session.reset()
                onWin()
            }
        } else {
            SensoryFeedbackService.shared.minigameStepSuccess()
        }
    }

    private func handleDragEnded() {
        defer {
            hasCompletedCurrentDrag = false
        }

        if hasCompletedCurrentDrag {
            return
        }

        if let letter = currentDragLetter, let pair = session.activePairs.first(where: { $0.label == letter }) {
            // Falls beim Loslassen genau auf dem Ziel-Endpunkt geendet wurde
            if let last = currentDragPath.last,
               (last == pair.start || last == pair.end),
               currentDragPath.first != last,
               currentDragPath.count > 1 {
                completeConnection(for: letter, path: currentDragPath)
            } else {
                // Losgelassen ohne fertige Verbindung:
                if currentDragPath.count > 1 {
                    triggerWrongFeedback()
                } else {
                    currentDragLetter = nil
                    currentDragPath = []
                }
            }
        }
    }

    private func triggerWrongFeedback() {
        SensoryFeedbackService.shared.minigameSubtleMistake()
        let cellsToShake = currentDragPath
        wrongCells = Set(cellsToShake)
        for idx in cellsToShake {
            cellShakeTriggers[idx] += 1
        }
        currentDragLetter = nil
        currentDragPath = []

        Task {
            try? await Task.sleep(for: .milliseconds(350))
            wrongCells.removeAll()
        }
    }
}

// MARK: - 4. MULTIPLICATION MINIGAME VIEW (OPAL-STYLE MATH IMPULSE BREAKER)

struct MultiplicationGameView: View {
    var onWin: () -> Void

    init(onWin: @escaping () -> Void) {
        self.onWin = onWin
    }

    private var session = MinigameSessionManager.shared.multiplication
    @State private var validateTask: Task<Void, Never>? = nil
    @State private var shakeOffset: CGFloat = 0
    @State private var isShakingWrong: Bool = false
    @State private var digitTapTrigger: Int = 0

    var body: some View {
        VStack(spacing: Design.Spacing.md) {
            // Header
            VStack(spacing: 6) {
                Text("Mental Math".loc)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)

                Text("%d of %d solved".loc(session.currentQuestionIndex, session.questions.count))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Design.Colors.textSecondary)
            }
            .padding(.horizontal)

            // Main Card Container
            VStack(spacing: 12) {
                // 3 Math Questions
                questionsGrid
                    .padding(.horizontal, 4)

                // Thin subtle divider
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 2)

                // Numeric Keypad (3x4 Grid)
                keypadGrid
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .frame(width: 324)
            .background(.ultraThinMaterial.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(
                        Color.white.opacity(0.12),
                        lineWidth: 1
                    )
            )
        }
        .sensoryFeedback(.impact(weight: .medium, intensity: 1.0), trigger: digitTapTrigger)
        .sensoryFeedback(.success, trigger: session.currentQuestionIndex)
        .sensoryFeedback(.warning, trigger: isShakingWrong)
        .onAppear {
            if !session.isGameActive || session.questions.count < 3 {
                startNewGame()
            }
        }
        .onDisappear {
            validateTask?.cancel()
        }
    }

    // MARK: - Questions Grid
    private var questionsGrid: some View {
        Grid(alignment: .center, horizontalSpacing: 10, verticalSpacing: 10) {
            ForEach(0..<session.questions.count, id: \.self) { index in
                let q = session.questions[index]
                let isActive = (index == session.currentQuestionIndex)
                let isDone = (index < session.currentQuestionIndex)
                let isWrongCurrent = (isActive && isShakingWrong)
                let answerText = session.userInputs[index]

                GridRow {
                    // 1. Math Equation (fixed width 96, right-aligned against '=')
                    HStack(spacing: 6) {
                        Text("\(q.a)")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(Color.white)

                        Text("×")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(Design.Colors.textSecondary)

                        Text("\(q.b)")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(Color.white)
                    }
                    .frame(width: 96, alignment: .trailing)
                    .gridColumnAlignment(.trailing)

                    // 2. Equals sign '=' (perfectly centered & vertically aligned)
                    Text("=")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.90))
                        .gridColumnAlignment(.center)
                        .frame(width: 20)

                    // 3. Solution Input Box (uniform size, vertically aligned column)
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(isWrongCurrent ? Color.red.opacity(0.25) : Color.white.opacity(0.08))

                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(
                                isWrongCurrent ? Color.red.opacity(0.90) :
                                (isActive ? Color(red: 0.70, green: 0.70, blue: 0.95) :
                                (isDone ? Color(red: 0.20, green: 0.90, blue: 0.55).opacity(0.85) :
                                Color.white.opacity(0.12))),
                                lineWidth: (isActive || isWrongCurrent) ? 2.5 : 1
                            )

                        Text(answerText)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(isDone ? Color(red: 0.20, green: 0.90, blue: 0.55) : (isWrongCurrent ? Color.red : Color.white))
                            .contentTransition(.numericText())
                            .animation(Design.Anim.normal, value: answerText)
                    }
                    .frame(width: 88, height: 44)
                    .offset(x: isWrongCurrent ? shakeOffset : 0)
                    .gridColumnAlignment(.leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Keypad Grid
    private var keypadGrid: some View {
        VStack(spacing: 10) {
            // Row 1: 1, 2, 3
            HStack(spacing: 0) {
                keypadButton("1")
                keypadButton("2")
                keypadButton("3")
            }

            // Row 2: 4, 5, 6
            HStack(spacing: 0) {
                keypadButton("4")
                keypadButton("5")
                keypadButton("6")
            }

            // Row 3: 7, 8, 9
            HStack(spacing: 0) {
                keypadButton("7")
                keypadButton("8")
                keypadButton("9")
            }

            // Row 4: empty, 0, backspace
            HStack(spacing: 0) {
                Color.clear
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)

                keypadButton("0")

                backspaceButton
            }
        }
        .padding(.horizontal, 8)
    }

    private func keypadButton(_ digit: String) -> some View {
        Button {
            handleDigit(digit)
        } label: {
            Text(digit)
                .font(.system(size: 26, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var backspaceButton: some View {
        Button {
            handleBackspace()
        } label: {
            Image(systemName: "delete.left")
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Game Logic & Input Handling

    private func handleDigit(_ digit: String) {
        guard session.currentQuestionIndex < session.questions.count else { return }
        guard !isShakingWrong else { return }

        digitTapTrigger += 1
        SensoryFeedbackService.shared.minigameTap()

        // Append digit (up to 4 digits max)
        var currentInput = session.userInputs[session.currentQuestionIndex]
        if currentInput.count < 4 {
            currentInput.append(digit)
            withAnimation(Design.Anim.normal) {
                session.userInputs[session.currentQuestionIndex] = currentInput
            }
        }

        // Debounce validation by ~1.5 seconds as requested
        restartValidationTimer()
    }

    private func handleBackspace() {
        guard session.currentQuestionIndex < session.questions.count else { return }
        guard !isShakingWrong else { return }

        digitTapTrigger += 1
        SensoryFeedbackService.shared.minigameTap()

        var currentInput = session.userInputs[session.currentQuestionIndex]
        if !currentInput.isEmpty {
            currentInput.removeLast()
            withAnimation(Design.Anim.normal) {
                session.userInputs[session.currentQuestionIndex] = currentInput
            }
        }

        if currentInput.isEmpty {
            validateTask?.cancel()
            validateTask = nil
        } else {
            restartValidationTimer()
        }
    }

    private func restartValidationTimer() {
        validateTask?.cancel()
        validateTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            guard !Task.isCancelled else { return }
            validateCurrentAnswer()
        }
    }

    private func validateCurrentAnswer() {
        guard session.currentQuestionIndex < session.questions.count else { return }
        let currentIdx = session.currentQuestionIndex
        let question = session.questions[currentIdx]
        let currentInput = session.userInputs[currentIdx]

        guard let answerInt = Int(currentInput) else { return }

        if answerInt == question.answer {
            // Correct answer!
            if currentIdx + 1 < session.questions.count {
                // Advance to next question
                SensoryFeedbackService.shared.minigameStepSuccess()
                withAnimation(Design.Anim.smooth) {
                    session.currentQuestionIndex += 1
                }
            } else {
                // All 3 questions answered correctly!
                SensoryFeedbackService.shared.minigameGameWon()
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    session.reset()
                    onWin()
                }
            }
        } else {
            // Incorrect answer: shake and reset all 3 questions!
            SensoryFeedbackService.shared.minigameSubtleMistake()
            isShakingWrong = true

            withAnimation(.linear(duration: 0.07).repeatCount(6, autoreverses: true)) {
                shakeOffset = 14
            }

            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 450_000_000)
                shakeOffset = 0
                isShakingWrong = false

                // Reset all 3 questions with fresh ones
                withAnimation(Design.Anim.spring) {
                    startNewGame()
                }
            }
        }
    }

    private func startNewGame() {
        validateTask?.cancel()
        validateTask = nil
        session.questions = generate3Questions()
        session.currentQuestionIndex = 0
        session.userInputs = ["", "", ""]
        session.isGameActive = true
    }

    /// Generates 3 non-trivial multiplication questions with factors between 1 and 20.
    /// Excludes trivial 1xX, small products < 25, ensuring at least one factor 11..19 or both 6..19.
    private func generate3Questions() -> [MultiplicationGameSession.Question] {
        var result: [MultiplicationGameSession.Question] = []
        var seen = Set<String>()

        while result.count < 3 {
            let a: Int
            let b: Int

            if Bool.random() {
                // One factor 11..19, other factor 4..16 (e.g. 14x6, 12x15, 13x11)
                a = Int.random(in: 11...19)
                b = Int.random(in: 4...16)
            } else {
                // Both factors in 6..19 (e.g. 8x9, 7x14, 9x13)
                a = Int.random(in: 6...14)
                b = Int.random(in: 7...19)
            }

            let key = "\(min(a, b))x\(max(a, b))"
            guard !seen.contains(key) else { continue }
            guard a != 1 && b != 1 else { continue }
            guard a * b >= 28 else { continue }

            seen.insert(key)
            result.append(MultiplicationGameSession.Question(a: a, b: b))
        }

        return result
    }
}

#Preview {
    SOSView()
        .modelContainer(for: EmergencyContact.self, inMemory: true)
}
