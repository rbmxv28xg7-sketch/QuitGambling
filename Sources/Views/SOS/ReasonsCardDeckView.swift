import SwiftUI
import SwiftData

struct ReasonsCardDeckView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ReasonToQuit.createdDate) private var reasons: [ReasonToQuit]
    @AppStorage("hasSeededInitialReasons") private var hasSeededInitialReasons: Bool = false

    @State private var displayedReasons: [ReasonToQuit] = []
    @State private var dragOffset: CGSize = .zero
    @State private var isDismissing: Bool = false
    @State private var showingAddSheet: Bool = false
    @State private var newReasonText: String = ""

    private let defaultReasons = [
        "For my financial freedom and genuine security for my future.",
        "Because I want to feel real joy and vitality in life's small moments again.",
        "To be fully present for my family and the people I love.",
        "No jackpot in the world is worth losing my inner peace and restful sleep.",
        "To walk through life with pride, dignity, and my head held high."
    ]

    private var dragProgress: CGFloat {
        min(abs(dragOffset.width) / 140.0, 1.0)
    }

    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()

            VStack(spacing: Design.Spacing.md) {
                // Subtitle
                if !displayedReasons.isEmpty {
                    Text("Swipe cards to remind yourself of your strongest motivations.".loc)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.white.opacity(0.82))
                        .padding(.horizontal, 24)
                        .padding(.top, Design.Spacing.xs)
                }

                Spacer()

                // Fanned Card Deck or Empty State
                if displayedReasons.isEmpty {
                    emptyStateView
                } else {
                    fannedDeckView
                }

                Spacer()
            }
        }
        .navigationTitle("My Reasons".loc)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Design.Colors.primary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
            }
        }
        .onAppear {
            if !hasSeededInitialReasons && reasons.isEmpty {
                hasSeededInitialReasons = true
                for text in defaultReasons {
                    modelContext.insert(ReasonToQuit(text: text))
                }
                try? modelContext.save()
            }
            syncDisplayedReasons(from: reasons)
        }
        .onChange(of: reasons) { _, newReasons in
            syncDisplayedReasons(from: newReasons)
        }
        .sheet(isPresented: $showingAddSheet) {
            addReasonSheet
                .scrollIndicators(.hidden)
        }
        .scrollIndicators(.hidden)
    }

    private func syncDisplayedReasons(from allReasons: [ReasonToQuit]) {
        if allReasons.isEmpty {
            displayedReasons = []
            return
        }
        // Retain current order where possible
        var updated = displayedReasons.filter { current in
            allReasons.contains(where: { $0.id == current.id })
        }
        // Append newly added reasons at front
        for reason in allReasons {
            if !updated.contains(where: { $0.id == reason.id }) {
                updated.insert(reason, at: 0)
            }
        }
        displayedReasons = updated
    }

    // MARK: - Fanned Playing Card Deck
    private var fannedDeckView: some View {
        let visibleCount = min(displayedReasons.count, 5)
        let visibleCards = Array(displayedReasons.prefix(visibleCount).enumerated())

        return ZStack {
            // Render from back (highest index) to front (index 0)
            ForEach(visibleCards.reversed(), id: \.element.id) { index, reason in
                ReasonPlayingCard(
                    reason: reason,
                    onDelete: {
                        deleteReason(reason)
                    }
                )
                .scaleEffect(cardScale(for: index, dragProgress: dragProgress))
                .rotationEffect(cardRotation(for: index, dragProgress: dragProgress), anchor: UnitPoint(x: 0.5, y: 1.15))
                .offset(cardOffset(for: index, dragProgress: dragProgress))
                .zIndex(Double(10 - index))
                .shadow(
                    color: Color.black.opacity(index == 0 ? 0.45 : 0.25),
                    radius: index == 0 ? 20 : 10,
                    x: 0,
                    y: index == 0 ? 10 : 5
                )
                .shadow(
                    color: Color(red: 0.85, green: 0.92, blue: 1.0).opacity(index == 0 ? 0.35 : 0.12),
                    radius: index == 0 ? 25 : 12,
                    x: 0,
                    y: 0
                )
                // Only the front card responds to dragging
                .gesture(
                    index == 0 ? dragGesture : nil
                )
                // Tapping a background card brings it to the front
                .onTapGesture {
                    if index > 0 && !isDismissing {
                        bringCardToFront(at: index)
                    }
                }
            }
        }
        .frame(width: 310, height: 430)
    }

    // MARK: - Fan Transforms with Real-Time Drag Interpolation
    private func cardRotation(for index: Int, dragProgress: CGFloat) -> Angle {
        if index == 0 {
            return .degrees(Double(dragOffset.width / 14.0))
        }
        let currentAngle: Double
        let targetAngle: Double
        switch index {
        case 1:
            currentAngle = 5.0; targetAngle = 0.0
        case 2:
            currentAngle = -5.0; targetAngle = 5.0
        case 3:
            currentAngle = 9.0; targetAngle = -5.0
        case 4:
            currentAngle = -9.0; targetAngle = 9.0
        default:
            currentAngle = 0.0; targetAngle = 0.0
        }
        let interpolated = currentAngle + (targetAngle - currentAngle) * Double(dragProgress)
        return .degrees(interpolated)
    }

    private func cardOffset(for index: Int, dragProgress: CGFloat) -> CGSize {
        if index == 0 {
            return dragOffset
        }
        let currentX: CGFloat
        let targetX: CGFloat
        let currentY: CGFloat
        let targetY: CGFloat

        switch index {
        case 1:
            currentX = 12; targetX = 0
            currentY = 6;  targetY = 0
        case 2:
            currentX = -12; targetX = 12
            currentY = 12;  targetY = 6
        case 3:
            currentX = 20; targetX = -12
            currentY = 18; targetY = 12
        case 4:
            currentX = -20; targetX = 20
            currentY = 24;  targetY = 18
        default:
            currentX = 0; targetX = 0
            currentY = 0; targetY = 0
        }

        let interpolatedX = currentX + (targetX - currentX) * dragProgress
        let interpolatedY = currentY + (targetY - currentY) * dragProgress
        return CGSize(width: interpolatedX, height: interpolatedY)
    }

    private func cardScale(for index: Int, dragProgress: CGFloat) -> CGFloat {
        if index == 0 {
            return 1.0
        }
        let currentScale: CGFloat
        let targetScale: CGFloat
        switch index {
        case 1:
            currentScale = 0.96; targetScale = 1.0
        case 2:
            currentScale = 0.92; targetScale = 0.96
        case 3:
            currentScale = 0.88; targetScale = 0.92
        case 4:
            currentScale = 0.84; targetScale = 0.88
        default:
            currentScale = 0.80; targetScale = 0.84
        }
        return currentScale + (targetScale - currentScale) * dragProgress
    }

    // MARK: - Drag Gesture
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                guard !isDismissing else { return }
                if displayedReasons.count <= 1 {
                    // With 1 reason: can move freely, with gentle rubber-band limit if pulled far
                    let rawX = value.translation.width
                    let limit: CGFloat = 160
                    let clampedX: CGFloat
                    if abs(rawX) > limit {
                        let excess = abs(rawX) - limit
                        clampedX = (rawX > 0 ? limit : -limit) + (rawX > 0 ? excess * 0.32 : -excess * 0.32)
                    } else {
                        clampedX = rawX
                    }
                    dragOffset = CGSize(width: clampedX, height: value.translation.height * 0.75)
                } else {
                    dragOffset = value.translation
                }
            }
            .onEnded { value in
                guard !isDismissing else { return }
                if displayedReasons.count <= 1 {
                    // With only 1 reason: ALWAYS bounce back to center, never swipe away!
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                        dragOffset = .zero
                    }
                    SensoryFeedbackService.shared.selectionClick()
                    return
                }

                let threshold: CGFloat = 85
                let velocity = value.predictedEndTranslation.width

                if value.translation.width > threshold || velocity > 260 {
                    swipeTopCard(toRight: true)
                } else if value.translation.width < -threshold || velocity < -260 {
                    swipeTopCard(toRight: false)
                } else {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.68)) {
                        dragOffset = .zero
                    }
                }
            }
    }

    private func swipeTopCard(toRight: Bool) {
        SensoryFeedbackService.shared.selectionClick()
        isDismissing = true

        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
            dragOffset = CGSize(width: toRight ? 620 : -620, height: dragOffset.height * 0.2)
        } completion: {
            guard displayedReasons.count > 1 else {
                dragOffset = .zero
                isDismissing = false
                return
            }

            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                let finishedCard = displayedReasons.removeFirst()
                displayedReasons.append(finishedCard)
                dragOffset = .zero
                isDismissing = false
            }
        }
    }

    private func bringCardToFront(at index: Int) {
        SensoryFeedbackService.shared.selectionClick()
        guard index < displayedReasons.count else { return }
        withAnimation(.spring(response: 0.36, dampingFraction: 0.70)) {
            let tapped = displayedReasons.remove(at: index)
            displayedReasons.insert(tapped, at: 0)
        }
    }

    private func deleteReason(_ reason: ReasonToQuit) {
        SensoryFeedbackService.shared.selectionClick()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.70)) {
            modelContext.delete(reason)
            try? modelContext.save()
            displayedReasons.removeAll { $0.id == reason.id }
        }
    }

    // MARK: - Empty State View (Crash-Proof)
    private var emptyStateView: some View {
        VStack(spacing: Design.Spacing.md) {
            Spacer()
            Image(systemName: "heart.text.square")
                .font(.system(size: 64))
                .foregroundStyle(Design.Colors.primary.opacity(0.85))

            Text("No Reasons Added Yet".loc)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.white)

            Text("Add personal motivations reminding you why living gambling-free matters to you.".loc)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Design.Colors.textSecondary)
                .padding(.horizontal, 36)

            Button {
                showingAddSheet = true
            } label: {
                Label("Add Reason".loc, systemImage: "plus")
                    .font(.headline)
                    .foregroundStyle(Design.Colors.textOnPrimary)
                    .frame(height: 52)
                    .padding(.horizontal, 28)
                    .background(Design.Colors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.top, Design.Spacing.sm)

            Spacer()
        }
    }

    // MARK: - Add Reason Sheet
    private var addReasonSheet: some View {
        NavigationStack {
            ZStack {
                FlutedGlassBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Design.Spacing.lg) {
                        Text("Add Reason".loc)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, Design.Spacing.xs)

                        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
                            Text("NEW REASON".loc)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Design.Colors.gold)
                                .padding(.leading, 8)

                            VStack(spacing: Design.Spacing.md) {
                                TextField("I want to quit because...".loc, text: $newReasonText, axis: .vertical)
                                    .lineLimit(4...8)
                                    .foregroundStyle(Design.Colors.textPrimary)
                            }
                            .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.md)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, Design.Spacing.md)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel".loc) {
                        showingAddSheet = false
                    }
                    .foregroundStyle(Design.Colors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save".loc) {
                        let trimmed = newReasonText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        let reason = ReasonToQuit(text: trimmed)
                        modelContext.insert(reason)
                        try? modelContext.save()
                        newReasonText = ""
                        showingAddSheet = false
                        displayedReasons.insert(reason, at: 0)
                    }
                    .bold()
                    .foregroundStyle(Design.Colors.gold)
                    .disabled(newReasonText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
        .dismissKeyboardOnTap()
    }
}

// MARK: - Playing Card View
struct ReasonPlayingCard: View {
    let reason: ReasonToQuit
    var onDelete: () -> Void

    @State private var showingDeleteAlert: Bool = false

    var body: some View {
        ZStack {
            // 1. Frosted Apple Liquid Glass Material (True Optical Blur & Translucency)
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)

            // 2. Milky Frosted Silver Glass Tint (Leicht milchig)
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.24),
                            Color(red: 0.88, green: 0.92, blue: 0.98).opacity(0.14),
                            Color.white.opacity(0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // 3. Subtle Silver Specular Sheen (Diagonal Light Reflection)
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color.white.opacity(0.28), location: 0.0),
                            .init(color: Color.clear, location: 0.35),
                            .init(color: Color.white.opacity(0.12), location: 0.65),
                            .init(color: Color.clear, location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // 4. Inner Milky Glass Soft Glow
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .inset(by: 1)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.45),
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.25)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )

            // 5. Polished Silver Glass Outer Bevel Rim
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        stops: [
                            .init(color: Color.white.opacity(0.85), location: 0.0),
                            .init(color: Color(red: 0.85, green: 0.90, blue: 0.98).opacity(0.50), location: 0.30),
                            .init(color: Color.white.opacity(0.20), location: 0.65),
                            .init(color: Color(red: 0.80, green: 0.85, blue: 0.95).opacity(0.60), location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )

            // 6. Specular Top Edge Light Refraction Shimmer
            VStack {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                Color.white.opacity(0.90),
                                Color.white,
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1.2)
                    .padding(.horizontal, 24)
                    .padding(.top, 1)

                Spacer()
            }

            VStack(spacing: 0) {
                // Top Bar with Direct Trash Delete Button & Confirmation Alert
                HStack {
                    Spacer()

                    Button {
                        showingDeleteAlert = true
                        SensoryFeedbackService.shared.selectionClick()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.80))
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.12))
                            )
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.white.opacity(0.22), lineWidth: 0.8)
                            )
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .alert("Delete this reason?".loc, isPresented: $showingDeleteAlert) {
                        Button("Cancel".loc, role: .cancel) {}
                        Button("Delete".loc, role: .destructive) {
                            onDelete()
                        }
                    } message: {
                        Text("Are you sure you want to remove this personal motivation?".loc)
                    }
                }
                .padding(.trailing, 10)
                .padding(.top, 10)

                Spacer()

                // Quotes and Reason Content
                VStack(spacing: 12) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    Color(red: 0.88, green: 0.92, blue: 0.98)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.black.opacity(0.35), radius: 2, y: 1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)

                    Text(reason.text)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.white)
                        .lineSpacing(5)
                        .padding(.horizontal, 20)
                        .minimumScaleFactor(0.80)
                        .shadow(color: Color.black.opacity(0.70), radius: 3, x: 0, y: 1.5)

                    Image(systemName: "quote.closing")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.88, green: 0.92, blue: 0.98),
                                    Color.white
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.black.opacity(0.35), radius: 2, y: 1)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 24)
                }

                Spacer()
            }
            .padding(.bottom, 24)
        }
        .frame(width: 296, height: 410)
    }
}

#Preview {
    NavigationStack {
        ReasonsCardDeckView()
            .modelContainer(for: ReasonToQuit.self, inMemory: true)
    }
}
