import SwiftUI

/// A discreet camouflage screen resembling a generic notes/checklist app for privacy in public situations.
struct CamouflageView: View {
    var onExit: () -> Void

    @State private var notesText: String = "Projektplanung Q3\n- Aufgaben priorisieren\n- Budgetüberblick vorbereiten\n- Feedback einholen"
    @State private var tasks: [(title: String, done: Bool)] = [
        ("Meeting-Notizen abtippen", true),
        ("Rücksprache mit Team", false),
        ("Dokumentation aktualisieren", false)
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Design.Spacing.md) {
                HStack {
                    Label("Einfache Notizen", systemImage: "note.text")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    // Discreet exit button
                    Button {
                        onExit()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
                .padding(.horizontal)
                .padding(.top, Design.Spacing.sm)

                Divider()

                List {
                    Section("Kurznotiz") {
                        TextField("Notiz eingeben...", text: $notesText, axis: .vertical)
                            .lineLimit(3...6)
                    }

                    Section("Aufgaben") {
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
            }
            .navigationBarHidden(true)
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
}

#Preview {
    CamouflageView(onExit: {})
}
