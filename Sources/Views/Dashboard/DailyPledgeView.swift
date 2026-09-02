import SwiftUI

struct DailyPledgeView: View {
    var hasPledgedToday: Bool
    var onPledge: () -> Void
    
    var body: some View {
        Group {
            if hasPledgedToday {
                HStack(spacing: Design.Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Design.Colors.primary)
                    Text("Du hast heute dein Versprechen gegeben ✓")
                        .font(.headline)
                        .foregroundStyle(Design.Colors.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Design.Spacing.md)
                .background(Design.Colors.primary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: Design.Radius.md))
            } else {
                Button(action: {
                    withAnimation(Design.Anim.normal) {
                        onPledge()
                    }
                }) {
                    Text("Ich spiele heute nicht ✋")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(Design.Colors.primary)
                .sensoryFeedback(.success, trigger: hasPledgedToday)
            }
        }
    }
}

#Preview {
    VStack {
        DailyPledgeView(hasPledgedToday: false, onPledge: {})
        DailyPledgeView(hasPledgedToday: true, onPledge: {})
    }
    .padding()
}
