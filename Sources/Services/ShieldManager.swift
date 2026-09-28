import SwiftUI
import Combine
import FamilyControls
import ManagedSettings

/// Comprehensive service managing native iOS system-level app and targeted website blocking via Apple's Screen Time APIs.
///
/// CRITICAL FIX: Uses a SINGLE ManagedSettingsStore (the default store) instead of two conflicting stores.
/// Previous dual-store approach (named "QuitGamblingShield" + default) caused iOS to take the UNION of
/// restrictions from both stores, leading to stale/conflicting policies that inverted the blocking behavior.
@Observable
@MainActor
final class ShieldManager {

    #if targetEnvironment(simulator)
    var isSimulator: Bool = true
    #else
    var isSimulator: Bool = false
    #endif

    enum ShieldMode: String, CaseIterable, Identifiable {
        case alwaysOn = "24/7 Continuous Shield"
        case riskHours = "Risk Hours (Evenings & Weekends)"

        var id: String { rawValue }

        var subtitle: String {
            switch self {
            case .alwaysOn:
                return "Always active for maximum protection and abstinence."
            case .riskHours:
                return "Daily 6:00 PM – 6:00 AM and all day on weekends."
            }
        }
    }

    var isShieldActive: Bool {
        didSet {
            UserDefaults.standard.set(isShieldActive, forKey: "isShieldActive")
            applyRestrictions()
        }
    }

    var shieldMode: ShieldMode {
        didSet {
            UserDefaults.standard.set(shieldMode.rawValue, forKey: "shieldMode")
            applyRestrictions()
        }
    }

    var isAuthorized: Bool = false
    var authorizationErrorMessage: String? = nil

    var activitySelection = FamilyActivitySelection() {
        didSet {
            saveActivitySelection()
            if isShieldActive {
                applyRestrictions()
            }
        }
    }

    var customBlockedDomains: [String] = [] {
        didSet {
            UserDefaults.standard.set(customBlockedDomains, forKey: "customBlockedDomains")
            if isShieldActive {
                applyRestrictions()
            }
        }
    }

    var isAutomaticDomainFilterEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isAutomaticDomainFilterEnabled, forKey: "isAutomaticDomainFilterEnabled")
            if isShieldActive {
                applyRestrictions()
            }
        }
    }

    // Use the named store which proved to work on device at 01:39
    private let store = ManagedSettingsStore(named: .init("QuitGamblingShield"))
    private let defaultStore = ManagedSettingsStore()

    var currentCountryCode: String {
        didSet {
            CountryBlocklistCatalog.setCountryCode(currentCountryCode)
            if isShieldActive {
                applyRestrictions()
            }
        }
    }

    var currentCountry: CountryOption {
        CountryBlocklistCatalog.country(for: currentCountryCode)
    }

    /// Curated Top 25 gambling domains for the user's selected country.
    /// Under 49 domains to strictly guarantee Apple's WebContent filter does not silently fail.
    var defaultGamblingDomains: [String] {
        CountryBlocklistCatalog.domains(for: currentCountryCode)
    }

    func setCountry(_ code: String) {
        guard currentCountryCode != code else { return }
        currentCountryCode = code
    }

    var allBlockedDomains: [String] {
        var set = Set<String>()
        var result: [String] = []
        // Country Top 25 domains + custom user domains
        for d in (defaultGamblingDomains + customBlockedDomains) {
            let clean = d.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if !clean.isEmpty && !set.contains(clean) {
                set.insert(clean)
                result.append(clean)
            }
        }
        return result
    }

    /// Returns up to 45 domains to guarantee Apple's ~49 item limit is never breached
    var activeFilterDomains: [String] {
        var set = Set<String>()
        var result: [String] = []
        for d in (defaultGamblingDomains + customBlockedDomains) {
            let clean = d.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if !clean.isEmpty && !set.contains(clean) {
                set.insert(clean)
                result.append(clean)
            }
        }
        return Array(result.prefix(45))
    }

    /// Total count of domains protected in the global HaGeZi database
    var globalDatabaseCount: Int {
        DomainBlocklistService.shared.totalBlockedDomainsCount
    }

    /// Checks if a domain is recognized as a gambling platform in the global database
    func isDomainInGlobalDatabase(_ domain: String) -> Bool {
        DomainBlocklistService.shared.isGamblingDomain(domain)
    }

    init() {
        self.currentCountryCode = CountryBlocklistCatalog.currentCountryCode
        self.isShieldActive = UserDefaults.standard.bool(forKey: "isShieldActive")

        self.shieldMode = .alwaysOn
        UserDefaults.standard.set(ShieldMode.alwaysOn.rawValue, forKey: "shieldMode")

        if let savedCustom = UserDefaults.standard.stringArray(forKey: "customBlockedDomains") {
            self.customBlockedDomains = savedCustom
        }

        if UserDefaults.standard.object(forKey: "isAutomaticDomainFilterEnabled") != nil {
            self.isAutomaticDomainFilterEnabled = UserDefaults.standard.bool(forKey: "isAutomaticDomainFilterEnabled")
        } else {
            self.isAutomaticDomainFilterEnabled = true
        }

        // -- Migration: Clear old named store to eliminate stale/conflicting restrictions --
        if !UserDefaults.standard.bool(forKey: "hasMigratedToSingleStoreV2") {
            print("SHIELD_DEBUG: [Migration] Clearing old named store 'QuitGamblingShield' and default store.")
            // Create a temporary reference to the old named store and clear ALL its settings
            let oldNamedStore = ManagedSettingsStore(named: .init("QuitGamblingShield"))
            oldNamedStore.shield.applications = nil
            oldNamedStore.shield.applicationCategories = nil
            oldNamedStore.shield.webDomains = nil
            oldNamedStore.shield.webDomainCategories = nil
            oldNamedStore.webContent.blockedByFilter = nil
            oldNamedStore.clearAllSettings()
            // Also clear the default store for a guaranteed clean slate
            store.clearAllSettings()
            UserDefaults.standard.set(true, forKey: "hasMigratedToSingleStoreV2")
        }

        loadActivitySelection()

        // Unconditionally clear if shield was saved as inactive
        #if !targetEnvironment(simulator)
        if #available(iOS 16.0, *) {
            let status = AuthorizationCenter.shared.authorizationStatus
            let savedAuth = UserDefaults.standard.bool(forKey: "isScreenTimeAuthorized")
            self.isAuthorized = (status == .approved) || savedAuth
        }
        #else
        self.isAuthorized = true
        #endif

        if isShieldActive && isAuthorized {
            applyRestrictions()
            print("SHIELD_DEBUG: init() complete. isShieldActive is true & authorized -> restrictions applied immediately.")
        } else if !isShieldActive {
            clearEverything()
            print("SHIELD_DEBUG: init() complete. isShieldActive is false -> cleared all stores.")
        } else {
            print("SHIELD_DEBUG: init() complete. isShieldActive is true. Waiting for checkAuthorization().")
        }
    }

    // MARK: - Authorization Lifecycle

    func checkAuthorization() async {
        #if targetEnvironment(simulator)
        isAuthorized = true
        print("SHIELD_DEBUG: [Simulator] Simulated authorization granted.")
        applyRestrictions()
        #else
        if #available(iOS 16.0, *) {
            var status = AuthorizationCenter.shared.authorizationStatus
            print("SHIELD_DEBUG: checkAuthorization() initial status = \(status)")

            if status == .notDetermined {
                do {
                    print("SHIELD_DEBUG: requesting authorization for .individual...")
                    try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                    status = AuthorizationCenter.shared.authorizationStatus
                    print("SHIELD_DEBUG: after requestAuthorization, status = \(status)")
                } catch {
                    print("SHIELD_DEBUG: requestAuthorization error: \(error)")
                }
            }

            isAuthorized = (status == .approved)
            UserDefaults.standard.set(isAuthorized, forKey: "isScreenTimeAuthorized")
            print("SHIELD_DEBUG: checkAuthorization() → isAuthorized=\(isAuthorized), approved=\(status == .approved)")
            applyRestrictions()
        }
        #endif
    }

    func requestAuthorization() async -> Bool {
        #if targetEnvironment(simulator)
        isAuthorized = true
        authorizationErrorMessage = nil
        isShieldActive = true
        applyRestrictions()
        return true
        #else
        if #available(iOS 16.0, *) {
            do {
                print("SHIELD_DEBUG: Requesting authorization for .individual...")
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                isAuthorized = true
                authorizationErrorMessage = nil
                print("SHIELD_DEBUG: requestAuthorization() succeeded! Now activating shield.")
                isShieldActive = true  // triggers didSet → applyRestrictions()
                return true
            } catch {
                print("SHIELD_DEBUG: requestAuthorization() FAILED: \(error)")
                isAuthorized = false
                authorizationErrorMessage = "Screen Time permission was denied or restricted in iOS Settings."
                return false
            }
        }
        return false
        #endif
    }

    // MARK: - Domain Management

    func addCustomDomain(_ domain: String) {
        var cleanDomain = domain.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        cleanDomain = cleanDomain.replacingOccurrences(of: "https://", with: "")
        cleanDomain = cleanDomain.replacingOccurrences(of: "http://", with: "")
        cleanDomain = cleanDomain.replacingOccurrences(of: "www.", with: "")
        if cleanDomain.contains("/") {
            cleanDomain = String(cleanDomain.split(separator: "/").first ?? "")
        }

        guard !cleanDomain.isEmpty, !allBlockedDomains.contains(cleanDomain) else { return }
        customBlockedDomains.append(cleanDomain)
        // didSet already calls applyRestrictions() when isShieldActive
    }

    func removeCustomDomain(_ domain: String) {
        customBlockedDomains.removeAll { $0 == domain }
        // didSet already calls applyRestrictions() when isShieldActive
    }

    // MARK: - Restrictions Application

    /// The single source of truth for applying or clearing Screen Time restrictions.
    ///
    /// - When `isAuthorized && isShieldActive && inActiveWindow`: restrictions are applied to the SINGLE default store.
    /// - Otherwise: the store is cleared via `clearAllSettings()`.
    func applyRestrictions() {
        let shouldBlock = isShieldActive
        print("SHIELD_DEBUG: applyRestrictions() → isShieldActive=\(isShieldActive) → shouldBlock=\(shouldBlock)")

        if shouldBlock {
            guard isAuthorized else {
                print("SHIELD_DEBUG: applyRestrictions() → Cannot apply block: NOT AUTHORIZED.")
                return
            }

            // -- APPLY RESTRICTIONS --

            // 1. Block user-selected applications (e.g. Tipico, Bet365, Casino Apps)
            if !activitySelection.applicationTokens.isEmpty {
                store.shield.applications = activitySelection.applicationTokens
                defaultStore.shield.applications = activitySelection.applicationTokens
            } else {
                store.shield.applications = nil
                defaultStore.shield.applications = nil
            }

            // 2. Block user-selected categories if any
            if !activitySelection.categoryTokens.isEmpty {
                store.shield.applicationCategories = .specific(activitySelection.categoryTokens)
                defaultStore.shield.applicationCategories = .specific(activitySelection.categoryTokens)
            } else {
                store.shield.applicationCategories = nil
                defaultStore.shield.applicationCategories = nil
            }

            // 3. User-picked web domain tokens from FamilyActivityPicker
            if !activitySelection.webDomainTokens.isEmpty {
                store.shield.webDomains = activitySelection.webDomainTokens
                defaultStore.shield.webDomains = activitySelection.webDomainTokens
            } else {
                store.shield.webDomains = nil
                defaultStore.shield.webDomains = nil
            }

            // 4. Targeted Web Domain Filtering via WebContentSettings
            // CRITICAL: Strictly capped via activeFilterDomains (<= 45) to prevent Apple's ~49 limit from dropping the policy!
            let domainsToBlock = activeFilterDomains
            let webDomainSet = Set(domainsToBlock.map { WebDomain(domain: $0) })
            print("SHIELD_DEBUG: [ACTIVE] BLOCKING \(webDomainSet.count) domains on store and defaultStore. First 5: \(domainsToBlock.prefix(5))")
            store.webContent.blockedByFilter = WebContentSettings.FilterPolicy.specific(webDomainSet)
            defaultStore.webContent.blockedByFilter = WebContentSettings.FilterPolicy.specific(webDomainSet)
            store.shield.webDomainCategories = nil
            defaultStore.shield.webDomainCategories = nil

            print("SHIELD_DEBUG: Readback store.blockedByFilter = \(String(describing: store.webContent.blockedByFilter))")
            print("SHIELD_DEBUG: Readback defaultStore.blockedByFilter = \(String(describing: defaultStore.webContent.blockedByFilter))")

        } else {
            // -- CLEAR ALL RESTRICTIONS (UNCONDITIONALLY) --
            clearEverything()
        }
    }

    /// Wipes all restrictions from all possible store instances
    func clearEverything() {
        print("SHIELD_DEBUG: [CLEAR] clearEverything() starting...")

        // 1. Explicitly set .none on primary stores so iOS WebContent filter is immediately deactivated
        store.webContent.blockedByFilter = WebContentSettings.FilterPolicy.none
        defaultStore.webContent.blockedByFilter = WebContentSettings.FilterPolicy.none

        // 2. Clear all shields and settings
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        store.shield.webDomainCategories = nil
        store.clearAllSettings()

        defaultStore.shield.applications = nil
        defaultStore.shield.applicationCategories = nil
        defaultStore.shield.webDomains = nil
        defaultStore.shield.webDomainCategories = nil
        defaultStore.clearAllSettings()

        // 3. Re-affirm .none so iOS daemon receives an explicit "no filtering" directive
        store.webContent.blockedByFilter = WebContentSettings.FilterPolicy.none
        defaultStore.webContent.blockedByFilter = WebContentSettings.FilterPolicy.none

        // 4. Also clear any historical store names that might linger on the device
        let legacyStoreNames = [
            "QuitGamblingShield",
            "FreiSpielShield",
            "com.freispiel.shield",
            "customRestrictions",
            "myStore",
            "QuitGambling",
            "freispiel",
            "shield",
            "ShieldStore",
            "Default"
        ]
        for name in legacyStoreNames {
            let s = ManagedSettingsStore(named: .init(name))
            s.webContent.blockedByFilter = WebContentSettings.FilterPolicy.none
            s.shield.applications = nil
            s.shield.applicationCategories = nil
            s.shield.webDomains = nil
            s.shield.webDomainCategories = nil
            s.clearAllSettings()
            s.webContent.blockedByFilter = WebContentSettings.FilterPolicy.none
        }

        print("SHIELD_DEBUG: [CLEAR] clearEverything() finished. Readback store: \(String(describing: store.webContent.blockedByFilter)), defaultStore: \(String(describing: defaultStore.webContent.blockedByFilter))")
    }

    /// Explicitly disable the shield and clear all restrictions.
    func disableShield() {
        print("SHIELD_DEBUG: disableShield() → setting isShieldActive=false")
        isShieldActive = false
        clearEverything()
    }

    /// Determines if the shield should be restricting apps right now based on the active mode
    func isCurrentlyInActiveWindow() -> Bool {
        return isShieldActive
    }

    // MARK: - Persistence

    private func saveActivitySelection() {
        if let encoded = try? PropertyListEncoder().encode(activitySelection) {
            UserDefaults.standard.set(encoded, forKey: "savedActivitySelection")
        }
    }

    private func loadActivitySelection() {
        if let data = UserDefaults.standard.data(forKey: "savedActivitySelection"),
           let decoded = try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.activitySelection = decoded
        }
    }
}
