import SwiftUI
import SwiftData

struct ReasonsCardDeckView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ReasonToQuit.createdDate) private var reasons: [ReasonToQuit]
    
    @State private var showingAddSheet = false
    @State private var newReasonText = ""
    
    var body: some View {
        ZStack {
            Design.Colors.background.ignoresSafeArea()
            
            if reasons.isEmpty {
                ContentUnavailableView(
                    "Keine Gründe",
                    systemImage: "heart.text.square",
                    description: Text("Füge Gründe hinzu, warum du frei sein möchtest.")
                )
            } else {
                TabView {
                    ForEach(reasons) { reason in
                        ReasonCard(text: reason.text)
                            .padding()
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
        .navigationTitle("Meine Gründe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                        .frame(width: 44, height: 44) // 44pt min tap
                        .contentShape(Rectangle())
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            NavigationStack {
                Form {
                    Section(header: Text("Neuer Grund")) {
                        TextField("Ich möchte aufhören, weil...", text: $newReasonText, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
                .navigationTitle("Grund hinzufügen")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Abbrechen") {
                            showingAddSheet = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Speichern") {
                            let reason = ReasonToQuit(text: newReasonText)
                            modelContext.insert(reason)
                            newReasonText = ""
                            showingAddSheet = false
                        }
                        .disabled(newReasonText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}

struct ReasonCard: View {
    let text: String
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "quote.opening")
                .font(.system(size: 40))
                .foregroundStyle(Design.Colors.accent.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, Design.Spacing.sm)
            
            Text(text)
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundStyle(Design.Colors.secondary)
            
            Image(systemName: "quote.closing")
                .font(.system(size: 40))
                .foregroundStyle(Design.Colors.accent.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, Design.Spacing.sm)
            Spacer()
        }
        .padding(Design.Spacing.xl)
        .background(Design.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: Design.Radius.xl))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(Design.Spacing.md)
    }
}

#Preview {
    NavigationStack {
        ReasonsCardDeckView()
            .modelContainer(for: ReasonToQuit.self, inMemory: true)
    }
}
