import SwiftUI

struct MilestoneBadgesView: View {
    let daysClean: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            Text("Meilensteine")
                .font(.headline)
                .foregroundStyle(Design.Colors.secondary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Design.Spacing.lg) {
                    ForEach(Design.Milestone.allCases, id: \.self) { milestone in
                        let isAchieved = daysClean >= milestone.days
                        
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(isAchieved ? Design.Colors.gold : Design.Colors.surfaceHover)
                                    .frame(width: 60, height: 60)
                                
                                if isAchieved {
                                    Image(systemName: milestone.icon)
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                    
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.white)
                                        .background(Circle().fill(Color.green))
                                        .offset(x: 20, y: 20)
                                } else {
                                    Image(systemName: "lock.fill")
                                        .font(.title2)
                                        .foregroundStyle(Design.Colors.secondary)
                                }
                            }
                            
                            Text(milestone.label)
                                .font(.caption)
                                .foregroundStyle(isAchieved ? Design.Colors.primary : Design.Colors.secondary)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    MilestoneBadgesView(daysClean: 15)
}
