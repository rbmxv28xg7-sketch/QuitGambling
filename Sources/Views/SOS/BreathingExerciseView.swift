import SwiftUI

struct BreathingExerciseView: View {
    @Bindable var viewModel: SOSViewModel

    init(viewModel: SOSViewModel = SOSViewModel()) {
        self.viewModel = viewModel
    }
    
    var phaseText: String {
        switch viewModel.breathingPhase {
        case .inhale: return "Einatmen"
        case .holdIn: return "Halten"
        case .exhale: return "Ausatmen"
        case .holdOut: return "Halten"
        }
    }
    
    var circleScale: CGFloat {
        switch viewModel.breathingPhase {
        case .inhale: return 1.5
        case .holdIn: return 1.5
        case .exhale: return 0.8
        case .holdOut: return 0.8
        }
    }
    
    var body: some View {
        VStack(spacing: Design.Spacing.xl) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Design.Colors.primaryLight.opacity(0.3))
                    .frame(width: 200, height: 200)
                    .scaleEffect(viewModel.isBreathingActive ? circleScale : 1.0)
                    .animation(.linear(duration: 4.0), value: circleScale)
                
                Text(viewModel.isBreathingActive ? phaseText : "Bereit?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Design.Colors.secondary)
            }
            
            Spacer()
            
            Text("Zyklen: \(viewModel.cycleCount)")
                .font(.headline)
                .foregroundStyle(Design.Colors.secondary)
            
            Button(action: {
                if viewModel.isBreathingActive {
                    viewModel.stopBreathing()
                } else {
                    viewModel.startBreathing()
                }
            }) {
                Text(viewModel.isBreathingActive ? "Stopp" : "Start")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(viewModel.isBreathingActive ? Design.Colors.sos : Design.Colors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
            }
            .padding(.horizontal)
            .padding(.bottom, Design.Spacing.xl)
        }
        .background(
            LinearGradient(
                colors: [Design.Colors.background, Design.Colors.primaryLight.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
        )
        .navigationTitle("Atemübung")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: viewModel.isBreathingActive) {
            guard viewModel.isBreathingActive else { return }
            
            while viewModel.isBreathingActive {
                viewModel.breathingPhase = .inhale
                try? await Task.sleep(for: .seconds(4))
                guard viewModel.isBreathingActive else { break }
                
                viewModel.breathingPhase = .holdIn
                try? await Task.sleep(for: .seconds(4))
                guard viewModel.isBreathingActive else { break }
                
                viewModel.breathingPhase = .exhale
                try? await Task.sleep(for: .seconds(4))
                guard viewModel.isBreathingActive else { break }
                
                viewModel.breathingPhase = .holdOut
                try? await Task.sleep(for: .seconds(4))
                guard viewModel.isBreathingActive else { break }
                
                viewModel.cycleCount += 1
            }
        }
        .onDisappear {
            viewModel.stopBreathing()
        }
    }
}

#Preview {
    NavigationStack {
        BreathingExerciseView(viewModel: SOSViewModel())
    }
}
