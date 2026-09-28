import SwiftUI

/// A versatile camouflage overlay that switches dynamically between a realistic Calculator and a Notes app.
struct CamouflageView: View {
    var onExit: () -> Void
    var privacyManager: PrivacyManager? = nil

    @Environment(PrivacyManager.self) private var envPrivacyManager: PrivacyManager?

    private var activePrivacy: PrivacyManager {
        privacyManager ?? envPrivacyManager ?? PrivacyManager()
    }

    @State private var notesText: String = "Q3 Project Planning\n- Prioritize tasks\n- Prepare budget overview\n- Gather team feedback"
    @State private var tasks: [(title: String, done: Bool)] = [
        ("Type up meeting notes", true),
        ("Follow up with team", false),
        ("Update documentation", false)
    ]

    var body: some View {
        Group {
            if activePrivacy.selectedCamouflageStyle == .calculator {
                CalculatorCamouflageView(
                    onExit: onExit,
                    targetPIN: activePrivacy.camouflagePIN,
                    onBiometricRecovery: {
                        await activePrivacy.performAuthentication()
                    }
                )
            } else {
                notesDisguiseView
            }
        }
    }

    // MARK: - Notes Disguise Mode

    private var notesDisguiseView: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Design.Spacing.md) {
                HStack {
                    Label("Simple Notes", systemImage: "note.text")
                        .font(.headline)
                        .foregroundStyle(Design.Colors.textSecondary)
                        .contentShape(Rectangle())
                        .onLongPressGesture(minimumDuration: 1.5) {
                            Task {
                                let success = await activePrivacy.performAuthentication()
                                if success { onExit() }
                            }
                        }

                    Spacer()

                    // Discreet exit button
                    Button {
                        onExit()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Design.Colors.textSecondary)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
                .padding(.horizontal)
                .padding(.top, Design.Spacing.sm)

                Divider()

                List {
                    Section("Quick Note") {
                        TextField("Enter note...", text: $notesText, axis: .vertical)
                            .lineLimit(3...6)
                            .onChange(of: notesText) { _, newText in
                                if newText.trimmingCharacters(in: .whitespacesAndNewlines) == activePrivacy.camouflagePIN {
                                    SensoryFeedbackService.shared.successFeedback()
                                    onExit()
                                }
                            }
                    }

                    Section("Tasks") {
                        ForEach(0..<tasks.count, id: \.self) { index in
                            HStack {
                                Image(systemName: tasks[index].done ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(tasks[index].done ? .gray : .secondary)
                                Text(tasks[index].title)
                                    .strikethrough(tasks[index].done)
                                    .foregroundStyle(tasks[index].done ? .secondary : .primary)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                tasks[index].done.toggle()
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollIndicators(.hidden)
            }
            .navigationBarHidden(true)
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
}

#Preview {
    CamouflageView(onExit: {})
        .environment(PrivacyManager())
}
