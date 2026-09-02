import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: FinanceView()) {
                    Label("Finanzen", systemImage: "banknote")
                }
                NavigationLink(destination: ResourcesView()) {
                    Label("Hilfsangebote", systemImage: "lifepreserver")
                }
                NavigationLink(destination: SettingsView()) {
                    Label("Einstellungen", systemImage: "gear")
                }
            }
            .navigationTitle("Mehr")
        }
    }
}

#Preview {
    MoreView()
}
