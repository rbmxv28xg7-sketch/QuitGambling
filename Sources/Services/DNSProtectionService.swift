import SwiftUI
import NetworkExtension

/// Service to configure and manage system-wide encrypted DNS protection (DoH) via Apple's NetworkExtension.
/// Protects against 525,000+ gambling domains system-wide across all browsers and apps with 0 extensions.
@Observable
@MainActor
final class DNSProtectionService {
    static let shared = DNSProtectionService()

    var isDNSActive: Bool = UserDefaults.standard.bool(forKey: "isDNSActive") {
        didSet {
            UserDefaults.standard.set(isDNSActive, forKey: "isDNSActive")
        }
    }
    var isConfigured: Bool = UserDefaults.standard.bool(forKey: "isDNSConfigured") {
        didSet {
            UserDefaults.standard.set(isConfigured, forKey: "isDNSConfigured")
        }
    }
    var isCheckingStatus: Bool = false
    var statusMessage: String? = nil
    var errorMessage: String? = nil

    private let manager = NEDNSSettingsManager.shared()

    init() {
        Task {
            await checkStatus()
        }

        NotificationCenter.default.addObserver(
            forName: Notification.Name.NEDNSSettingsConfigurationDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                print("DNS_DEBUG: NEDNSSettingsConfigurationDidChange received!")
                await self?.checkStatus()
            }
        }
    }

    func checkStatus() async {
        isCheckingStatus = true
        defer { isCheckingStatus = false }
        do {
            try await manager.loadFromPreferences()

            // Automatically upgrade existing profile to dedicated Gambling protection endpoint if still on older endpoint
            if let doh = manager.dnsSettings as? NEDNSOverHTTPSSettings,
               doh.serverURL?.absoluteString != "https://freedns.controld.com/no-gambling" {
                print("DNS_DEBUG: Auto-migrating DNS settings to no-gambling...")
                let newDoh = NEDNSOverHTTPSSettings(servers: [
                    "76.76.2.11",
                    "76.76.10.11",
                    "76.76.2.22",
                    "76.76.10.22",
                    "2606:1a40::11",
                    "2606:1a40:1::11"
                ])
                newDoh.serverURL = URL(string: "https://freedns.controld.com/no-gambling")
                manager.dnsSettings = newDoh
                manager.localizedDescription = "QuitGambling 500k+ Gambling Shield"
                manager.onDemandRules = [NEOnDemandRuleConnect()]
                try? await manager.saveToPreferences()
                try? await manager.loadFromPreferences()
            }

            let hasSettings = (manager.dnsSettings != nil)
            self.isConfigured = hasSettings
            self.isDNSActive = hasSettings && manager.isEnabled
            print("DNS_DEBUG: checkStatus: isConfigured=\(isConfigured), isDNSActive=\(isDNSActive)")
            if self.isDNSActive {
                self.statusMessage = "System-wide DNS protection (500k+ gambling sites) is active!"
                self.errorMessage = nil
            } else if self.isConfigured {
                self.statusMessage = "Profile saved to iOS — please activate in iOS Settings."
                self.errorMessage = nil
            } else {
                self.statusMessage = nil
            }
        } catch {
            print("DNS_DEBUG: checkStatus failed: \(error)")
            self.isConfigured = false
            self.isDNSActive = false
            self.statusMessage = nil
        }
    }

    /// Open iOS Settings directly, prioritizing Allgemein -> VPN & Geräteverwaltung
    func openDNSSettings() {
        let candidates = [
            "settings-navigation://com.apple.Settings.General/VPN",
            "settings-navigation://com.apple.Settings.General/ManagedConfigurationList",
            "settings-navigation://com.apple.Settings.General",
            "settings-navigation://",
            "App-prefs:General&path=ManagedConfigurationList",
            "App-prefs:root=General&path=VPN",
            "App-prefs:root=General",
            "App-prefs:General",
            "App-Prefs:root=General",
            "App-Prefs:",
            "prefs:root=General&path=ManagedConfigurationList",
            "prefs:root=General&path=VPN",
            "prefs:root=General",
            "prefs:",
            UIApplication.openSettingsURLString
        ]
        openFirstAvailableURL(candidates)
    }

    private func openFirstAvailableURL(_ urls: [String]) {
        guard let first = urls.first, let url = URL(string: first) else { return }
        print("DNS_DEBUG: Attempting to open Settings URL: \(first)")
        UIApplication.shared.open(url, options: [:]) { success in
            print("DNS_DEBUG: URL \(first) open result: \(success)")
            if !success && urls.count > 1 {
                self.openFirstAvailableURL(Array(urls.dropFirst()))
            }
        }
    }

    /// Reloads and updates DNS status from iOS preferences
    @discardableResult
    func activateDNS() async -> Bool {
        isCheckingStatus = true
        errorMessage = nil
        defer { isCheckingStatus = false }
        do {
            try await manager.loadFromPreferences()
            let dohSettings = NEDNSOverHTTPSSettings(servers: [
                "76.76.2.11",
                "76.76.10.11",
                "76.76.2.22",
                "76.76.10.22",
                "2606:1a40::11",
                "2606:1a40:1::11"
            ])
            dohSettings.serverURL = URL(string: "https://freedns.controld.com/no-gambling")
            manager.dnsSettings = dohSettings
            manager.localizedDescription = "QuitGambling 500k+ Gambling Shield"
            manager.onDemandRules = [NEOnDemandRuleConnect()]
            try await manager.saveToPreferences()
            try await manager.loadFromPreferences()
            let hasSettings = (manager.dnsSettings != nil)
            self.isConfigured = hasSettings
            self.isDNSActive = hasSettings && manager.isEnabled
            print("DNS_DEBUG: activateDNS() result: isConfigured=\(isConfigured), isDNSActive=\(isDNSActive)")
            if self.isDNSActive {
                self.statusMessage = "System-wide DNS protection (500k+ gambling sites) is active!"
            }
            return self.isDNSActive
        } catch {
            print("DNS_DEBUG: activateDNS() error: \(error)")
            self.errorMessage = "Error: \(error.localizedDescription)"
            return false
        }
    }

    /// Natively request iOS to add QuitGambling encrypted DNS settings
    func enableDNSProtection() async -> Bool {
        errorMessage = nil
        statusMessage = "Preparing configuration..."

        do {
            try? await manager.loadFromPreferences()

            // Configure Encrypted DNS over HTTPS (DoH) pointing to dedicated Gambling resolver
            let dohSettings = NEDNSOverHTTPSSettings(servers: [
                "76.76.2.11",
                "76.76.10.11",
                "76.76.2.22",
                "76.76.10.22",
                "2606:1a40::11",
                "2606:1a40:1::11"
            ])
            dohSettings.serverURL = URL(string: "https://freedns.controld.com/no-gambling")

            manager.dnsSettings = dohSettings
            manager.localizedDescription = "QuitGambling 500k+ Gambling Shield"
            manager.onDemandRules = [NEOnDemandRuleConnect()]

            statusMessage = "Please confirm in the iOS prompt..."
            
            do {
                try await manager.saveToPreferences()
                print("DNS_DEBUG: saveToPreferences() succeeded!")
                try await manager.loadFromPreferences()
                let hasSettings = (manager.dnsSettings != nil)
                self.isConfigured = hasSettings
                self.isDNSActive = hasSettings && manager.isEnabled

                if self.isDNSActive {
                    self.statusMessage = "System-wide DNS protection is active!"
                } else {
                    self.statusMessage = "DNS registered in iOS. Go to Settings → General → VPN & Device Management → DNS to activate."
                }
                return true
            } catch let saveError as NSError {
                print("DNS_DEBUG: saveToPreferences failed: domain=\(saveError.domain), code=\(saveError.code), userInfo=\(saveError.userInfo)")
                self.isConfigured = false
                self.isDNSActive = false
                self.errorMessage = "Error [\(saveError.domain):\(saveError.code)]: \(saveError.localizedDescription) - \(saveError.userInfo)"
                self.statusMessage = nil
                return false
            }
        } catch {
            print("DNS_DEBUG: enableDNSProtection outer failed: \(error)")
            self.errorMessage = "Error: \(error.localizedDescription)"
            self.statusMessage = nil
            return false
        }
    }

    /// Disable system-wide DNS protection
    func disableDNSProtection() async {
        do {
            try await manager.loadFromPreferences()
            try await manager.removeFromPreferences()
            self.isConfigured = false
            self.isDNSActive = false
            self.statusMessage = "DNS protection deactivated."
        } catch {
            print("DNS_DEBUG: disableDNSProtection failed: \(error)")
            self.isConfigured = false
            self.isDNSActive = false
            self.errorMessage = error.localizedDescription
        }
    }

    /// Direct URL to the official signed Apple Configuration Profile (.mobileconfig) for Gambling
    var directProfileURL: URL {
        URL(string: "https://api.controld.com/mobileconfig/no-gambling?type=free")!
    }

    /// Direct URL to the Apple NextDNS configuration profile generator
    var nextDNSProfileURL: URL {
        URL(string: "https://apple.nextdns.io")!
    }

    /// Direct URL to iOS device management settings
    var deviceManagementURL: URL {
        URL(string: "App-prefs:General&path=ManagedConfigurationList") ?? URL(string: UIApplication.openSettingsURLString)!
    }
}
