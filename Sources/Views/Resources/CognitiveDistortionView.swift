import SwiftUI

struct CognitiveDistortionView: View {
    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: Design.Spacing.lg) {
                    DistortionCard(
                        icon: "dice.fill",
                        title: "Gambler's Fallacy",
                        distortedThought: "\"After so many losses, a big win must be due.\"",
                        realityCheck: "The mathematical odds remain identical on every single round, independent of past outcomes. The machine or dealer has no memory."
                    )
                    
                    DistortionCard(
                        icon: "wand.and.stars",
                        title: "Illusion of Control",
                        distortedThought: "\"I have a system. If I focus and time it right, I can influence the outcome.\"",
                        realityCheck: "Gambling outcomes are determined by random number generators (RNG) and fixed mathematical house edges. Neither rituals nor 'tactics' alter the math."
                    )
                    
                    DistortionCard(
                        icon: "exclamationmark.triangle.fill",
                        title: "Near-Miss Illusion",
                        distortedThought: "\"That was so close! Just one symbol off from the jackpot. Next time is the one.\"",
                        realityCheck: "A 'near miss' is technically 100% a loss. Games are engineered specifically to produce frequent near misses to spike dopamine and trick your brain into playing on."
                    )
                    
                    DistortionCard(
                        icon: "arrow.uturn.backward.circle.fill",
                        title: "Chasing Losses",
                        distortedThought: "\"I'll just bet a bit more to win back what I lost today.\"",
                        realityCheck: "This is the single fastest spiral into catastrophic losses. Chasing is emotional, not logical. Every new wager is new risk. Walk away clean."
                    )
                }
                .padding(.horizontal)
                .padding(.top, Design.Spacing.md)
                .padding(.bottom, 96)
            }
        }
        .navigationTitle("Cognitive Traps")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DistortionCard: View {
    let icon: String
    let title: String
    let distortedThought: String
    let realityCheck: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.md) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(Design.Colors.gold)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Design.Colors.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(Design.Colors.sos)
                    Text("The Trap:")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Design.Colors.sos)
                }
                Text(distortedThought)
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(Design.Colors.textSecondary)
            }
            .padding(Design.Spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Design.Colors.sos.opacity(0.10))
            .overlay(
                Rectangle()
                    .fill(Design.Colors.sos)
                    .frame(width: 3),
                alignment: .leading
            )
            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.sm))
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.caption2)
                        .foregroundStyle(Design.Colors.signalGreen)
                    Text("The Reality:")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Design.Colors.signalGreen)
                }
                Text(realityCheck)
                    .font(.subheadline)
                    .foregroundStyle(Design.Colors.textPrimary)
                    .lineSpacing(2)
            }
            .padding(Design.Spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Design.Colors.signalGreen.opacity(0.10))
            .overlay(
                Rectangle()
                    .fill(Design.Colors.signalGreen)
                    .frame(width: 3),
                alignment: .leading
            )
            .clipShape(RoundedRectangle(cornerRadius: Design.Radius.sm))
        }
        .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.lg)
    }
}

#Preview {
    NavigationStack {
        CognitiveDistortionView()
    }
}
