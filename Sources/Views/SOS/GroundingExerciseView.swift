import SwiftUI

/// 5-4-3-2-1 Sensory Grounding exercise matching the original clean visual layout
/// (large number, centered sense title & icon, pure background) combined with
/// dynamic '+' button, live item listing beneath the field, keyboard avoidance,
/// and tap-to-dismiss.
struct GroundingExerciseView: View {
    @Bindable var viewModel: SOSViewModel
    
    @FocusState private var isFocused: Bool
    @State private var entryText: String = ""

    init(viewModel: SOSViewModel = SOSViewModel()) {
        self.viewModel = viewModel
    }

    var currentInstruction: (number: Int, sense: String, icon: String) {
        switch viewModel.groundingStep {
        case 1: return (5, "Things you can see".loc, "eye.fill")
        case 2: return (4, "Things you can feel".loc, "hand.raised.fill")
        case 3: return (3, "Things you can hear".loc, "ear")
        case 4: return (2, "Things you can smell".loc, "nose.fill")
        default: return (1, "Thing you can taste".loc, "mouth.fill")
        }
    }

    private var targetCount: Int {
        viewModel.targetCount(for: viewModel.groundingStep)
    }

    private var currentItems: [String] {
        viewModel.items(for: viewModel.groundingStep)
    }

    private var placeholderText: String {
        if currentItems.count < targetCount {
            return "Item %d of %d...".loc(currentItems.count + 1, targetCount)
        } else {
            return "Step completed".loc
        }
    }

    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()
                .contentShape(Rectangle())
                .onTapGesture {
                    isFocused = false
                }

            if viewModel.groundingStep > 5 {
                completionView
            } else {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: Design.Spacing.md) {
                            // Large number transition
                            Text("\(currentInstruction.number)")
                                .font(.system(size: 84, weight: .bold, design: .rounded))
                                .foregroundStyle(Design.Colors.primary)
                                .contentTransition(.numericText())
                                .animation(Design.Anim.spring, value: viewModel.groundingStep)
                                .padding(.top, Design.Spacing.xs)

                            // Icon & Sense header
                            HStack(spacing: 8) {
                                Image(systemName: currentInstruction.icon)
                                    .font(.title2)
                                Text(currentInstruction.sense)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(Design.Colors.secondary)

                            // Input field with Dynamic Island '+' button
                            let hasText = !entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

                            HStack(spacing: 10) {
                                // 1. Input field
                                HStack {
                                    TextField(placeholderText, text: $entryText)
                                        .font(.body)
                                        .focused($isFocused)
                                        .submitLabel(.return)
                                        .onSubmit {
                                            submitCurrentItem()
                                        }
                                        .disabled(currentItems.count >= targetCount)
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color(red: 0.12, green: 0.13, blue: 0.17).opacity(0.70))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(isFocused ? Design.Colors.primary : Color.white.opacity(0.18), lineWidth: isFocused ? 1.5 : 1)
                                )

                                // 2. White Dynamic Island Plus-Button
                                if hasText {
                                    Button {
                                        SensoryFeedbackService.shared.selectionClick()
                                        submitCurrentItem()
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(Color.white)
                                                .shadow(color: Color.black.opacity(0.35), radius: 8, y: 3)

                                            Image(systemName: "plus")
                                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                                .foregroundStyle(Color.black)
                                        }
                                        .frame(width: 52, height: 52)
                                    }
                                    .buttonStyle(.plain)
                                    .transition(
                                        .asymmetric(
                                            insertion: .scale(scale: 0.1, anchor: .trailing)
                                                .combined(with: .opacity)
                                                .combined(with: .move(edge: .trailing)),
                                            removal: .scale(scale: 0.1, anchor: .trailing)
                                                .combined(with: .opacity)
                                                .combined(with: .move(edge: .trailing))
                                        )
                                    )
                                }
                            }
                            .animation(.spring(response: 0.35, dampingFraction: 0.68, blendDuration: 0.15), value: hasText)
                            .id("input_field")
                            .padding(.top, Design.Spacing.sm)
                            .padding(.horizontal)

                            // List of logged items below the field
                            if !currentItems.isEmpty {
                                VStack(spacing: 8) {
                                    ForEach(Array(currentItems.enumerated()), id: \.offset) { index, item in
                                        HStack(spacing: 12) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Design.Colors.primary)
                                                .font(.system(size: 18))

                                            Text(item)
                                                .font(.body)
                                                .foregroundStyle(Color.white)

                                            Spacer()

                                            Button(action: {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    viewModel.removeGroundingItem(at: index, for: viewModel.groundingStep)
                                                }
                                            }) {
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 13, weight: .bold))
                                                    .foregroundStyle(Design.Colors.textSecondary)
                                                    .frame(width: 36, height: 36)
                                                    .contentShape(Rectangle())
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .frame(height: 52)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(Color(red: 0.12, green: 0.13, blue: 0.17).opacity(0.65))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                        )
                                        .id("item_\(index)")
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 4)
                            }

                            // Tap empty space to dismiss keyboard
                            Color.clear
                                .frame(minHeight: 120)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    isFocused = false
                                }
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isFocused = false
                        }
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: currentItems.count) { oldCount, newCount in
                        if newCount > oldCount {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                proxy.scrollTo("item_\(newCount - 1)", anchor: .bottom)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("5-4-3-2-1 Grounding".loc)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    isFocused = false
                } label: {
                    Label("Done".loc, systemImage: "keyboard.chevron.compact.down")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Design.Colors.primary)
                }
            }
        }
        .onAppear {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(350))
                isFocused = true
            }
        }
        .onDisappear {
            viewModel.resetGrounding()
        }
        .dismissKeyboardOnTap()
    }

    // MARK: - Completion View (Original Layout)
    private var completionView: some View {
        VStack(spacing: Design.Spacing.md) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Design.Colors.primary)

            Text("Well Done!".loc)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.white)

            Text("You completed the grounding exercise. Notice how much more present and calm you feel right now.".loc)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Design.Colors.secondary)
                .padding(.horizontal)

            Spacer()

            Button(action: {
                withAnimation {
                    viewModel.resetGrounding()
                }
            }) {
                Text("Repeat Exercise".loc)
                    .font(.headline)
                    .foregroundStyle(Design.Colors.textOnPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Design.Colors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.horizontal)
            .padding(.bottom, Design.Spacing.xl)
        }
    }

    // MARK: - Submit Item
    private func submitCurrentItem() {
        let trimmed = entryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard currentItems.count < targetCount else { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            viewModel.addGroundingItem(trimmed, for: viewModel.groundingStep)
            entryText = ""
        }
        SensoryFeedbackService.shared.selectionClick()

        if viewModel.items(for: viewModel.groundingStep).count >= targetCount {
            isFocused = false
            SensoryFeedbackService.shared.successFeedback()
            Task {
                try? await Task.sleep(for: .milliseconds(700))
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.nextGroundingStep()
                    if viewModel.groundingStep <= 5 {
                        Task { @MainActor in
                            try? await Task.sleep(for: .milliseconds(200))
                            isFocused = true
                        }
                    } else {
                        isFocused = false
                    }
                }
            }
        } else {
            isFocused = true
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(60))
                isFocused = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        GroundingExerciseView(viewModel: SOSViewModel())
    }
}
