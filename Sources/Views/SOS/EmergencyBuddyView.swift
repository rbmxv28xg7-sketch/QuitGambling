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
    @State private var newRelationship = "Partner"
    @State private var newMessage = "Hey, I'm feeling a strong urge right now and could really use a quick chat or support. Do you have a minute?"

    private var buddy: EmergencyContact? { contacts.first }

    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()

            ScrollView(showsIndicators: false) {
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
        }
        .navigationTitle("Emergency Buddy".loc)
        .toolbar {
            if buddy != nil {
                Button("Edit".loc, systemImage: "pencil") {
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
                .scrollIndicators(.hidden)
        }
        .scrollIndicators(.hidden)
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
                    Text(contact.relationship.isEmpty ? "Trusted Contact".loc : contact.relationship)
                        .font(.subheadline)
                        .foregroundStyle(Design.Colors.textSecondary)
                    Text(contact.phoneNumber)
                        .font(.caption)
                        .foregroundStyle(Design.Colors.textTertiary)
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: Design.Spacing.xs) {
                Text("Pre-written SOS Message:".loc)
                    .font(.caption)
                    .foregroundStyle(Design.Colors.textSecondary)
                Text("\"\(contact.customMessage)\"")
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(Color.white.opacity(0.90))
                    .padding(Design.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Design.Radius.md, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )
            }

            HStack(spacing: Design.Spacing.md) {
                // SMS Button
                Button {
                    sendSOSMessage(contact)
                } label: {
                    Label("Send SMS".loc, systemImage: "message.fill")
                        .font(.headline)
                        .foregroundStyle(Design.Colors.textOnPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Design.Colors.primary)
                        .clipShape(.rect(cornerRadius: Design.Radius.md))
                }

                // Call Button
                Button {
                    callBuddy(contact)
                } label: {
                    Label("Call".loc, systemImage: "phone.fill")
                        .font(.headline)
                        .foregroundStyle(Design.Colors.textOnPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Design.Colors.accent)
                        .clipShape(.rect(cornerRadius: Design.Radius.md))
                }
            }
        }
        .sereneCardStyle(padding: Design.Spacing.lg)
    }

    // MARK: - No Buddy Card

    private var noBuddyCard: some View {
        VStack(spacing: Design.Spacing.lg) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 56))
                .foregroundStyle(Design.Colors.primary)

            VStack(spacing: Design.Spacing.xs) {
                Text("Add a Trusted Contact".loc)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.white)
                Text("Set up your partner, friend, or counselor. When an urge hits, you can reach out with a single tap.".loc)
                    .font(.subheadline)
                    .foregroundStyle(Design.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                newName = ""
                newPhone = ""
                newRelationship = "Partner"
                newMessage = "Hey, I'm feeling a strong urge right now and could really use a quick chat or support. Do you have a minute?"
                isShowingAddSheet = true
            } label: {
                Text("Set Up Buddy Now".loc)
                    .font(.headline)
                    .foregroundStyle(Design.Colors.textOnPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Design.Colors.primary)
                    .clipShape(.rect(cornerRadius: Design.Radius.md))
            }
        }
        .sereneCardStyle(padding: Design.Spacing.xl)
    }

    // MARK: - Tips Card

    private var tipsCard: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            Label("Why an Emergency Buddy Helps".loc, systemImage: "lightbulb.fill")
                .font(.headline)
                .foregroundStyle(Design.Colors.gold)

            Text("• **Connection over isolation:** Compulsive urges thrive on solitude and secrecy.\n• **Accountability brake:** An open word with a trusted person immediately interrupts tunnel vision.\n• **Immediate relief:** Simply sending the prepared SOS message helps bridge the critical first 15 minutes.".loc)
                .font(.subheadline)
                .foregroundStyle(Design.Colors.textSecondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .sereneCardStyle(padding: Design.Spacing.lg)
    }

    // MARK: - Edit/Add Sheet

    private var editBuddySheet: some View {
        NavigationStack {
            ZStack {
                FlutedGlassBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Design.Spacing.lg) {
                        Text((buddy == nil ? "Add Buddy" : "Edit Buddy").loc)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, Design.Spacing.xs)

                        buddyFormSection("Contact Details".loc) {
                            TextField("Full Name".loc, text: $newName)
                                .foregroundStyle(Design.Colors.textPrimary)
                            Divider().background(Color.white.opacity(0.12))
                            TextField("Phone Number (e.g. +1 555...)".loc, text: $newPhone)
                                .keyboardType(.phonePad)
                                .foregroundStyle(Design.Colors.textPrimary)
                            Divider().background(Color.white.opacity(0.12))
                            TextField("Relationship (e.g. Partner, Friend, Sibling)".loc, text: $newRelationship)
                                .foregroundStyle(Design.Colors.textPrimary)
                        }

                        buddyFormSection("Pre-written SOS Message".loc) {
                            TextField("Message".loc, text: $newMessage, axis: .vertical)
                                .lineLimit(3...6)
                                .foregroundStyle(Design.Colors.textPrimary)
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
                    Button("Cancel".loc) { isShowingAddSheet = false }
                        .foregroundStyle(Design.Colors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save".loc) {
                        saveBuddy()
                        isShowingAddSheet = false
                    }
                    .bold()
                    .foregroundStyle(Design.Colors.gold)
                    .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty || newPhone.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func buddyFormSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(Design.Colors.gold)
                .padding(.leading, 8)

            VStack(spacing: Design.Spacing.md) {
                content()
            }
            .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.md)
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
