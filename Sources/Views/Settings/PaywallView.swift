import SwiftUI
import StoreKit

/// Apple Craftsmanship Paywall for Quit Gambling Pro.
/// Crystal-clear hierarchy: instant value recognition, prominent side-by-side pricing, and high-converting purchase CTA.
struct PaywallView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPackageId: String = "annual"
    @State private var isPurchasing: Bool = false
    @State private var alertMessage: String? = nil
    @State private var showAlert: Bool = false
    @State private var showAllFeaturesSheet: Bool = false
    @State private var showPromoCodeSheet: Bool = false

    // 4 High-Impact Pillars shown directly on the screen
    private let corePillars: [(icon: String, title: String, detail: String)] = [
        ("shield.checkered", "System-Wide DNS Shield", "Block 525,000+ gambling domains in all apps"),
        ("location.fill", "Smart Danger Radar", "Proximity alerts when near casinos & venues"),
        ("eye.slash.fill", "Stealth Camouflage & Vault", "Shake-to-hide disguise & biometric lock"),
        ("chart.bar.fill", "Clinical Report & Trends", "Deep recovery analytics & doctor PDF export")
    ]

    // Complete breakdown of all 10 Pro features for the detailed sheet
    private let allFeatures: [(icon: String, title: String, subtitle: String)] = [
        ("shield.checkered", "System-Wide DNS Protection", "Block 525,000+ gambling & betting sites in Safari, Chrome & all apps — 100% without extensions."),
        ("location.fill", "Unlimited Danger Zones", "Automatic geofencing alerts with dwell-time filtering for custom casino & arcade locations."),
        ("eye.slash.fill", "Stealth Camouflage & Disguise", "Realistic Calculator & Notes disguise modes with shake-to-hide and custom PIN protection."),
        ("app.badge.checkmark", "Discreet Homescreen Icons", "Camouflage the app icon on your iPhone home screen as a generic utility."),
        ("lock.shield.fill", "Biometric App Vault", "Instant Face ID / Passcode lock when leaving the app to keep your recovery strictly private."),
        ("banknote.fill", "Unlimited Financial Goals", "Set multiple parallel debt payoff and savings targets funded by your clean days."),
        ("cart.fill", "Tangible Purchasing Power", "Real-world conversions translating your savings into reclaimed essentials and life experiences."),
        ("paintpalette.fill", "Exclusive Visual Themes", "Unlock all luminous colorways, bespoke palettes & aesthetic visual styles."),
        ("chart.bar.fill", "Urge & Trigger Analytics", "Insightful trigger distributions, urge intensity curves, and mood trends over time."),
        ("doc.text.fill", "Export Report for Doctor", "Export a structured, professional recovery report of clean days, savings & urges for therapy or OASIS.")
    ]

    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Navigation Bar: Restore & Close
                HStack {
                    Button("Restore".loc) {
                        handleRestore()
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Design.Colors.textSecondary)

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Design.Colors.textPrimary)
                            .frame(width: 32, height: 32)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, Design.Spacing.lg)
                .padding(.top, 6)
                .padding(.bottom, 2)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        // 1. Hero Crown & Title
                        VStack(spacing: 5) {
                            ZStack {
                                if subscriptionManager.isPro {
                                    Circle()
                                        .fill(Color.green.opacity(0.18))
                                        .frame(width: 46, height: 46)
                                        .blur(radius: 10)
                                        .opacity(0.5)
                                } else {
                                    Circle()
                                        .fill(Design.Colors.goldGradient)
                                        .frame(width: 46, height: 46)
                                        .blur(radius: 10)
                                        .opacity(0.5)
                                }

                                Image(systemName: subscriptionManager.isPro ? "checkmark.seal.fill" : "crown.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(subscriptionManager.isPro ? Color.green : Design.Colors.champagne)
                            }
                            .padding(.top, 2)

                            Text(subscriptionManager.isPro ? "Pro Membership Active".loc : "Quit Gambling Pro".loc)
                                .font(.system(size: 23, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white)

                            Text(subscriptionManager.isPro ? "All 10 professional recovery features are active.".loc : "Reclaim your peace of mind with total protection.".loc)
                                .font(.system(size: 12))
                                .foregroundStyle(Design.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Design.Spacing.md)
                        }

                        // 2. Core 4 Value Pillars (Compact, 1-line each)
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(corePillars, id: \.title) { pillar in
                                HStack(spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .fill(Design.Colors.champagne.opacity(0.15))
                                            .frame(width: 26, height: 26)
                                        Image(systemName: pillar.icon)
                                            .font(.system(size: 11.5, weight: .semibold))
                                            .foregroundStyle(Design.Colors.champagne)
                                    }

                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(pillar.title.loc)
                                            .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                                            .foregroundStyle(Color.white)
                                        Text(pillar.detail.loc)
                                            .font(.system(size: 10.5))
                                            .foregroundStyle(Design.Colors.textSecondary)
                                    }

                                    Spacer()

                                    Image(systemName: "checkmark")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(Design.Colors.signalGreen)
                                }
                            }

                            // "See all 10 features" button
                            Button {
                                showAllFeaturesSheet = true
                            } label: {
                                HStack(spacing: 4) {
                                    Text("See all 10 included features".loc)
                                        .font(.system(size: 11.5, weight: .semibold))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 9.5, weight: .bold))
                                }
                                .foregroundStyle(Design.Colors.champagne)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 2)
                            }
                        }
                        .liquidGlass(cornerRadius: Design.Radius.card, padding: 12)
                        .padding(.horizontal, Design.Spacing.md)

                        if subscriptionManager.isPro {
                            // Active Pro State - Purchasing is blocked
                            VStack(spacing: Design.Spacing.sm) {
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(Color.green)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Subscription Active".loc)
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundStyle(Color.white)
                                        Text("All Pro features unlocked".loc)
                                            .font(.caption)
                                            .foregroundStyle(Design.Colors.textSecondary)
                                    }

                                    Spacer()

                                    Text("ACTIVE".loc)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.green)
                                        .clipShape(Capsule())
                                }
                                .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.md)

                                Link(destination: URL(string: "https://apps.apple.com/account/subscriptions")!) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "apple.logo")
                                        Text("Manage Subscription in App Store".loc)
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        Image(systemName: "arrow.up.forward.app")
                                            .font(.caption.weight(.bold))
                                    }
                                    .foregroundStyle(Color.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color.white.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)

                                Text("Modify or cancel your plan at any time in Apple Settings".loc)
                                    .font(.caption2)
                                    .foregroundStyle(Design.Colors.textTertiary)
                            }
                            .padding(.horizontal, Design.Spacing.md)
                        } else {
                            // 3. Plan Selection (Side-by-side + Lifetime Banner)
                            VStack(spacing: 8) {
                                HStack(spacing: 10) {
                                    // Annual Plan (Featured)
                                    planSelectionCard(
                                        id: "annual",
                                        badge: "SAVE 50%".loc,
                                        title: "Annual".loc,
                                        price: annualMonthlyBreakdown,
                                        period: annualPeriodString
                                    )

                                    // Monthly Plan
                                    planSelectionCard(
                                        id: "monthly",
                                        badge: "FLEXIBLE".loc,
                                        title: "Monthly".loc,
                                        price: monthlyPriceString,
                                        period: monthlyPeriodString
                                    )
                                }

                                // Lifetime Plan (One-Time)
                                lifetimeSelectionCard(
                                    badge: "ONE-TIME".loc,
                                    title: "Lifetime".loc,
                                    subtitle: "Protected forever".loc
                                )
                            }
                            .padding(.horizontal, Design.Spacing.md)

                            // 4. Primary Purchase Action Button & Promocode Button
                            VStack(spacing: 8) {
                                Button {
                                    handlePurchase()
                                } label: {
                                    HStack(spacing: 8) {
                                        if isPurchasing {
                                            ProgressView()
                                                .tint(.black)
                                        } else {
                                            Text(purchaseCtaText)
                                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                            Image(systemName: "arrow.right")
                                                .font(.system(size: 13, weight: .bold))
                                        }
                                    }
                                    .foregroundStyle(Color.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(
                                        LinearGradient(
                                            colors: [Color(red: 1.0, green: 0.88, blue: 0.5), Color(red: 0.95, green: 0.72, blue: 0.25)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .contentShape(RoundedRectangle(cornerRadius: 15))
                                    .shadow(color: Color(red: 0.95, green: 0.72, blue: 0.25).opacity(0.35), radius: 10, y: 4)
                                }
                                .disabled(isPurchasing)
                                .buttonStyle(PaywallPressableButtonStyle())

                                // Promocode Button - sleek gray with tactile press and 100% full hit shape
                                Button {
                                    SensoryFeedbackService.shared.selectionClick()
                                    showPromoCodeSheet = true
                                } label: {
                                    Text("Promocode eingeben".loc)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color.white.opacity(0.85))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(Color.white.opacity(0.10))
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .contentShape(RoundedRectangle(cornerRadius: 14))
                                }
                                .buttonStyle(PaywallPressableButtonStyle())

                                Text("No commitment • Cancel anytime in App Store".loc)
                                    .font(.system(size: 10.5))
                                    .foregroundStyle(Design.Colors.textTertiary)
                            }
                            .padding(.horizontal, Design.Spacing.md)
                            .padding(.top, 2)
                        }

                        // 5. Legal
                        VStack(spacing: 6) {
                            HStack(spacing: Design.Spacing.md) {
                                Link("Privacy Policy".loc, destination: URL(string: "https://quitgambling.app/privacy")!)
                                    .font(.system(size: 10.5))
                                    .foregroundStyle(Design.Colors.textTertiary)

                                Text("•")
                                    .font(.system(size: 10.5))
                                    .foregroundStyle(Design.Colors.textTertiary)

                                Link("Terms of Service".loc, destination: URL(string: "https://quitgambling.app/terms")!)
                                    .font(.system(size: 10.5))
                                    .foregroundStyle(Design.Colors.textTertiary)
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
                .smoothTopScrollFade(fadeLength: 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showAllFeaturesSheet) {
            AllFeaturesDetailSheet(features: allFeatures)
        }
        .sheet(isPresented: $showPromoCodeSheet) {
            PromoCodeSheetView(manager: subscriptionManager) {
                dismiss()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenPromoCodeSheet"))) { _ in
            showPromoCodeSheet = true
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Quit Gambling Pro"),
                message: Text(alertMessage ?? ""),
                dismissButton: .default(Text("OK")) {
                    if subscriptionManager.isPro {
                        dismiss()
                    }
                }
            )
        }
        .task {
            await subscriptionManager.loadProducts()
        }
    }

    // MARK: - Plan Selection Card Helper

    private func planSelectionCard(id: String, badge: String, title: String, price: String, period: String) -> some View {
        let isSelected = selectedPackageId == id

        return Button {
            SensoryFeedbackService.shared.selectionClick()
            selectedPackageId = id
        } label: {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(badge)
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(id == "annual" ? Design.Colors.signalGreen : Design.Colors.textSecondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(id == "annual" ? Design.Colors.signalGreen.opacity(0.18) : Color.white.opacity(0.1))
                        .clipShape(Capsule())

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 17))
                        .foregroundStyle(isSelected ? Color(red: 1.0, green: 0.85, blue: 0.4) : Design.Colors.textTertiary)
                }

                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white)

                Text(price)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)

                Text(period)
                    .font(.system(size: 10))
                    .foregroundStyle(Design.Colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .padding(Design.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Design.Radius.card)
                    .fill(isSelected ? Color.white.opacity(0.08) : Color.white.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Design.Radius.card)
                    .strokeBorder(
                        isSelected ? Color(red: 1.0, green: 0.85, blue: 0.4) : Color.white.opacity(0.12),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: isSelected ? Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.2) : Color.clear, radius: 8, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Lifetime Selection Card Helper

    private func lifetimeSelectionCard(badge: String, title: String, subtitle: String) -> some View {
        let isSelected = selectedPackageId == "lifetime"

        return Button {
            SensoryFeedbackService.shared.selectionClick()
            selectedPackageId = "lifetime"
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.18) : Color.white.opacity(0.08))
                        .frame(width: 36, height: 36)

                    Image(systemName: "infinity")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(isSelected ? Color(red: 1.0, green: 0.85, blue: 0.4) : Design.Colors.champagne)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white)

                        Text(badge)
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 1.0, green: 0.85, blue: 0.4))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.18))
                            .clipShape(Capsule())
                    }

                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(Design.Colors.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(lifetimeOnlyPriceString)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)

                    Text("one-time".loc)
                        .font(.system(size: 10))
                        .foregroundStyle(Design.Colors.textSecondary)
                }

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 17))
                    .foregroundStyle(isSelected ? Color(red: 1.0, green: 0.85, blue: 0.4) : Design.Colors.textTertiary)
            }
            .padding(.horizontal, Design.Spacing.md)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: Design.Radius.card)
                    .fill(isSelected ? Color.white.opacity(0.08) : Color.white.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Design.Radius.card)
                    .strokeBorder(
                        isSelected ? Color(red: 1.0, green: 0.85, blue: 0.4) : Color.white.opacity(0.12),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: isSelected ? Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.2) : Color.clear, radius: 8, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Dynamic Products & Pricing

    private var annualProduct: Product? {
        subscriptionManager.annualProduct
    }

    private var monthlyProduct: Product? {
        subscriptionManager.monthlyProduct
    }

    private var lifetimeProduct: Product? {
        subscriptionManager.lifetimeProduct
    }

    private var annualMonthlyBreakdown: String {
        if let product = annualProduct {
            let monthly = (product.price as NSDecimalNumber).doubleValue / 12.0
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale.current
            let str = formatter.string(from: NSNumber(value: monthly)) ?? String(format: "%.2f €", monthly)
            return "\(str) / \("mo".loc)"
        }
        return "2,50 € / \("mo".loc)"
    }

    private var annualPeriodString: String {
        if let product = annualProduct {
            return "\(product.displayPrice) \("billed yearly".loc)"
        }
        return "29,99 € \("billed yearly".loc)"
    }

    private var monthlyPriceString: String {
        if let product = monthlyProduct {
            return "\(product.displayPrice) / \("mo".loc)"
        }
        return "4,99 € / \("mo".loc)"
    }

    private var monthlyPeriodString: String {
        "Billed monthly".loc
    }

    private var lifetimePriceString: String {
        if let product = lifetimeProduct {
            return "\(product.displayPrice) \("one-time".loc)"
        }
        return "49,99 € \("one-time".loc)"
    }

    private var lifetimeOnlyPriceString: String {
        if let product = lifetimeProduct {
            return product.displayPrice
        }
        return "49,99 €"
    }

    private var purchaseCtaText: String {
        if selectedPackageId == "annual" {
            return "\("Start Annual".loc) • \(annualMonthlyBreakdown)"
        } else if selectedPackageId == "monthly" {
            return "\("Start Monthly".loc) • \(monthlyPriceString)"
        } else {
            return "\("Get Lifetime".loc) • \(lifetimePriceString)"
        }
    }

    // MARK: - Actions

    private func handlePurchase() {
        guard !subscriptionManager.isPro else { return }
        isPurchasing = true
        SensoryFeedbackService.shared.selectionClick()

        Task {
            let productId: String
            switch selectedPackageId {
            case "annual": productId = SubscriptionManager.yearlyId
            case "monthly": productId = SubscriptionManager.monthlyId
            case "lifetime": productId = SubscriptionManager.lifetimeId
            default: productId = SubscriptionManager.yearlyId
            }

            do {
                let success = try await subscriptionManager.purchase(productId: productId)
                if success {
                    SensoryFeedbackService.shared.successFeedback()
                    alertMessage = "Welcome to Quit Gambling Pro. All features are now unlocked.".loc
                    showAlert = true
                }
            } catch {
                SensoryFeedbackService.shared.errorFeedback()
                alertMessage = String(format: "%@: %@", "Unable to complete purchase".loc, error.localizedDescription)
                showAlert = true
            }
            isPurchasing = false
        }
    }

    private func handleRestore() {
        isPurchasing = true
        SensoryFeedbackService.shared.selectionClick()
        Task {
            do {
                let restored = try await subscriptionManager.restorePurchases()
                if restored {
                    SensoryFeedbackService.shared.successFeedback()
                    alertMessage = "Purchases successfully restored.".loc
                } else {
                    SensoryFeedbackService.shared.selectionClick()
                    alertMessage = "No active subscriptions found.".loc
                }
            } catch {
                SensoryFeedbackService.shared.errorFeedback()
                alertMessage = String(format: "%@: %@", "Restore failed".loc, error.localizedDescription)
            }
            showAlert = true
            isPurchasing = false
        }
    }
}

// MARK: - All Features Detail Sheet

private struct AllFeaturesDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let features: [(icon: String, title: String, subtitle: String)]

    var body: some View {
        NavigationStack {
            ZStack {
                FlutedGlassBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Design.Spacing.md) {
                        ForEach(features, id: \.title) { feature in
                            HStack(alignment: .top, spacing: Design.Spacing.md) {
                                Image(systemName: feature.icon)
                                    .font(.system(size: 16))
                                    .foregroundStyle(Design.Colors.gold)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(feature.title)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color.white)
                                    Text(feature.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(Design.Colors.textSecondary)
                                        .lineSpacing(2)
                                }
                            }
                            .padding(.vertical, 4)

                            if feature.title != features.last?.title {
                                Divider().background(Color.white.opacity(0.08))
                            }
                        }
                    }
                    .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.lg)
                    .padding(.horizontal, Design.Spacing.md)
                    .padding(.vertical, Design.Spacing.md)
                }
            }
            .navigationTitle("All 10 Pro Features")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundStyle(Design.Colors.champagne)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Promo Code Redemption Sheet

// MARK: - Pressable Button Style with Spring Tactile Feedback

struct PaywallPressableButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.82 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Promo Code Redemption Sheet

private struct PromoCodeSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionManager.self) private var subscriptionManagerEnv: SubscriptionManager?
    var manager: SubscriptionManager? = nil
    var onRedeemed: () -> Void

    @State private var codeInput: String = ""
    @State private var errorMessage: String? = nil
    @State private var isSuccess: Bool = false
    @FocusState private var isFieldFocused: Bool

    private var activeManager: SubscriptionManager? {
        manager ?? subscriptionManagerEnv
    }

    private var isCodeEmpty: Bool {
        codeInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header: Nike-style Title + Dismiss
            HStack {
                Text("Hast du einen Promocode?".loc)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Design.Colors.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                }
                .buttonStyle(PaywallPressableButtonStyle())
            }
            .padding(.top, 2)

            // Nike Outlined Textfield with Notch Label
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        errorMessage != nil ? Color.red.opacity(0.85) :
                        (isFieldFocused ? Color.white.opacity(0.85) : Color.white.opacity(0.22)),
                        lineWidth: isFieldFocused ? 1.5 : 1
                    )
                    .frame(height: 50)

                // Notch label: "Promocode"
                HStack {
                    Text("Promocode".loc)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(errorMessage != nil ? Color.red : (isFieldFocused ? Color.white : Design.Colors.textSecondary))
                        .padding(.horizontal, 4)
                        .background(Color(red: 0.11, green: 0.11, blue: 0.13))
                        .padding(.leading, 12)
                    Spacer()
                }
                .offset(y: -25)

                // Input Field & Clear Button
                HStack(spacing: 8) {
                    TextField("", text: $codeInput, prompt: Text("Promocode").foregroundStyle(Color.white.opacity(0.32)))
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.white)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .focused($isFieldFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            if !isCodeEmpty {
                                redeem()
                            }
                        }

                    if !codeInput.isEmpty {
                        Button {
                            codeInput = ""
                            errorMessage = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color.white.opacity(0.4))
                                .font(.system(size: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }

            // Nike Capsule Action Button & Status (Directly above keyboard)
            HStack(spacing: 12) {
                Button {
                    redeem()
                } label: {
                    Text("Anwenden".loc)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(isCodeEmpty ? Color.white.opacity(0.35) : Color.black)
                        .padding(.horizontal, 26)
                        .frame(height: 40)
                        .background(isCodeEmpty ? Color.white.opacity(0.12) : Color.white)
                        .clipShape(Capsule())
                }
                .disabled(isCodeEmpty)
                .buttonStyle(PaywallPressableButtonStyle())

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption2)
                        .foregroundStyle(Color.red)
                } else if isSuccess {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.green)
                            .font(.system(size: 12))
                        Text("Promocode angewendet!".loc)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(Color.green)
                    }
                }

                Spacer()
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(Color(red: 0.11, green: 0.11, blue: 0.13).ignoresSafeArea())
        .presentationDetents([.height(152)])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(22)
        .presentationBackground(Color(red: 0.11, green: 0.11, blue: 0.13))
        .preferredColorScheme(.dark)
        .onAppear {
            isFieldFocused = true
        }
    }

    private func redeem() {
        errorMessage = nil
        guard let subManager = activeManager else {
            errorMessage = "Fehler: SubscriptionManager nicht verfügbar".loc
            return
        }
        let success = subManager.unlockWithPromoCode(codeInput)
        if success {
            SensoryFeedbackService.shared.successFeedback()
            isSuccess = true
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(700))
                dismiss()
                onRedeemed()
            }
        } else {
            SensoryFeedbackService.shared.errorFeedback()
            errorMessage = "Ungültiger Promocode".loc
        }
    }
}

#Preview {
    PaywallView()
        .environment(SubscriptionManager())
}
