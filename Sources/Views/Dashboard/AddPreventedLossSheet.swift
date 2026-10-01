import SwiftUI
import SwiftData

/// Fast, frictionless sheet for recording an acute gambling deposit or impulse that was successfully resisted.
/// High-contrast typography and layout guaranteeing zero wrapping and WCAG AAA readability.
struct AddPreventedLossSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var defaultContextTag: String = "Manual"
    var onSaved: (() -> Void)? = nil

    @State private var amountText: String = ""
    @State private var selectedContextTag: String = ""
    @State private var noteText: String = ""
    @FocusState private var isAmountFocused: Bool

    private let presetAmounts: [Double] = [20, 50, 100, 250, 500]
    private let contextOptions: [(title: String, icon: String)] = [
        ("Overcame SOS Urge", "lifepreserver.fill"),
        ("Closed Casino Website", "xmark.shield.fill"),
        ("Defended Paycheck", "banknote.fill"),
        ("Stayed Strong on Weekend", "calendar.badge.checkmark"),
        ("Went for a Walk Instead", "figure.walk"),
        ("Distracted Elsewhere", "sparkles")
    ]

    var parsedAmount: Double {
        Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FlutedGlassBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        // Header
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(Design.Colors.primary.opacity(0.20))
                                    .frame(width: 44, height: 44)

                                Image(systemName: "shield.lefthalf.filled")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(Design.Colors.primary)
                            }

                            Text("Bet Successfully Prevented".loc)
                                .font(.system(size: 19, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white)
                                .multilineTextAlignment(.center)

                            Text("What amount were you about to bet or deposit before deciding not to?".loc)
                                .font(.caption)
                                .foregroundStyle(Color.white.opacity(0.75))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 4)

                        // Centered Amount Input Display & Quick Preset Chips
                        VStack(spacing: 12) {
                            HStack(alignment: .center, spacing: 6) {
                                ZStack(alignment: .center) {
                                    // Hidden native TextField that captures keyboard touches
                                    TextField("", text: $amountText)
                                        .keyboardType(.numberPad)
                                        .focused($isAmountFocused)
                                        .foregroundStyle(Color.clear)
                                        .tint(Design.Colors.primary)
                                        .multilineTextAlignment(.center)
                                        .fixedSize(horizontal: true, vertical: false)

                                    // Animated Numeric Display with Apple slot/odometer numericText transition
                                    Text(amountText.isEmpty ? "0" : amountText)
                                        .font(.system(size: 52, weight: .bold, design: .rounded))
                                        .foregroundStyle(amountText.isEmpty ? Color.white.opacity(0.35) : Color.white)
                                        .contentTransition(.numericText())
                                        .animation(.spring(response: 0.38, dampingFraction: 0.78), value: amountText)
                                        .allowsHitTesting(false)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    isAmountFocused = true
                                }

                                Text("$")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                    .foregroundStyle(Design.Colors.primary)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)

                            // Quick preset chips (strictly single-line, equal-width)
                            HStack(spacing: 6) {
                                ForEach(presetAmounts, id: \.self) { preset in
                                    Button {
                                        withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                                            amountText = String(format: "%.0f", preset)
                                        }
                                        SensoryFeedbackService.shared.selectionClick()
                                    } label: {
                                        Text("$\(Int(preset))")
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                            .lineLimit(1)
                                            .foregroundStyle(parsedAmount == preset ? Design.Colors.textOnPrimary : Color.white)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 36)
                                            .background(
                                                Capsule()
                                                    .fill(parsedAmount == preset ? Design.Colors.primary : Color.white.opacity(0.08))
                                            )
                                            .overlay(
                                                Capsule()
                                                    .strokeBorder(parsedAmount == preset ? Design.Colors.primary : Color.white.opacity(0.15), lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            // Fixed-height container (20pt) so layout never jumps or pushes content down
                            HStack(spacing: 6) {
                                if parsedAmount > 0 {
                                    let eq = SavingsEquivalentService.currentEquivalent(for: parsedAmount)
                                    Image(systemName: eq.icon)
                                        .font(.caption)
                                        .foregroundStyle(Design.Colors.gold)
                                    Text("Equals e.g. %@".loc(eq.shortTitle))
                                        .font(.caption)
                                        .foregroundStyle(Design.Colors.gold)
                                        .contentTransition(.numericText())
                                        .animation(.spring(response: 0.38, dampingFraction: 0.78), value: parsedAmount)
                                }
                            }
                            .frame(height: 20)
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: Design.Radius.card, style: .continuous))

                        // Context Tags in clean, organized 2-column grid
                        VStack(alignment: .leading, spacing: 8) {
                            Text("WHAT WAS THE TRIGGER / SITUATION?".loc)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .tracking(1.2)
                                .foregroundStyle(Color.white.opacity(0.70))

                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                                ForEach(contextOptions, id: \.title) { option in
                                    Button {
                                        if selectedContextTag == option.title {
                                            selectedContextTag = ""
                                        } else {
                                            selectedContextTag = option.title
                                            SensoryFeedbackService.shared.selectionClick()
                                        }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: option.icon)
                                                .font(.system(size: 13, weight: .semibold))
                                            Text(option.title.loc)
                                                .font(.system(size: 12, weight: .semibold))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.80)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 38)
                                        .padding(.horizontal, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(selectedContextTag == option.title ? Design.Colors.primary : Color.white.opacity(0.06))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .strokeBorder(selectedContextTag == option.title ? Design.Colors.primary : Color.white.opacity(0.12), lineWidth: 1)
                                        )
                                        .foregroundStyle(selectedContextTag == option.title ? Design.Colors.textOnPrimary : Color.white.opacity(0.90))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, Design.Spacing.xs)

                        // Optional Note (Spacious, easy-to-tap reflection field)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("PERSONAL NOTE (OPTIONAL)".loc)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .tracking(1.2)
                                .foregroundStyle(Color.white.opacity(0.70))

                            ZStack(alignment: .topLeading) {
                                if noteText.isEmpty {
                                    Text("e.g. Urge was intense, but held out for 15 minutes...".loc)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.white.opacity(0.35))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 12)
                                        .allowsHitTesting(false)
                                }

                                TextField("", text: $noteText, axis: .vertical)
                                    .lineLimit(3...6)
                                    .font(.subheadline)
                                    .padding(14)
                                    .frame(minHeight: 80, alignment: .topLeading)
                                    .foregroundStyle(Color.white)
                            }
                            .background(Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, Design.Spacing.xs)

                        // Save Button (High-Contrast: Dark text on radiant primary amber)
                        Button {
                            saveEntry()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.shield.fill")
                                    .font(.system(size: 16, weight: .bold))
                                Text(parsedAmount > 0 ? "Log %@ as Victory".loc("$\(Int(parsedAmount))") : "Enter Amount".loc)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .contentTransition(.numericText())
                                    .animation(.spring(response: 0.38, dampingFraction: 0.78), value: parsedAmount)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundStyle(parsedAmount > 0 ? Design.Colors.textOnPrimary : Color.white.opacity(0.40))
                            .background(
                                RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                                    .fill(parsedAmount > 0 ? Design.Colors.primary : Color.white.opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                                    .strokeBorder(parsedAmount > 0 ? Design.Colors.primary : Color.white.opacity(0.12), lineWidth: 1)
                            )
                        }
                        .disabled(parsedAmount <= 0)
                        .padding(.top, 4)
                        .padding(.bottom, 8)
                    }
                    .padding(Design.Spacing.md)
                }
            }
            .navigationTitle("Prevented Bet".loc)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel".loc) {
                        dismiss()
                    }
                    .foregroundStyle(Color.white.opacity(0.85))
                }
            }
            .onAppear {
                if !defaultContextTag.isEmpty {
                    selectedContextTag = defaultContextTag
                }
            }
            .scrollIndicators(.hidden)
        }
        .scrollIndicators(.hidden)
    }

    private func saveEntry() {
        guard parsedAmount > 0 else { return }
        let entry = PreventedLossEntry(
            amount: parsedAmount,
            note: noteText,
            contextTag: selectedContextTag.isEmpty ? defaultContextTag : selectedContextTag
        )
        modelContext.insert(entry)
        try? modelContext.save()
        SensoryFeedbackService.shared.successFeedback()
        onSaved?()
        dismiss()
    }
}

/// Helper flow layout for tag chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                x = 0
                height += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: height + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
