import SwiftUI

struct LiveCounterView: View {
    var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(spacing: Design.Spacing.sm) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 32))
                .foregroundStyle(Design.Colors.primary)
            
            Text("\(viewModel.daysClean)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
                .foregroundStyle(Design.Colors.primary)
            
            Text("Tage spielfrei")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text(String(format: "%02d:%02d:%02d", viewModel.hoursClean, viewModel.minutesClean, viewModel.secondsClean))
                .font(.system(.title3, design: .monospaced))
                .foregroundStyle(.secondary)
                .padding(.top, Design.Spacing.xs)
        }
        .frame(maxWidth: .infinity)
        .padding(Design.Spacing.xl)
        .background(
            Design.Colors.primary.opacity(0.1)
                .gradient
        )
        .clipShape(RoundedRectangle(cornerRadius: Design.Radius.xl))
    }
}

#Preview {
    LiveCounterView(viewModel: DashboardViewModel())
}
