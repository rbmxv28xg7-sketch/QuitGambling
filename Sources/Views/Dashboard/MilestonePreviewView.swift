import SwiftUI

struct MilestonePreviewView: View {
    var viewModel: DashboardViewModel
    
    var body: some View {
        HStack(spacing: Design.Spacing.md) {
            ZStack {
                ProgressView(value: viewModel.milestoneProgress)
                    .progressViewStyle(.circular)
                    .tint(Design.Colors.gold)
                    .scaleEffect(1.5)
                
                if let next = viewModel.nextMilestone {
                    Image(systemName: next.icon)
                        .foregroundStyle(Design.Colors.gold)
                }
            }
            .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: Design.Spacing.xs) {
                if let next = viewModel.nextMilestone {
                    Text("Noch \(viewModel.daysToNextMilestone) Tage bis \(next.label)")
                        .font(.headline)
                        .foregroundStyle(Design.Colors.primary)
                    Text("Dein nächster Meilenstein")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Alle Meilensteine erreicht!")
                        .font(.headline)
                        .foregroundStyle(Design.Colors.primary)
                }
            }
            
            Spacer()
        }
        .padding(Design.Spacing.md)
        .background(Design.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
    }
}

#Preview {
    MilestonePreviewView(viewModel: DashboardViewModel())
}
