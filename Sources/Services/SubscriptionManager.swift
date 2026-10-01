import SwiftUI
import RevenueCat

/// Service managing RevenueCat in-app subscriptions, entitlements, and paywall offerings for Quit Gambling Pro.
@Observable
@MainActor
final class SubscriptionManager: NSObject, PurchasesDelegate {

    // MARK: - State Properties

    var isPro: Bool = false
    var currentOffering: Offering? = nil
    var isLoading: Bool = false
    var errorMessage: String? = nil

    // RevenueCat Public API Key (App-specific Apple key starting with 'appl_')
    static var apiKey: String {
        get {
            UserDefaults.standard.string(forKey: "revenuecat_public_api_key") ?? defaultApiKey
        }
        set {
            let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            UserDefaults.standard.set(trimmed, forKey: "revenuecat_public_api_key")
        }
    }

    static let defaultApiKey = "appl_demo_quitgambling_shipathon"

    override init() {
        super.init()
        let isDirectPro = UserDefaults.standard.bool(forKey: "isProSubscribed")
        let isPromo = UserDefaults.standard.bool(forKey: "isPromoProUnlocked")
        self.isPro = isDirectPro || isPromo
    }

    // MARK: - Configuration Lifecycle

    static func configure() {
        #if DEBUG
        Purchases.logLevel = .debug
        #else
        Purchases.logLevel = .warn
        #endif
        Purchases.configure(withAPIKey: apiKey)
    }

    func attachDelegate() {
        if Purchases.isConfigured {
            Purchases.shared.delegate = self
        }
    }

    // MARK: - PurchasesDelegate

    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            self.handleCustomerInfo(customerInfo)
        }
    }

    func updateCustomerStatus() async {
        guard Purchases.isConfigured else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            handleCustomerInfo(customerInfo)
        } catch {
            // Keep local state if offline
            print("RevenueCat customerInfo fetch: \(error.localizedDescription)")
        }
    }

    func fetchOfferings() async {
        guard Purchases.isConfigured else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let offerings = try await Purchases.shared.offerings()
            self.currentOffering = offerings.current
            print("RevenueCat offerings loaded: \(String(describing: offerings.current?.identifier)), packages: \(offerings.current?.availablePackages.count ?? 0)")
        } catch {
            print("RevenueCat offerings fetch: \(error.localizedDescription)")
        }
    }

    // MARK: - Purchases & Restore

    func purchase(package: Package) async throws -> Bool {
        guard !isPro else { return true }
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Purchases.shared.purchase(package: package)
            if !result.userCancelled {
                handleCustomerInfo(result.customerInfo)
                return self.isPro
            }
            return false
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }

    func restorePurchases() async throws -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            handleCustomerInfo(customerInfo)
            return self.isPro
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Helper

    func handleCustomerInfo(_ customerInfo: CustomerInfo) {
        // If user unlocked via promo code, keep Pro state active
        if isPromoUnlocked {
            self.isPro = true
            UserDefaults.standard.set(true, forKey: "isProSubscribed")
            return
        }

        // "quit_gambling_pro", "pro", or "premium" entitlement identifier
        let hasActivePro = customerInfo.entitlements["quit_gambling_pro"]?.isActive == true ||
                           customerInfo.entitlements["pro"]?.isActive == true ||
                           customerInfo.entitlements["premium"]?.isActive == true

        self.isPro = hasActivePro
        UserDefaults.standard.set(hasActivePro, forKey: "isProSubscribed")
    }

    /// Whether Pro was activated via an authorized Promo Code
    var isPromoUnlocked: Bool {
        UserDefaults.standard.bool(forKey: "isPromoProUnlocked")
    }

    /// Returns the redeemed promo code name if present
    var redeemedPromoCode: String? {
        UserDefaults.standard.string(forKey: "redeemed_promo_code")
    }

    /// Redeems an official promo code (SHIPATON2026) to unlock Pro features permanently
    @discardableResult
    func unlockWithPromoCode(_ code: String) -> Bool {
        let cleaned = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleaned == "SHIPATON2026" || cleaned == "SHIPATHON2026" {
            self.isPro = true
            UserDefaults.standard.set(true, forKey: "isProSubscribed")
            UserDefaults.standard.set(true, forKey: "isPromoProUnlocked")
            UserDefaults.standard.set(cleaned, forKey: "redeemed_promo_code")
            return true
        }
        return false
    }

    /// Reset promo unlock status (e.g. for testing)
    func resetPromoUnlock() {
        UserDefaults.standard.removeObject(forKey: "isPromoProUnlocked")
        UserDefaults.standard.removeObject(forKey: "redeemed_promo_code")
        UserDefaults.standard.set(false, forKey: "isProSubscribed")
        self.isPro = false
    }

    /// Development/Demo bypass for testing and Shipathon judges
    func toggleDemoPro() {
        isPro.toggle()
        UserDefaults.standard.set(isPro, forKey: "isProSubscribed")
    }
}
