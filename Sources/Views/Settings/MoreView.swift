import SwiftUI

enum MoreRoute: String, Hashable {
    case settings
    case clinicalReport
    case journal
    case finances
    case assessment
    case resources
    case paywall
}

struct MoreView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager: SubscriptionManager?
    @State private var showingPaywall: Bool = false
    @Binding var navigationPath: NavigationPath

    init(navigationPath: Binding<NavigationPath> = .constant(NavigationPath())) {
        self._navigationPath = navigationPath
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                FlutedGlassBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Design.Spacing.lg) {
                        // Pro Hero Card
                        Button {
                            SensoryFeedbackService.shared.cardTap()
                            showingPaywall = true
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(subscriptionManager?.isPro == true ? Color.green.opacity(0.18) : Design.Colors.champagne.opacity(0.22))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: subscriptionManager?.isPro == true ? "checkmark.seal.fill" : "sparkles")
                                        .font(.title3)
                                        .foregroundStyle(subscriptionManager?.isPro == true ? Color.green : Design.Colors.champagne)
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    HStack {
                                        Text("Quit Gambling Pro".loc)
                                            .font(.headline)
                                            .foregroundStyle(Design.Colors.textPrimary)
                                        if subscriptionManager?.isPro == true {
                                            Text("ACTIVE".loc)
                                                .font(.system(size: 9, weight: .bold))
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.green)
                                                .clipShape(Capsule())
                                        } else {
                                            Text("PRO".loc)
                                                .font(.system(size: 9, weight: .bold))
                                                .foregroundStyle(.black)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Design.Colors.champagne)
                                                .clipShape(Capsule())
                                        }
                                    }
                                    Text(subscriptionManager?.isPro == true ? "All 10 Pro features unlocked".loc : "DNS shield, stealth & analytics".loc)
                                        .font(.caption)
                                        .foregroundStyle(Design.Colors.textSecondary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.75)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Design.Colors.textTertiary)
                            }
                            .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.md)
                        }
                        .buttonStyle(.plain)

                        // Section: Reflection & Finances
                        moreSection("Reflection & Finances".loc) {
                            Button {
                                SensoryFeedbackService.shared.selectionClick()
                                navigationPath.append(MoreRoute.journal)
                            } label: {
                                moreRow(title: "Journal & Reflections".loc, icon: "book.fill", iconColor: Design.Colors.gold)
                            }
                            .buttonStyle(.plain)

                            Divider().background(Color.white.opacity(0.12))

                            Button {
                                SensoryFeedbackService.shared.selectionClick()
                                navigationPath.append(MoreRoute.finances)
                            } label: {
                                moreRow(title: "Finances & Savings Goals".loc, icon: "banknote.fill", iconColor: Color.white)
                            }
                            .buttonStyle(.plain)
                        }

                        // Section: Clinical & Support
                        moreSection("Clinical & Support".loc) {
                            Button {
                                SensoryFeedbackService.shared.selectionClick()
                                navigationPath.append(MoreRoute.clinicalReport)
                            } label: {
                                moreRow(
                                    title: "Clinical Report".loc,
                                    icon: "cross.case.fill",
                                    iconColor: Design.Colors.primary,
                                    showProBadge: subscriptionManager?.isPro != true
                                )
                            }
                            .buttonStyle(.plain)

                            Divider().background(Color.white.opacity(0.12))

                            Button {
                                SensoryFeedbackService.shared.selectionClick()
                                navigationPath.append(MoreRoute.assessment)
                            } label: {
                                moreRow(title: "PGSI Self-Assessment (9 Questions)".loc, icon: "doc.text.magnifyingglass", iconColor: Design.Colors.gold)
                            }
                            .buttonStyle(.plain)

                            Divider().background(Color.white.opacity(0.12))

                            Button {
                                SensoryFeedbackService.shared.selectionClick()
                                navigationPath.append(MoreRoute.resources)
                            } label: {
                                moreRow(title: "Helplines & Support Resources".loc, icon: "lifepreserver.fill", iconColor: Design.Colors.secondary)
                            }
                            .buttonStyle(.plain)
                        }

                        // Section: App
                        moreSection("App".loc) {
                            Button {
                                SensoryFeedbackService.shared.selectionClick()
                                navigationPath.append(MoreRoute.settings)
                            } label: {
                                moreRow(title: "Settings & Privacy".loc, icon: "gearshape.fill", iconColor: Design.Colors.textSecondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, Design.Spacing.md)
                    .padding(.bottom, 96)
                }
            }
            .navigationTitle("More".loc)
            .navigationDestination(for: MoreRoute.self) { route in
                switch route {
                case .settings:
                    SettingsView()
                case .clinicalReport:
                    ClinicalReportView()
                case .journal:
                    JournalView()
                case .finances:
                    FinanceView()
                case .assessment:
                    SelfAssessmentView()
                case .resources:
                    ResourcesView()
                case .paywall:
                    PaywallView()
                        .ignoresSafeArea()
                }
            }
            .fullScreenCover(isPresented: $showingPaywall) {
                PaywallView()
            }
            .onOpenURL { url in
                #if DEBUG
                if url.scheme == "quitgambling" {
                    if url.host == "open-settings" || url.host == "open-themes" {
                        navigationPath = NavigationPath([MoreRoute.settings])
                    } else if url.host == "open-clinical-report" {
                        navigationPath = NavigationPath([MoreRoute.clinicalReport])
                    } else if url.host == "open-paywall" || url.absoluteString.contains("paywall") {
                        showingPaywall = true
                    } else if url.host == "open-promocode-sheet" {
                        showingPaywall = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            NotificationCenter.default.post(name: NSNotification.Name("OpenPromoCodeSheet"), object: nil)
                        }
                    }
                }
                #endif
            }
        }
    }

    private func moreSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(Design.Colors.gold)
                .padding(.leading, 8)

            VStack(spacing: Design.Spacing.md) {
                content()
            }
            .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.md)
        }
    }

    private func moreRow(title: String, icon: String, iconColor: Color, showProBadge: Bool = false) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(iconColor)
                .frame(width: 24)

            Text(title)
                .font(.body)
                .foregroundStyle(Design.Colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            if showProBadge {
                ProBadge(isCompact: true)
            }

            Spacer(minLength: 4)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Design.Colors.textTertiary)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    MoreView()
        .environment(ShieldManager())
}
