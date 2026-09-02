import SwiftUI

struct HotlineListView: View {
    var body: some View {
        List {
            Section {
                Text("Ein Anruf kann alles verändern.")
                    .font(.headline)
                    .foregroundStyle(Design.Colors.secondary)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
            }
            
            Section(header: Text("Deutschland")) {
                HotlineRow(name: "BZgA Suchttelefon", number: "0800 1 37 27 00")
                HotlineRow(name: "Telefonseelsorge", number: "0800 111 0 111")
                HotlineRow(name: "OASIS Info", number: "0800 137 2700")
            }
            
            Section(header: Text("International")) {
                HotlineRow(name: "US National Helpline", number: "1-800-522-4700")
                HotlineRow(name: "UK GamCare", number: "0808 8020 133")
                HotlineRow(name: "AU Gambling Help", number: "1800 858 858")
            }
        }
        .navigationTitle("Soforthilfe")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HotlineRow: View {
    let name: String
    let number: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Design.Spacing.xs) {
                Text(name)
                    .font(.body)
                    .fontWeight(.semibold)
                Text(number)
                    .font(.subheadline)
                    .foregroundStyle(Design.Colors.secondary)
            }
            Spacer()
            Button(action: {
                if let url = URL(string: "tel:\(number.replacingOccurrences(of: " ", with: ""))") {
                    UIApplication.shared.open(url)
                }
            }) {
                Image(systemName: "phone.fill")
                    .font(.title2)
                    .foregroundStyle(Design.Colors.sos)
                    .frame(width: 44, height: 44) // 44pt min tap
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, Design.Spacing.xs)
    }
}

#Preview {
    NavigationStack {
        HotlineListView()
    }
}
