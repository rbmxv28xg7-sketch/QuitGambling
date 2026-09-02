import SwiftUI
import SwiftData

struct SOSView: View {
    @State private var viewModel = SOSViewModel()
    @Query private var contacts: [EmergencyContact]

    private var buddy: EmergencyContact? { contacts.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Design.Spacing.lg) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Du bist nicht allein.")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Design.Colors.secondary)

                        Text("Nutze diese Werkzeuge, um den akuten Spieldruck sicher zu überstehen.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    // Hero Buddy Card
                    NavigationLink(destination: EmergencyBuddyView()) {
                        HStack(spacing: Design.Spacing.md) {
                            ZStack {
                                Circle()
                                    .fill(Design.Colors.accent.opacity(0.2))
                                    .frame(width: 52, height: 52)
                                Image(systemName: "person.2.fill")
                                    .font(.title3)
                                    .foregroundStyle(Design.Colors.accent)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(buddy == nil ? "Notfall-Buddy festlegen" : "Notfall-Buddy: \(buddy?.name ?? "")")
                                    .font(.headline)
                                    .foregroundStyle(Design.Colors.secondary)
                                Text(buddy == nil ? "Hinterlege eine Vertrauensperson für Krisen" : "Schnellkontakt per SMS oder Anruf")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                        }
                        .padding(Design.Spacing.md)
                        .background(Design.Colors.surface)
                        .clipShape(.rect(cornerRadius: Design.Radius.lg))
                        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
                    }
                    .padding(.horizontal)

                    // Exercise Grid
                    LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: Design.Spacing.md) {
                        NavigationLink(destination: BreathingExerciseView(viewModel: viewModel)) {
                            SOSCard(title: "Atemübung", icon: "lungs.fill", color: Design.Colors.primaryLight)
                        }

                        NavigationLink(destination: UrgeSurfingView(viewModel: viewModel)) {
                            SOSCard(title: "Urge Surfing", icon: "water.waves", color: Design.Colors.primary)
                        }

                        NavigationLink(destination: GroundingExerciseView(viewModel: viewModel)) {
                            SOSCard(title: "Erdungsübung", icon: "figure.mind.and.body", color: Design.Colors.gold)
                        }

                        NavigationLink(destination: DEADSStrategyView()) {
                            SOSCard(title: "D.E.A.D.S.", icon: "shield.fill", color: Design.Colors.secondary)
                        }

                        NavigationLink(destination: ReasonsCardDeckView()) {
                            SOSCard(title: "Meine Gründe", icon: "heart.text.square.fill", color: Design.Colors.accent)
                        }

                        NavigationLink(destination: HotlineListView()) {
                            SOSCard(title: "Soforthilfe", icon: "phone.fill", color: Design.Colors.sos)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Design.Colors.background)
            .navigationTitle("SOS Notfall-Hilfe")
        }
    }
}

struct SOSCard: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: Design.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 32))
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(color)
        .clipShape(.rect(cornerRadius: Design.Radius.lg))
    }
}

#Preview {
    SOSView()
        .modelContainer(for: EmergencyContact.self, inMemory: true)
}
