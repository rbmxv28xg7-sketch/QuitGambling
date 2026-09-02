import SwiftUI
import SwiftData

/// Multi-step onboarding flow for first-time users.
struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var currentStep = 0
    @State private var startDate = Date.now
    @State private var dailySpend: Double = 50.0
    @State private var showCheckmark = false

    var body: some View {
        TabView(selection: $currentStep) {
            welcomeStep.tag(0)
            dateStep.tag(1)
            spendStep.tag(2)
            completionStep.tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }

    // MARK: - Step 0: Welcome

    private var welcomeStep: some View {
        VStack(spacing: Design.Spacing.xl) {
            Spacer()

            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(Design.Colors.primary)

            VStack(spacing: Design.Spacing.md) {
                Text("Willkommen bei FreiSpiel")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)

                Text("Dein erster Schritt in ein spielfreies Leben. Wir begleiten dich auf deinem Weg.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            onboardingButton("Weiter") {
                withAnimation { currentStep = 1 }
            }
        }
        .padding(Design.Spacing.xl)
    }

    // MARK: - Step 1: Date

    private var dateStep: some View {
        VStack(spacing: Design.Spacing.xl) {
            Text("Wann hast du zuletzt gespielt?")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.top, Design.Spacing.xxl)

            DatePicker(
                "Datum",
                selection: $startDate,
                in: ...Date.now,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(Design.Colors.primary)
            .padding()

            Spacer()

            onboardingButton("Weiter") {
                withAnimation { currentStep = 2 }
            }
        }
        .padding(Design.Spacing.xl)
    }

    // MARK: - Step 2: Spend

    private var spendStep: some View {
        VStack(spacing: Design.Spacing.xl) {
            Spacer()

            Text("Wie viel hast du durchschnittlich pro Tag ausgegeben?")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)

            VStack(spacing: Design.Spacing.md) {
                Text(dailySpend, format: .currency(code: "EUR"))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(Design.Colors.primary)
                    .contentTransition(.numericText())
                    .animation(Design.Anim.normal, value: dailySpend)

                Slider(value: $dailySpend, in: 0...500, step: 5)
                    .tint(Design.Colors.primary)
                    .padding(.horizontal)

                Text("Du kannst diesen Wert sp\u{00E4}ter jederzeit \u{00E4}ndern.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, Design.Spacing.xl)

            Spacer()

            onboardingButton("Weiter") {
                withAnimation { currentStep = 3 }
            }
        }
        .padding(Design.Spacing.xl)
    }

    // MARK: - Step 3: Completion

    private var completionStep: some View {
        VStack(spacing: Design.Spacing.xl) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(Design.Colors.primary)
                .scaleEffect(showCheckmark ? 1.0 : 0.5)
                .opacity(showCheckmark ? 1.0 : 0)
                .animation(Design.Anim.spring, value: showCheckmark)

            VStack(spacing: Design.Spacing.md) {
                Text("Du bist bereit")
                    .font(.largeTitle)
                    .bold()

                Text("Jeder Tag z\u{00E4}hlt. Wir sind f\u{00FC}r dich da.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            onboardingButton("Los geht's") {
                completeOnboarding()
            }
        }
        .padding(Design.Spacing.xl)
        .task {
            try? await Task.sleep(for: .milliseconds(300))
            showCheckmark = true
        }
    }

    // MARK: - Helpers

    private func onboardingButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Design.Colors.primary)
                .clipShape(.rect(cornerRadius: Design.Radius.md))
        }
    }

    private func completeOnboarding() {
        let profile = UserProfile(
            sobrietyStartDate: startDate,
            dailyGamblingSpend: dailySpend
        )
        profile.hasCompletedOnboarding = true
        modelContext.insert(profile)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
