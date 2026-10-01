import SwiftUI

/// Hero card displaying total money saved since sobriety start date.
struct SavingsProgressView: View {
    let totalSaved: Double
    let startDate: Date

    var body: some View {
        VStack(spacing: Design.Spacing.md) {
            HStack {
                Image(systemName: "leaf.fill")
                    .font(.title2)
                    .foregroundStyle(Design.Colors.textOnPrimary.opacity(0.85))
                Spacer()
                Image(systemName: "banknote.fill")
                    .font(.title3)
                    .foregroundStyle(Design.Colors.textOnPrimary.opacity(0.85))
            }

            VStack(spacing: Design.Spacing.xs) {
                Text(totalSaved, format: .currency(code: "USD"))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(Design.Colors.textOnPrimary)
                    .contentTransition(.numericText())
                    .animation(Design.Anim.normal, value: totalSaved)

                Text("Saved since \(startDate, format: .dateTime.day().month(.wide).year())")
                    .font(.subheadline)
                    .foregroundStyle(Design.Colors.textOnPrimary.opacity(0.85))
            }
        }
        .padding(Design.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Design.Colors.primary, Design.Colors.primaryLight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: Design.Radius.lg))
    }
}

#Preview {
    SavingsProgressView(totalSaved: 1247.50, startDate: .now.addingTimeInterval(-86400 * 30))
        .padding()
}
