import SwiftUI

struct ResourcesView: View {
    var body: some View {
        List {
            Section("Selbsteinschätzung & Wissen") {
                NavigationLink(destination: SelfAssessmentView()) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("PGSI Selbsttest")
                                .font(.body)
                                .bold()
                            Text("9 wissenschaftliche Fragen zur Selbsteinschätzung")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "doc.text.magnifyingglass")
                            .foregroundStyle(Design.Colors.primary)
                    }
                }

                NavigationLink(destination: CognitiveDistortionView()) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Denkfallen verstehen")
                                .font(.body)
                                .bold()
                            Text("Spielerfehlschluss, Verlustjagd & Illusionen")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "brain.head.profile")
                            .foregroundStyle(Design.Colors.secondary)
                    }
                }
            }

            Section("Deutsche Hilfsangebote & Hotlines") {
                Link(destination: URL(string: "tel:08001372700")!) {
                    Label("BZgA Telefonberatung (0800 1 37 27 00)", systemImage: "phone.fill")
                }
                Link(destination: URL(string: "https://www.check-dein-spiel.de")!) {
                    Label("BZgA Informationsportal", systemImage: "globe")
                }
                Link(destination: URL(string: "https://rp-darmstadt.hessen.de")!) {
                    Label("OASIS Spielersperre (Bundesweit)", systemImage: "shield.fill")
                }
                Link(destination: URL(string: "https://www.playchange.de")!) {
                    Label("PlayChange Online-Beratung", systemImage: "person.2.fill")
                }
                Link(destination: URL(string: "https://www.digisucht.de")!) {
                    Label("DigiSucht Beratungsplattform", systemImage: "laptopcomputer")
                }
                Link(destination: URL(string: "https://www.anonyme-spieler.org")!) {
                    Label("Anonyme Spieler (Selbsthilfegruppen)", systemImage: "person.3.fill")
                }
                Link(destination: URL(string: "https://www.suchtberatung-der-caritas.de")!) {
                    Label("Caritas & Diakonie Suchtberatung", systemImage: "cross.case.fill")
                }
                Link(destination: URL(string: "https://www.forum-schuldnerberatung.de")!) {
                    Label("Kostenlose Schuldnerberatung", systemImage: "eurosign.circle.fill")
                }
                Link(destination: URL(string: "tel:08001110111")!) {
                    Label("Telefonseelsorge (24/7 Notfall)", systemImage: "phone.circle.fill")
                }
            }

            Section("Internationale Hilfe") {
                Link(destination: URL(string: "https://www.ncpgambling.org")!) {
                    Label("USA: 1-800-GAMBLER (NCPG)", systemImage: "globe.americas.fill")
                }
                Link(destination: URL(string: "https://www.gamcare.org.uk")!) {
                    Label("UK: GamCare (0808 8020 133)", systemImage: "globe.europe.africa.fill")
                }
                Link(destination: URL(string: "https://www.gamblinghelponline.org.au")!) {
                    Label("Australien: Gambling Help Online", systemImage: "globe.asia.australia.fill")
                }
            }

            Section("Kostenlose Sperr-Software") {
                Link(destination: URL(string: "https://betblocker.org")!) {
                    Label("BetBlocker (Kostenlos für alle Geräte)", systemImage: "lock.shield.fill")
                }
                Link(destination: URL(string: "https://gamban.com")!) {
                    Label("Gamban Software", systemImage: "lock.fill")
                }
            }
        }
        .navigationTitle("Hilfsangebote")
    }
}

#Preview {
    NavigationStack {
        ResourcesView()
    }
}
