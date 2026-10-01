import SwiftUI

struct DEADSStrategyView: View {
    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()

            TabView {
                DEADSCard(
                    letter: "D",
                    title: "Delay".loc,
                    description: "Wait 15 minutes. The compulsive urge is like a wave that naturally crests and subsides after a short delay.".loc,
                    tips: "Set a 15-minute timer. Promise yourself to wait at least until the timer completes.".loc,
                    color: Design.Colors.primary
                )
                DEADSCard(
                    letter: "E",
                    title: "Escape".loc,
                    description: "Remove yourself immediately from the situation triggering the urge.".loc,
                    tips: "Step outside, leave the room, or step away from the screen triggering you.".loc,
                    color: Design.Colors.secondary
                )
                DEADSCard(
                    letter: "A",
                    title: "Avoid".loc,
                    description: "Steer clear of known triggers, environments, and associations.".loc,
                    tips: "Ensure website filters are active, take a different route home, or avoid casino venues.".loc,
                    color: Design.Colors.gold
                )
                DEADSCard(
                    letter: "D",
                    title: "Distract".loc,
                    description: "Redirect your mental focus onto an engaging, positive activity.".loc,
                    tips: "Call your buddy, solve a focus game, take a brisk walk, or do a workout.".loc,
                    color: Design.Colors.accent
                )
                DEADSCard(
                    letter: "S",
                    title: "Substitute".loc,
                    description: "Replace the destructive urge with a healthy, nurturing alternative.".loc,
                    tips: "Drink a tall glass of cold water, listen to soothing music, or do box breathing.".loc,
                    color: Design.Colors.primaryLight
                )
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .navigationTitle("D.E.A.D.S.".loc)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DEADSCard: View {
    let letter: String
    let title: String
    let description: String
    let tips: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Design.Spacing.lg) {
            Text(letter)
                .font(.system(size: 110, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text(description)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Design.Colors.textSecondary)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: Design.Spacing.xs) {
                Label("Practical Tip".loc, systemImage: "lightbulb.fill")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(color)

                Text(tips)
                    .font(.footnote)
                    .foregroundStyle(Design.Colors.textSecondary)
                    .lineSpacing(2)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .sereneCardStyle(padding: Design.Spacing.md)
            .padding(.horizontal)

            Spacer()
        }
        .padding(.vertical, Design.Spacing.xl)
    }
}

#Preview {
    NavigationStack {
        DEADSStrategyView()
    }
}
