import SwiftUI

struct GroundingExerciseView: View {
    @Bindable var viewModel: SOSViewModel

    init(viewModel: SOSViewModel = SOSViewModel()) {
        self.viewModel = viewModel
    }
    @State private var entryText: String = ""
    
    var currentInstruction: (number: Int, sense: String, icon: String) {
        switch viewModel.groundingStep {
        case 1: return (5, "Dinge, die du sehen kannst", "eye.fill")
        case 2: return (4, "Dinge, die du fühlen kannst", "hand.raised.fill")
        case 3: return (3, "Dinge, die du hören kannst", "ear")
        case 4: return (2, "Dinge, die du riechen kannst", "nose.fill")
        default: return (1, "Ding, das du schmecken kannst", "mouth.fill")
        }
    }
    
    var body: some View {
        VStack(spacing: Design.Spacing.xl) {
            if viewModel.groundingStep > 5 {
                VStack(spacing: Design.Spacing.md) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(Design.Colors.primary)
                    Text("Gut gemacht!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Du hast die Erdungsübung abgeschlossen. Hoffentlich fühlst du dich jetzt ruhiger.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Design.Colors.secondary)
                        .padding()
                    
                    Button(action: {
                        viewModel.resetGrounding()
                    }) {
                        Text("Nochmal")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Design.Colors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
                    }
                    .padding(.horizontal)
                }
            } else {
                VStack(spacing: Design.Spacing.md) {
                    Text("\(currentInstruction.number)")
                        .font(.system(size: 120, weight: .bold))
                        .foregroundStyle(Design.Colors.primary)
                    
                    HStack {
                        Image(systemName: currentInstruction.icon)
                            .font(.title)
                        Text(currentInstruction.sense)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(Design.Colors.secondary)
                    
                    TextField("Tippe hier...", text: $entryText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.top, Design.Spacing.lg)
                    
                    Spacer()
                    
                    Button(action: {
                        entryText = ""
                        viewModel.nextGroundingStep()
                    }) {
                        Text("Weiter")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Design.Colors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
                    }
                    .padding(.bottom, Design.Spacing.xl)
                }
                .padding(.horizontal)
            }
        }
        .background(Design.Colors.background.ignoresSafeArea())
        .navigationTitle("5-4-3-2-1 Methode")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.resetGrounding()
        }
    }
}

#Preview {
    NavigationStack {
        GroundingExerciseView(viewModel: SOSViewModel())
    }
}
