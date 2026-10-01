import SwiftUI
import SwiftData

struct NewEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var viewModel: JournalViewModel
    
    @State private var text: String = ""
    @State private var selectedMood: Int = 3
    @State private var gratitude: String = ""
    @State private var hadCravings: Bool = false
    @State private var showValidationError: Bool = false
    @FocusState private var isJournalFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                FlutedGlassBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Design.Spacing.lg) {
                        Text("New Entry")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, Design.Spacing.xs)

                        entrySection("Mood") {
                            MoodPickerView(selectedMood: $selectedMood)
                        }

                        entrySection("Journal", isInvalid: showValidationError) {
                            VStack(alignment: .leading, spacing: 10) {
                                TextField("What's on your mind?", text: $text, axis: .vertical)
                                    .focused($isJournalFocused)
                                    .lineLimit(5...)
                                    .frame(minHeight: 80)
                                    .foregroundStyle(Design.Colors.textPrimary)

                                if showValidationError {
                                    HStack(spacing: 6) {
                                        Image(systemName: "exclamationmark.circle.fill")
                                            .font(.caption)
                                        Text("Please write a short note about your thoughts before saving.")
                                            .font(.caption.weight(.medium))
                                    }
                                    .foregroundStyle(Design.Colors.sos)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                        }

                        entrySection("Gratitude") {
                            TextField("What are you grateful for today?", text: $gratitude, axis: .vertical)
                                .frame(minHeight: 44)
                                .foregroundStyle(Design.Colors.textPrimary)
                        }

                        entrySection(nil) {
                            Toggle("Did you feel gambling urges today?", isOn: $hadCravings)
                                .foregroundStyle(Design.Colors.textPrimary)
                                .tint(Design.Colors.toggleTint)
                                .frame(minHeight: 44)
                                .onChange(of: hadCravings) { _, _ in
                                    SensoryFeedbackService.shared.toggleChanged()
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, Design.Spacing.md)
                    .padding(.bottom, 40)
                }
            }
            .dismissKeyboardOnTap()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        SensoryFeedbackService.shared.selectionClick()
                        dismiss()
                    }
                    .foregroundStyle(Design.Colors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        handleSave()
                    }
                    .bold()
                    .foregroundStyle(Design.Colors.gold)
                }
            }
            .onChange(of: text) { _, newText in
                if showValidationError && !newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    withAnimation(Design.Anim.normal) {
                        showValidationError = false
                    }
                }
            }
        }
    }

    private func handleSave() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            SensoryFeedbackService.shared.errorFeedback()
            withAnimation(Design.Anim.spring) {
                showValidationError = true
                isJournalFocused = true
            }
        } else {
            SensoryFeedbackService.shared.successFeedback()
            viewModel.createEntry(
                context: modelContext,
                text: trimmed,
                mood: selectedMood,
                gratitude: gratitude.trimmingCharacters(in: .whitespacesAndNewlines),
                hadCravings: hadCravings
            )
            dismiss()
        }
    }

    private func entrySection<Content: View>(
        _ title: String?,
        isInvalid: Bool = false,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
            if let title {
                HStack(spacing: 6) {
                    Text(title.uppercased())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(isInvalid ? Design.Colors.sos : Design.Colors.gold)

                    if isInvalid {
                        Text("• Required field")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Design.Colors.sos)
                            .transition(.opacity)
                    }
                }
                .padding(.leading, 8)
                .lineLimit(1)
            }

            VStack(spacing: Design.Spacing.md) {
                content()
            }
            .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.md)
            .overlay(
                RoundedRectangle(cornerRadius: Design.Radius.card)
                    .strokeBorder(isInvalid ? Design.Colors.sos.opacity(0.85) : Color.clear, lineWidth: 1.5)
            )
        }
    }
}

#Preview {
    NewEntryView(viewModel: JournalViewModel())
}
