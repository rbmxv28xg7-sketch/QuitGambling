import SwiftUI

struct DEADSStrategyView: View {
    var body: some View {
        TabView {
            DEADSCard(
                letter: "D",
                title: "Delay (Verzögern)",
                description: "Warte 15 Minuten. Der Suchtdruck ist wie eine Welle, die oft nach kurzer Zeit wieder abflacht.",
                tips: "Stelle einen Timer. Versprich dir selbst, zumindest bis zum Ablauf der Zeit zu warten.",
                color: Design.Colors.primary
            )
            DEADSCard(
                letter: "E",
                title: "Escape (Entkommen)",
                description: "Verlasse die Situation, die den Suchtdruck auslöst.",
                tips: "Geh nach draußen, wechsle den Raum oder beende das Gespräch, das dich triggert.",
                color: Design.Colors.secondary
            )
            DEADSCard(
                letter: "A",
                title: "Avoid (Vermeiden)",
                description: "Meide bekannte Auslöser für dein Verhalten.",
                tips: "Blockiere bestimmte Webseiten, nimm eine andere Route nach Hause oder meide bestimmte Orte.",
                color: Design.Colors.gold
            )
            DEADSCard(
                letter: "D",
                title: "Distract (Ablenken)",
                description: "Lenke deine Aufmerksamkeit auf etwas anderes.",
                tips: "Ruf jemanden an, löse ein Rätsel, lies ein Buch oder mach Sport.",
                color: Design.Colors.accent
            )
            DEADSCard(
                letter: "S",
                title: "Substitute (Ersetzen)",
                description: "Ersetze das schädliche Verhalten durch eine gesunde Alternative.",
                tips: "Trinke ein Glas Wasser, iss einen Apfel oder mach eine Atemübung.",
                color: Design.Colors.primaryLight
            )
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .background(Design.Colors.background.ignoresSafeArea())
        .navigationTitle("D.E.A.D.S.")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DEADSCard: View {
    let letter: String
    let title: String
    let description: String
    let tips: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Design.Spacing.lg) {
            Text(letter)
                .font(.system(size: 140, weight: .bold))
                .foregroundStyle(color)
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Design.Colors.secondary)
            
            Text(description)
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundStyle(Design.Colors.secondary)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                Text("Tipps:")
                    .font(.headline)
                    .foregroundStyle(Design.Colors.secondary)
                
                Text(tips)
                    .font(.body)
                    .foregroundStyle(Design.Colors.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.vertical, Design.Spacing.xl)
    }
}

#Preview {
    NavigationStack {
        DEADSStrategyView()
    }
}
