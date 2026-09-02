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
        "Haben Sie mit höheren Beträgen gespielt, als Sie sich leisten konnten zu verlieren?",
        "Mussten Sie mit immer größeren Geldbeträgen spielen, um die gleiche Spannung zu empfinden?",
        "Sind Sie an einem anderen Tag zurückgekehrt, um verlorenes Geld zurückzugewinnen (Verlustjagd)?",
        "Haben Sie sich Geld geliehen oder etwas verkauft, um Geld zum Spielen zu haben?",
        "Hatten Sie das Gefühl, dass Sie möglicherweise ein Problem mit dem Glücksspiel haben könnten?",
        "Hat das Glücksspiel bei Ihnen zu gesundheitlichen Problemen geführt (wie Stress oder Schlafprobleme)?",
        "Haben andere Menschen Ihr Spielverhalten kritisiert oder Ihnen gesagt, dass Sie ein Spielproblem haben?",
        "Hat Ihr Spielverhalten finanzielle Probleme für Sie oder Ihren Haushalt verursacht?",
        "Hatten Sie Schuldgefühle wegen der Art und Weise, wie Sie spielen, oder wegen der Folgen des Spielens?"
    ]

    private let optionLabels = [
        ("Nie", 0),
        ("Manchmal", 1),
        ("Oft", 2),
        ("Fast immer", 3)
    ]

    var body: some View {
        ScrollView {
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
        }
        .navigationTitle("PGSI Selbsttest")
        .background(Design.Colors.background)
    }

    // MARK: - Intro Card

    private var introCard: some View {
        VStack(spacing: Design.Spacing.lg) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(Design.Colors.primary)

            VStack(spacing: Design.Spacing.sm) {
                Text("Problem Gambling Severity Index (PGSI)")
                    .font(.title3)
                    .bold()
                    .multilineTextAlignment(.center)

                Text("Der PGSI ist ein international anerkannter klinischer Screening-Fragebogen mit 9 Fragen zur objektiven Einschätzung des eigenen Spielverhaltens in den letzten 12 Monaten.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            VStack(alignment: .leading, spacing: Design.Spacing.xs) {
                Label("Dauert nur 2–3 Minuten", systemImage: "clock.fill")
                Label("100% anonym & lokal gespeichert", systemImage: "lock.shield.fill")
                Label("Wissenschaftlich validiert", systemImage: "checkmark.seal.fill")
            }
            .font(.caption)
            .foregroundStyle(Design.Colors.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Design.Spacing.md)
            .background(Design.Colors.background)
            .clipShape(.rect(cornerRadius: Design.Radius.md))

            Button {
                startNewTest()
            } label: {
                Text("Test jetzt starten")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Design.Colors.primary)
                    .clipShape(.rect(cornerRadius: Design.Radius.md))
            }
        }
        .padding(Design.Spacing.xl)
        .background(Design.Colors.surface)
        .clipShape(.rect(cornerRadius: Design.Radius.lg))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
    }

    // MARK: - Question Flow

    private var questionFlow: some View {
        VStack(spacing: Design.Spacing.lg) {
            // Progress
            VStack(spacing: Design.Spacing.xs) {
                HStack {
                    Text("Frage \(currentQuestionIndex + 1) von 9")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
                            Spacer()
                            if answers[currentQuestionIndex] == score {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Design.Colors.primary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 52)
                        .background(answers[currentQuestionIndex] == score ? Design.Colors.primary.opacity(0.12) : Design.Colors.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: Design.Radius.md)
                                .stroke(answers[currentQuestionIndex] == score ? Design.Colors.primary : Color.clear, lineWidth: 1.5)
                        )
                        .clipShape(.rect(cornerRadius: Design.Radius.md))
                    }
                    .tint(Design.Colors.primary)
                }
            }

            // Navigation Buttons
            HStack {
                if currentQuestionIndex > 0 {
                    Button("Zurück") {
                        withAnimation(Design.Anim.normal) {
                            currentQuestionIndex -= 1
                        }
                    }
                    .tint(.secondary)
                }

                Spacer()

                Button("Abbrechen") {
                    withAnimation {
                        isTestActive = false
                    }
                }
                .tint(Design.Colors.sos)
            }
            .padding(.top, Design.Spacing.md)
        }
        .padding(Design.Spacing.xl)
        .background(Design.Colors.surface)
        .clipShape(.rect(cornerRadius: Design.Radius.lg))
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
                        .foregroundStyle(.secondary)
                }
            }

            VStack(spacing: Design.Spacing.xs) {
                Text(result.riskCategory)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(scoreBadgeColor(result.score))

                Text(result.recommendation)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, Design.Spacing.xs)
                    .lineSpacing(3)
            }

            Divider()

            VStack(alignment: .leading, spacing: Design.Spacing.sm) {
                Text("Empfohlene nächste Schritte:")
                    .font(.headline)

                if result.score >= 3 {
                    NavigationLink {
                        HotlineListView()
                    } label: {
                        Label("Kostenlose BZgA-Hotline anrufen (0800 1 37 27 00)", systemImage: "phone.fill")
                            .font(.subheadline)
                    }

                    NavigationLink {
                        BreathingExerciseView()
                    } label: {
                        Label("Atemübung bei Spieldruck durchführen", systemImage: "lungs.fill")
                            .font(.subheadline)
                    }
                } else {
                    Text("• Führe weiterhin regelmäßig dein Tagebuch.\n• Beobachte emotionale Auslöser wie Stress oder Langeweile.\n• Nutze bei Bedarf jederzeit die Übungen im SOS-Bereich.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                withAnimation {
                    completedResult = nil
                    isTestActive = false
                }
            } label: {
                Text("Fertig")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Design.Colors.primary)
                    .clipShape(.rect(cornerRadius: Design.Radius.md))
            }
        }
        .padding(Design.Spacing.xl)
        .background(Design.Colors.surface)
        .clipShape(.rect(cornerRadius: Design.Radius.lg))
    }

    // MARK: - History Section

    private var historySection: some View {
        VStack(alignment: .leading, spacing: Design.Spacing.sm) {
            Text("Vergangene Testergebnisse")
                .font(.headline)
                .padding(.horizontal, Design.Spacing.xs)

            ForEach(pastResults.prefix(5)) { res in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(res.date, format: .dateTime.day().month().year())
                            .font(.subheadline)
                            .bold()
                        Text(res.riskCategory)
                            .font(.caption)
                            .foregroundStyle(scoreBadgeColor(res.score))
                    }

                    Spacer()

                    Text("\(res.score) Punkte")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(scoreBadgeColor(res.score))
                }
                .padding(Design.Spacing.md)
                .background(Design.Colors.surface)
                .clipShape(.rect(cornerRadius: Design.Radius.md))
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
