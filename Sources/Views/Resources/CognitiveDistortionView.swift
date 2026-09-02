import SwiftUI

struct CognitiveDistortionView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                DistortionCard(
                    icon: "dice.fill",
                    title: "Spielerfehlschluss",
                    distortedThought: "\"Nach so vielen Verlusten muss ich jetzt endlich gewinnen.\"",
                    realityCheck: "Die Wahrscheinlichkeit eines Gewinns bleibt bei jedem Spiel exakt gleich, unabhängig von vorherigen Ergebnissen. Der Automat hat kein Gedächtnis."
                )
                
                DistortionCard(
                    icon: "wand.and.stars",
                    title: "Kontrollillusion",
                    distortedThought: "\"Ich habe ein System. Wenn ich mich konzentriere, kann ich das Ergebnis beeinflussen.\"",
                    realityCheck: "Glücksspiele sind durch Zufallsgeneratoren gesteuert. Weder Rituale, noch 'Taktik' oder die Tageszeit haben Einfluss auf das Ergebnis."
                )
                
                DistortionCard(
                    icon: "exclamationmark.triangle.fill",
                    title: "Fast-Gewinn-Illusion",
                    distortedThought: "\"Das war so knapp! Ein Symbol weiter und ich hätte den Jackpot. Nächstes Mal klappt es.\"",
                    realityCheck: "Ein 'Fast-Gewinn' ist technisch gesehen ein voller Verlust. Spiele sind absichtlich so programmiert, um diese Illusion zu erzeugen und dich am Spielen zu halten."
                )
                
                DistortionCard(
                    icon: "arrow.uturn.backward.circle.fill",
                    title: "Verlusten hinterherjagen",
                    distortedThought: "\"Ich spiele nur noch ein bisschen, um mein verlorenes Geld zurückzugewinnen.\"",
                    realityCheck: "Das ist der schnellste Weg zu noch größeren Verlusten. Jeder neue Einsatz ist neues Risiko. Verlorenes Geld sollte als Ausgabe für 'Unterhaltung' abgeschrieben werden, nicht als offene Rechnung."
                )
            }
            .padding()
        }
        .navigationTitle("Denkfallen")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DistortionCard: View {
    let icon: String
    let title: String
    let distortedThought: String
    let realityCheck: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.blue) // Design.Colors.primary
                Text(title)
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Die Falle:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(distortedThought)
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(.red) // Emphasize danger
            }
            .padding(.leading, 4)
            .padding(.leading, 12)
            .overlay(
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 4),
                alignment: .leading
            )
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Die Realität:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(realityCheck)
                    .font(.subheadline)
            }
            .padding(.leading, 4)
            .padding(.leading, 12)
            .overlay(
                Rectangle()
                    .fill(Color.green) // Design.Colors.primary
                    .frame(width: 4),
                alignment: .leading
            )
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12) // Design.Radius.medium
    }
}

#Preview {
    NavigationStack {
        CognitiveDistortionView()
    }
}
