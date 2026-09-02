import SwiftUI
import SwiftData

/// View for managing and immediately contacting a personal emergency buddy during crisis states.
struct EmergencyBuddyView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @Query private var contacts: [EmergencyContact]

    @State private var isShowingAddSheet = false
    @State private var newName = ""
    @State private var newPhone = ""
    @State private var newRelationship = "Partner/in"
    @State private var newMessage = "Hey, ich verspüre gerade Spieldruck und bräuchte kurz Unterstützung oder ein Gespräch. Hast du kurz Zeit?"

    private var buddy: EmergencyContact? { contacts.first }

    var body: some View {
        ScrollView {
            VStack(spacing: Design.Spacing.xl) {
                if let buddy {
                    activeBuddyCard(buddy)
                } else {
                    noBuddyCard
                }

                tipsCard
            }
            .padding(Design.Spacing.md)
        }
        .navigationTitle("Notfall-Buddy")
        .background(Design.Colors.background)
        .toolbar {
            if buddy != nil {
                Button("Bearbeiten", systemImage: "pencil") {
                    if let b = buddy {
                        newName = b.name
                        newPhone = b.phoneNumber
                        newRelationship = b.relationship
                        newMessage = b.customMessage
                        isShowingAddSheet = true
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingAddSheet) {
            editBuddySheet
        }
    }

    // MARK: - Active Buddy Card

    private func activeBuddyCard(_ contact: EmergencyContact) -> some View {
        VStack(spacing: Design.Spacing.lg) {
            HStack(spacing: Design.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(Design.Colors.primary.opacity(0.15))
                        .frame(width: 60, height: 60)
                    Image(systemName: "person.fill.checkmark")
                        .font(.title2)
                        .foregroundStyle(Design.Colors.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(contact.name)
                        .font(.title3)
                        .bold()
                    Text(contact.relationship.isEmpty ? "Vertrauensperson" : contact.relationship)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(contact.phoneNumber)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: Design.Spacing.xs) {
                Text("Vorbereitete SMS-Nachricht:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\"\(contact.customMessage)\"")
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(Design.Colors.secondary)
                    .padding(Design.Spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Design.Colors.background)
                    .clipShape(.rect(cornerRadius: Design.Radius.sm))
            }

            HStack(spacing: Design.Spacing.md) {
                // SMS Button
                Button {
                    sendSOSMessage(contact)
                } label: {
                    Label("SMS senden", systemImage: "message.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Design.Colors.primary)
                        .clipShape(.rect(cornerRadius: Design.Radius.md))
                }

                // Call Button
                Button {
                    callBuddy(contact)
                } label: {
                    Label("Anrufen", systemImage: "phone.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Design.Colors.accent)
                        .clipShape(.rect(cornerRadius: Design.Radius.md))
                }
            }
        }
        .padding(Design.Spacing.lg)
        .background(Design.Colors.surface)
        .clipShape(.rect(cornerRadius: Design.Radius.lg))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
    }

    // MARK: - No Buddy Card

    private var noBuddyCard: some View {
        VStack(spacing: Design.Spacing.lg) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 64))
                .foregroundStyle(Design.Colors.primary)

            VStack(spacing: Design.Spacing.xs) {
                Text("Vertrauensperson hinzufügen")
                    .font(.title3)
                    .bold()
                Text("Hinterlege einen Partner, Freund oder Therapeuten. Im Moment des Spieldrucks kannst du dich mit einem Klick melden.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                newName = ""
                newPhone = ""
                newRelationship = "Partner/in"
                newMessage = "Hey, ich verspüre gerade Spieldruck und bräuchte kurz Unterstützung oder ein Gespräch. Hast du kurz Zeit?"
                isShowingAddSheet = true
            } label: {
                Text("Buddy jetzt festlegen")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Design.Colors.primary)
                    .clipShape(.rect(cornerRadius: Design.Radius.md))
            }
        }
        .padding(Design.Spacing.xl)
        .background(Design.Colors.surface)
        .clipShape(.rect(cornerRadius: Design.Radius.lg))
    }

    // MARK: - Tips Card

    private var tipsCard: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            Label("Warum ein Buddy hilft", systemImage: "lightbulb.fill")
                .font(.headline)
                .foregroundStyle(Design.Colors.gold)

            Text("• **Verbindung statt Isolation:** Suchtdruck nährt sich von Einsamkeit und Heimlichkeit.\n• **Soziale Hemmschwelle:** Ein offenes Wort zu einer Vertrauensperson unterbricht den Tunnelblick.\n• **Sofortige Entlastung:** Schon das Absenden der Nachricht hilft, die ersten kritischen 15 Minuten zu überbrücken.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
        .padding(Design.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Design.Colors.surface)
        .clipShape(.rect(cornerRadius: Design.Radius.lg))
    }

    // MARK: - Edit/Add Sheet

    private var editBuddySheet: some View {
        NavigationStack {
            Form {
                Section("Kontaktdaten") {
                    TextField("Vollständiger Name", text: $newName)
                    TextField("Telefonnummer (z.B. +49 170...)", text: $newPhone)
                        .keyboardType(.phonePad)
                    TextField("Beziehung (z.B. Partner, Schwester, Freund)", text: $newRelationship)
                }

                Section("Vorgefertigter Hilfetext") {
                    TextField("Nachricht", text: $newMessage, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(buddy == nil ? "Buddy hinzufügen" : "Buddy bearbeiten")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { isShowingAddSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        saveBuddy()
                        isShowingAddSheet = false
                    }
                    .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty || newPhone.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    // MARK: - Actions

    private func saveBuddy() {
        if let existing = buddy {
            existing.name = newName
            existing.phoneNumber = newPhone
            existing.relationship = newRelationship
            existing.customMessage = newMessage
        } else {
            let newContact = EmergencyContact(
                name: newName,
                phoneNumber: newPhone,
                relationship: newRelationship,
                customMessage: newMessage
            )
            modelContext.insert(newContact)
        }
        try? modelContext.save()
    }

    private func sendSOSMessage(_ contact: EmergencyContact) {
        let cleanPhone = contact.phoneNumber.filter { "0123456789+".contains($0) }
        let encodedMessage = contact.customMessage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "sms:\(cleanPhone)&body=\(encodedMessage)") {
            openURL(url)
        }
    }

    private func callBuddy(_ contact: EmergencyContact) {
        let cleanPhone = contact.phoneNumber.filter { "0123456789+".contains($0) }
        if let url = URL(string: "tel:\(cleanPhone)") {
            openURL(url)
        }
    }
}

#Preview {
    NavigationStack {
        EmergencyBuddyView()
    }
    .modelContainer(for: EmergencyContact.self, inMemory: true)
}
