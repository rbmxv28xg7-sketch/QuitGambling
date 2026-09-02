import SwiftUI

/// Reusable milestone badge icon showing achieved or locked state.
struct MilestoneIcon: View {
    let milestone: Design.Milestone
    let isAchieved: Bool
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            Circle()
                .fill(isAchieved ? Design.Colors.gold.opacity(0.2) : Color.gray.opacity(0.12))
                .frame(width: size, height: size)

            if isAchieved {
                Image(systemName: milestone.icon)
                    .font(.system(size: size * 0.38))
                    .foregroundStyle(Design.Colors.gold)
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: size * 0.3))
                    .foregroundStyle(.gray.opacity(0.5))
            }
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        MilestoneIcon(milestone: .week1, isAchieved: true)
        MilestoneIcon(milestone: .month1, isAchieved: false)
    }
}
