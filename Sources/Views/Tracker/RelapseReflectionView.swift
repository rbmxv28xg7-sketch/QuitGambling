import SwiftUI

struct RelapseReflectionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var trigger: String = ""
    @State private var futurePlan: String = ""
    @State private var achievements: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                FlutedGlassBackgroundView()

                ScrollView(showsIndicators: false) {
                VStack(spacing: Design.Spacing.xl) {
                    VStack(spacing: Design.Spacing.sm) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Design.Colors.accent)
                        
                        Text("It's okay.")
                            .font(.title)
                            .bold()
                        
                        Text("You are here, and that takes courage. Every day of freedom you've achieved still counts. Let's reflect together on what happened, without judgment.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Design.Colors.secondary)
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: Design.Spacing.lg) {
                        VStack(alignment: .leading) {
                            Text("What led up to this?")
                                .font(.headline)
                            TextField("Situation, feelings, thoughts...", text: $trigger, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...)
                                .frame(minHeight: 44)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("What can you do differently next time?")
                                .font(.headline)
                            TextField("Alternative actions, coping steps...", text: $futurePlan, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...)
                                .frame(minHeight: 44)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("What are you proud of during your clean time?")
                                .font(.headline)
                            TextField("Your achievements, lessons learned...", text: $achievements, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...)
                                .frame(minHeight: 44)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .dismissKeyboardOnTap()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Logic to save reflection
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
