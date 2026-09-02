import SwiftUI

struct RelapseReflectionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var trigger: String = ""
    @State private var futurePlan: String = ""
    @State private var achievements: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Design.Spacing.xl) {
                    VStack(spacing: Design.Spacing.sm) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Design.Colors.accent)
                        
                        Text("Es ist okay.")
                            .font(.title)
                            .bold()
                        
                        Text("Du bist hier, und das ist mutig. Jeder Tag, den du bisher geschafft hast, zählt. Lass uns gemeinsam reflektieren, was passiert ist, ohne dich zu verurteilen.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Design.Colors.secondary)
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: Design.Spacing.lg) {
                        VStack(alignment: .leading) {
                            Text("Was hat dazu geführt?")
                                .font(.headline)
                            TextField("Situation, Gefühle, Gedanken...", text: $trigger, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...)
                                .frame(minHeight: 44)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Was kannst du das nächste Mal anders machen?")
                                .font(.headline)
                            TextField("Alternative Handlungen...", text: $futurePlan, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...)
                                .frame(minHeight: 44)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Worauf bist du in deiner spielfreien Zeit stolz?")
                                .font(.headline)
                            TextField("Deine Erfolge...", text: $achievements, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...)
                                .frame(minHeight: 44)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schließen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        // Logik zum Speichern der Reflexion
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RelapseReflectionView()
}
