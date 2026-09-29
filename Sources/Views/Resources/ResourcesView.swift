import SwiftUI

struct ResourcesView: View {
    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: Design.Spacing.lg) {
                    resourceSection("Self-Assessment & Education") {
                        NavigationLink(destination: SelfAssessmentView()) {
                            resourceNavigationRow(
                                title: "PGSI Self-Assessment",
                                subtitle: "9 clinical screening questions",
                                icon: "doc.text.magnifyingglass",
                                iconColor: Design.Colors.primary
                            )
                        }

                        Divider().background(Color.white.opacity(0.12))

                        NavigationLink(destination: CognitiveDistortionView()) {
                            resourceNavigationRow(
                                title: "Cognitive Distortions",
                                subtitle: "Gambler's fallacy & loss chasing",
                                icon: "brain.head.profile",
                                iconColor: Design.Colors.secondary
                            )
                        }
                    }

                    resourceSection("Emergency Helplines & Immediate Support") {
                        resourceLinkRow(
                            title: "National Problem Gambling Helpline (US)",
                            subtitle: "24/7 Call or Text: 1-800-522-4700",
                            icon: "phone.fill",
                            iconColor: Design.Colors.primary,
                            url: "tel:18005224700"
                        )
                        Divider().background(Color.white.opacity(0.12))
                        resourceLinkRow(
                            title: "988 Crisis Lifeline",
                            subtitle: "24/7 Call or Text: 988",
                            icon: "heart.circle.fill",
                            iconColor: Design.Colors.sos,
                            url: "tel:988"
                        )
                        Divider().background(Color.white.opacity(0.12))
                        resourceLinkRow(
                            title: "SAMHSA Helpline",
                            subtitle: "Free & Confidential: 1-800-662-4357",
                            icon: "cross.case.fill",
                            iconColor: Design.Colors.gold,
                            url: "tel:18006624357"
                        )
                        Divider().background(Color.white.opacity(0.12))
                        resourceLinkRow(
                            title: "Gamblers Anonymous",
                            subtitle: "Online & local peer support meetings",
                            icon: "person.3.fill",
                            iconColor: Design.Colors.secondary,
                            url: "https://www.gamblersanonymous.org"
                        )
                    }

                    resourceSection("International Support Services") {
                        resourceLinkRow(
                            title: "BIÖG Gambling Helpline",
                            subtitle: "0800 1 37 27 00 • Free in Germany",
                            icon: "phone.circle.fill",
                            iconColor: Design.Colors.primary,
                            url: "tel:08001372700"
                        )
                        Divider().background(Color.white.opacity(0.12))
                        resourceLinkRow(
                            title: "Telefonseelsorge Crisis Line (24/7)",
                            subtitle: "0800 111 0 111 • 24/7 Confidential",
                            icon: "phone.fill",
                            iconColor: Design.Colors.sos,
                            url: "tel:08001110111"
                        )
                        Divider().background(Color.white.opacity(0.12))
                        resourceLinkRow(
                            title: "UK GamCare Helpline",
                            subtitle: "0808 8020 133 • National Helpline UK",
                            icon: "globe.europe.africa.fill",
                            iconColor: Design.Colors.secondary,
                            url: "tel:08088020133"
                        )
                        Divider().background(Color.white.opacity(0.12))
                        resourceLinkRow(
                            title: "AU Gambling Help",
                            subtitle: "1800 858 858 • Australia & Oceania",
                            icon: "globe.asia.australia.fill",
                            iconColor: Design.Colors.gold,
                            url: "tel:1800858858"
                        )
                        Divider().background(Color.white.opacity(0.12))
                        resourceLinkRow(
                            title: "OASIS Self-Exclusion Registry",
                            subtitle: "Official nationwide gambling exclusion",
                            icon: "shield.fill",
                            iconColor: Design.Colors.primary,
                            url: "https://rp-darmstadt.hessen.de"
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, Design.Spacing.md)
                .padding(.bottom, 96)
            }
        }
        .navigationTitle("Help & Resources")
    }

    private func resourceSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(Design.Colors.gold)
                .padding(.leading, 8)
                .lineLimit(1)

            VStack(spacing: Design.Spacing.md) {
                content()
            }
            .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.md)
        }
    }

    private func resourceNavigationRow(title: String, subtitle: String, icon: String, iconColor: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Design.Colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Design.Colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Spacer(minLength: 4)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Design.Colors.textTertiary)
        }
    }

    private func resourceLinkRow(title: String, subtitle: String? = nil, icon: String, iconColor: Color, url: String) -> some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(iconColor)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(Design.Colors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Design.Colors.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                }

                Spacer(minLength: 4)

                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(Design.Colors.textTertiary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ResourcesView()
    }
}
