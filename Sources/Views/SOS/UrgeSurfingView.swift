import SwiftUI

struct UrgeSurfingView: View {
    @Bindable var viewModel: SOSViewModel

    init(viewModel: SOSViewModel = SOSViewModel()) {
        self.viewModel = viewModel
    }
    
    var timeString: String {
        let minutes = viewModel.urgeSurfingRemaining / 60
        let seconds = viewModel.urgeSurfingRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: Design.Spacing.xl) {
            Text("Stell dir den Suchtdruck wie eine Welle vor. Sie baut sich auf, erreicht einen Höhepunkt und flacht wieder ab. Du musst nicht gegen sie ankämpfen, sondern kannst sie einfach 'reiten' (surfen), bis sie vergeht.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Design.Colors.secondary)
                .padding()
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Design.Colors.primaryLight.opacity(0.3), lineWidth: 20)
                    .frame(width: 250, height: 250)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(viewModel.urgeSurfingRemaining) / 900.0)
                    .stroke(Design.Colors.primary, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1.0), value: viewModel.urgeSurfingRemaining)
                
                Text(timeString)
                    .font(.system(size: 60, weight: .bold, design: .monospaced))
                    .foregroundStyle(Design.Colors.secondary)
            }
            
            Spacer()
            
            HStack(spacing: Design.Spacing.md) {
                Button(action: {
                    if viewModel.isUrgeSurfingActive {
                        viewModel.isUrgeSurfingActive = false
                    } else {
                        viewModel.startUrgeSurfing()
                    }
                }) {
                    Text(viewModel.isUrgeSurfingActive ? "Pause" : "Start")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(viewModel.isUrgeSurfingActive ? Design.Colors.gold : Design.Colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
                }
                
                Button(action: {
                    viewModel.stopUrgeSurfing()
                }) {
                    Text("Reset")
                        .font(.headline)
                        .foregroundStyle(Design.Colors.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Design.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, Design.Spacing.xl)
        }
        .background(Design.Colors.background.ignoresSafeArea())
        .navigationTitle("Urge Surfing")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: viewModel.isUrgeSurfingActive) {
            guard viewModel.isUrgeSurfingActive else { return }
            while viewModel.isUrgeSurfingActive && viewModel.urgeSurfingRemaining > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard viewModel.isUrgeSurfingActive else { break }
                viewModel.urgeSurfingRemaining -= 1
            }
            if viewModel.urgeSurfingRemaining == 0 {
                viewModel.isUrgeSurfingActive = false
            }
        }
        .onDisappear {
            viewModel.isUrgeSurfingActive = false
        }
    }
}

#Preview {
    NavigationStack {
        UrgeSurfingView(viewModel: SOSViewModel())
    }
}
