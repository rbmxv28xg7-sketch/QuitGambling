import SwiftUI
import SwiftData

/// View for taking the Problem Gambling Severity Index (PGSI) test and viewing historical results.
struct SelfAssessmentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SelfAssessmentResult.date, order: .reverse) private var pastResults: [SelfAssessmentResult]

    @State private var currentQuestionIndex = 0
    @State private var answers: [Int] = Array(repeating: -1, count: 9)
    @State private var isTestActive = false
    @State private var completedResult: SelfAssessmentResult?

    private let questions: [String] = [
        "Have you bet more than you could really afford to lose?",
        "Have you needed to gamble with larger amounts of money to get the same feeling of excitement?",
        "When you gambled, did you go back another day to try to win back the money you lost (chasing losses)?",
        "Have you borrowed money or sold anything to get money to gamble?",
        "Have you felt that you might have a problem with gambling?",
        "Has gambling caused you any health problems, including stress or anxiety?",
        "Have people criticized your betting or told you that you had a gambling problem?",
        "Has your gambling caused any financial problems for you or your household?",
        "Have you felt guilty about the way you gamble or what happens when you gamble?"
    ]

    private let optionLabels = [
        ("Never", 0),
        ("Sometimes", 1),
        ("Often", 2),
        ("Almost Always", 3)
    ]

    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: Design.Spacing.xl) {
                    if let result = completedResult {
                        resultCard(result)
                    } else if isTestActive {
                        questionFlow
                    } else {
                        introCard

                        if !pastResults.isEmpty {
                            historySection
                        }
                    }
                }
                .padding(Design.Spacing.md)
                .padding(.bottom, 96)
            }
        }
        .navigationTitle("PGSI Self-Assessment")
    }

    // MARK: - Intro Card

    private var introCard: some View {
        VStack(spacing: Design.Spacing.lg) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(Design.Colors.gold)

            VStack(spacing: Design.Spacing.sm) {
                Text("Problem Gambling Severity Index (PGSI)")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(Design.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("The Problem Gambling Severity Index (PGSI) is an internationally recognized clinical screening tool with 9 standardized questions to evaluate gambling behavior over the past 12 months.")
                    .font(.subheadline)
                    .foregroundStyle(Design.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            VStack(alignment: .leading, spacing: Design.Spacing.xs) {
                Label("Takes only 2–3 minutes", systemImage: "clock.fill")
                Label("100% anonymous & stored locally", systemImage: "lock.shield.fill")
                Label("Scientifically validated", systemImage: "checkmark.seal.fill")
            }
            .font(.caption)
            .foregroundStyle(Design.Colors.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Design.Spacing.md)
            .background(Color.white.opacity(0.06))
            .clipShape(.rect(cornerRadius: Design.Radius.md))

            Button {
                startNewTest()
            } label: {
                Text("Start Assessment Now")
                    .font(.headline)
                    .foregroundStyle(Design.Colors.textOnPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Design.Colors.primary)
                    .clipShape(.rect(cornerRadius: Design.Radius.md))
            }
        }
        .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.xl)
    }

    // MARK: - Question Flow

    private var questionFlow: some View {
        VStack(spacing: Design.Spacing.lg) {
            // Progress
            VStack(spacing: Design.Spacing.xs) {
                HStack {
                    Text("Question \(currentQuestionIndex + 1) of 9")
                        .font(.caption)
                        .foregroundStyle(Design.Colors.textSecondary)
                    Spacer()
                    Text("\(Int(Double(currentQuestionIndex + 1) / 9.0 * 100))%")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(Design.Colors.primary)
                }

                ProgressView(value: Double(currentQuestionIndex + 1), total: 9)
                    .tint(Design.Colors.primary)
            }

            // Question Text
            Text(questions[currentQuestionIndex])
                .font(.title3)
                .bold()
                .foregroundStyle(Design.Colors.textPrimary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, Design.Spacing.md)
                .animation(Design.Anim.normal, value: currentQuestionIndex)

            // Options
            VStack(spacing: Design.Spacing.sm) {
                ForEach(optionLabels, id: \.1) { label, score in
                    Button {
                        selectAnswer(score)
                    } label: {
                        HStack {
                            Text(label)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundStyle(Design.Colors.textPrimary)
                            Spacer()
                            if answers[currentQuestionIndex] == score {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Design.Colors.primary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 52)
                        .background(answers[currentQuestionIndex] == score ? Design.Colors.primary.opacity(0.20) : Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: Design.Radius.md)
                                .stroke(answers[currentQuestionIndex] == score ? Design.Colors.primary : Color.white.opacity(0.08), lineWidth: 1.5)
                        )
                        .clipShape(.rect(cornerRadius: Design.Radius.md))
                    }
                    .tint(Design.Colors.primary)
                }
            }

            // Navigation Buttons
            HStack {
                if currentQuestionIndex > 0 {
                    Button("Back") {
                        withAnimation(Design.Anim.normal) {
                            currentQuestionIndex -= 1
                        }
                    }
                    .tint(Design.Colors.textSecondary)
                }

                Spacer()

                Button("Cancel") {
                    withAnimation {
                        isTestActive = false
                    }
                }
                .tint(Design.Colors.sos)
            }
            .padding(.top, Design.Spacing.md)
        }
        .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.xl)
    }

    // MARK: - Result Card

    private func resultCard(_ result: SelfAssessmentResult) -> some View {
        VStack(spacing: Design.Spacing.lg) {
            ZStack {
                Circle()
                    .fill(scoreBadgeColor(result.score).opacity(0.15))
                    .frame(width: 80, height: 80)

                VStack(spacing: 0) {
                    Text("\(result.score)")
                        .font(.title)
                        .bold()
                        .foregroundStyle(scoreBadgeColor(result.score))
                    Text("/ 27")
                        .font(.caption2)
                        .foregroundStyle(Design.Colors.textSecondary)
                }
            }

            VStack(spacing: Design.Spacing.xs) {
                Text(result.riskCategory)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(scoreBadgeColor(result.score))

                Text(result.recommendation)
                    .font(.body)
                    .foregroundStyle(Design.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, Design.Spacing.xs)
                    .lineSpacing(3)
            }

            Divider().background(Color.white.opacity(0.12))

            VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                Text("Recommended Next Steps:")
                    .font(.headline)
                    .foregroundStyle(Design.Colors.textPrimary)

                if result.score >= 3 {
                    NavigationLink {
                        HotlineListView()
                    } label: {
                        Label("Call a Gambling Helpline", systemImage: "phone.fill")
                            .font(.subheadline)
                            .foregroundStyle(Design.Colors.textPrimary)
                    }

                    NavigationLink {
                        BreathingExerciseView()
                    } label: {
                        Label("Practice Box Breathing for Urges", systemImage: "lungs.fill")
                            .font(.subheadline)
                            .foregroundStyle(Design.Colors.textPrimary)
                    }
                } else {
                    Text("• Continue logging your daily thoughts and check-ins in your journal.\n• Observe emotional triggers like stress, boredom, or loneliness.\n• Use the SOS interactive tools anytime you experience urges.")
                        .font(.subheadline)
                        .foregroundStyle(Design.Colors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                withAnimation {
                    completedResult = nil
                    isTestActive = false
                }
            } label: {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(Design.Colors.textOnPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Design.Colors.primary)
                    .clipShape(.rect(cornerRadius: Design.Radius.md))
            }
        }
        .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.xl)
    }

    // MARK: - History Section

    private var historySection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            Text("Past Assessment Results")
                .font(.headline)
                .foregroundStyle(Design.Colors.textPrimary)
                .padding(.horizontal, Design.Spacing.xs)

            ForEach(pastResults.prefix(5)) { res in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(res.date, format: .dateTime.day().month().year())
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(Design.Colors.textPrimary)
                        Text(res.riskCategory)
                            .font(.caption)
                            .foregroundStyle(scoreBadgeColor(res.score))
                    }

                    Spacer()

                    Text("\(res.score) Points")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(scoreBadgeColor(res.score))
                }
                .liquidGlass(cornerRadius: Design.Radius.md, padding: Design.Spacing.md)
            }
        }
    }

    // MARK: - Helpers

    private func startNewTest() {
        answers = Array(repeating: -1, count: 9)
        currentQuestionIndex = 0
        completedResult = nil
        withAnimation(Design.Anim.normal) {
            isTestActive = true
        }
    }

    private func selectAnswer(_ score: Int) {
        answers[currentQuestionIndex] = score

        if currentQuestionIndex < 8 {
            withAnimation(Design.Anim.normal) {
                currentQuestionIndex += 1
            }
        } else {
            // Calculate total score
            let total = answers.reduce(0, +)
            let result = SelfAssessmentResult(date: .now, score: total, answers: answers)
            modelContext.insert(result)
            try? modelContext.save()

            withAnimation(Design.Anim.normal) {
                isTestActive = false
                completedResult = result
            }
        }
    }

    private func scoreBadgeColor(_ score: Int) -> Color {
        switch score {
        case 0:
            return Design.Colors.primary
        case 1...2:
            return Design.Colors.gold
        case 3...7:
            return Design.Colors.accent
        default:
            return Design.Colors.sos
        }
    }
}

#Preview {
    NavigationStack {
        SelfAssessmentView()
    }
    .modelContainer(for: SelfAssessmentResult.self, inMemory: true)
}
