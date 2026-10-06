import SwiftUI
import StoreKit

/// Custom StoreKit errors
enum StoreError: LocalizedError {
    case productNotFound
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "The requested product was not found.".loc
        case .failedVerification:
            return "Transaction verification failed.".loc
        }
    }
}

/// Service managing native StoreKit 2 in-app purchases, subscriptions, entitlements, and restore.
@Observable
@MainActor
final class SubscriptionManager {

    // MARK: - Product IDs matching App Store Connect
    static let yearlyId = "yearly"
    static let monthlyId = "monthly"
    static let lifetimeId = "lifetime"
    static let allProductIds: Set<String> = [yearlyId, monthlyId, lifetimeId]

    // MARK: - State Properties
    var isPro: Bool = false
    var products: [Product] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    nonisolated(unsafe) private var updateListenerTask: Task<Void, Never>? = nil

    // MARK: - Computed Product Helpers
    var annualProduct: Product? {
        products.first(where: { $0.id == Self.yearlyId })
    }

    var monthlyProduct: Product? {
        products.first(where: { $0.id == Self.monthlyId })
    }

    var lifetimeProduct: Product? {
        products.first(where: { $0.id == Self.lifetimeId })
    }

    // Backwards compatibility accessor
    static var apiKey: String {
        get { UserDefaults.standard.string(forKey: "revenuecat_public_api_key") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "revenuecat_public_api_key") }
    }

    init() {
        let isDirectPro = UserDefaults.standard.bool(forKey: "isProSubscribed")
        let isPromo = UserDefaults.standard.bool(forKey: "isPromoProUnlocked")
        self.isPro = isDirectPro || isPromo

        startTransactionListener()
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Configuration Lifecycle
    static func configure() {
        // Native StoreKit 2 connects directly to Apple's StoreKit servers without third-party SDKs
    }

    func attachDelegate() {
        if updateListenerTask == nil {
            startTransactionListener()
        }
    }

    // MARK: - StoreKit 2 Transaction Listener
    func startTransactionListener() {
        guard updateListenerTask == nil else { return }

        updateListenerTask = Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { break }
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updateCustomerStatus()
                    await transaction.finish()
                } catch {
                    print("StoreKit 2 transaction update failed verification: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Products Fetching
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let loadedProducts = try await Product.products(for: Self.allProductIds)
            self.products = loadedProducts.sorted(by: { $0.price < $1.price })
            print("StoreKit 2 products loaded: \(loadedProducts.map { "\($0.id): \($0.displayPrice)" })")
        } catch {
            print("StoreKit 2 products load error: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
        }
    }

    /// Backwards compatibility alias
    func fetchOfferings() async {
        await loadProducts()
    }

    // MARK: - Entitlements & Customer Status
    func updateCustomerStatus() async {
        // If user unlocked via promo code, keep Pro state active
        if isPromoUnlocked {
            self.isPro = true
            UserDefaults.standard.set(true, forKey: "isProSubscribed")
            return
        }

        var hasActivePro = false

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if Self.allProductIds.contains(transaction.productID) && transaction.revocationDate == nil {
                    if let expirationDate = transaction.expirationDate {
                        if expirationDate > Date() {
                            hasActivePro = true
                            break
                        }
                    } else {
                        // Non-consumable lifetime purchase
                        hasActivePro = true
                        break
                    }
                }
            } catch {
                print("Entitlement verification error: \(error.localizedDescription)")
            }
        }

        self.isPro = hasActivePro
        UserDefaults.standard.set(hasActivePro, forKey: "isProSubscribed")
    }

    // MARK: - Purchases & Restore
    func purchase(product: Product) async throws -> Bool {
        guard !isPro else { return true }
        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateCustomerStatus()
            await transaction.finish()
            return self.isPro

        case .userCancelled:
            return false

        case .pending:
            return false

        @unknown default:
            return false
        }
    }

    func purchase(productId: String) async throws -> Bool {
        guard !isPro else { return true }

        var targetProduct = products.first(where: { $0.id == productId })
        if targetProduct == nil {
            let fetched = try await Product.products(for: [productId])
            targetProduct = fetched.first
        }

        guard let product = targetProduct else {
            throw StoreError.productNotFound
        }

        return try await purchase(product: product)
    }

    func restorePurchases() async throws -> Bool {
        isLoading = true
        defer { isLoading = false }

        try await AppStore.sync()
        await updateCustomerStatus()
        return self.isPro
    }

    // MARK: - Verification Helper
    nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Promo Code Support
    var isPromoUnlocked: Bool {
        UserDefaults.standard.bool(forKey: "isPromoProUnlocked")
    }

    var redeemedPromoCode: String? {
        UserDefaults.standard.string(forKey: "redeemed_promo_code")
    }

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

    func resetPromoUnlock() {
        UserDefaults.standard.removeObject(forKey: "isPromoProUnlocked")
        UserDefaults.standard.removeObject(forKey: "redeemed_promo_code")
        UserDefaults.standard.set(false, forKey: "isProSubscribed")
        self.isPro = false
    }

    func toggleDemoPro() {
        isPro.toggle()
        UserDefaults.standard.set(isPro, forKey: "isProSubscribed")
    }
}
