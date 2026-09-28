import SwiftUI

/// App-wide user preferences for localization, currency, units, and regional protection.
@Observable
@MainActor
final class AppPreferences {
    static let shared = AppPreferences()

    // MARK: - Supported Options

    struct LanguageOption: Identifiable, Hashable {
        let id: String
        let name: String
        let nativeName: String
    }

    static let supportedLanguages: [LanguageOption] = [
        LanguageOption(id: "en", name: "English (US)", nativeName: "English (US)"),
        LanguageOption(id: "de", name: "German", nativeName: "Deutsch"),
        LanguageOption(id: "es", name: "Spanish", nativeName: "Español"),
        LanguageOption(id: "fr", name: "French", nativeName: "Français")
    ]

    struct CurrencyOption: Identifiable, Hashable {
        let id: String
        let code: String
        let symbol: String
        let name: String
    }

    static let supportedCurrencies: [CurrencyOption] = [
        CurrencyOption(id: "USD", code: "USD", symbol: "$", name: "US Dollar ($)"),
        CurrencyOption(id: "EUR", code: "EUR", symbol: "€", name: "Euro (€)"),
        CurrencyOption(id: "GBP", code: "GBP", symbol: "£", name: "British Pound (£)"),
        CurrencyOption(id: "CAD", code: "CAD", symbol: "$", name: "Canadian Dollar ($)"),
        CurrencyOption(id: "AUD", code: "AUD", symbol: "$", name: "Australian Dollar ($)"),
        CurrencyOption(id: "CHF", code: "CHF", symbol: "Fr", name: "Swiss Franc (Fr)")
    ]

    enum UnitSystem: String, CaseIterable, Identifiable {
        case imperial = "imperial"
        case metric = "metric"

        var id: String { rawValue }

        var title: String {
            switch self {
            case .imperial: return "Imperial (ft / mi)".loc
            case .metric: return "Metric (m / km)".loc
            }
        }
    }

    struct RegionOption: Identifiable, Hashable {
        let id: String
        let code: String
        let name: String
        let flagSymbol: String
    }

    static let supportedRegions: [RegionOption] = [
        RegionOption(id: "US", code: "US", name: "United States", flagSymbol: "flag.fill"),
        RegionOption(id: "DE", code: "DE", name: "Germany", flagSymbol: "globe.europe.africa.fill"),
        RegionOption(id: "GB", code: "GB", name: "United Kingdom", flagSymbol: "flag.fill"),
        RegionOption(id: "CA", code: "CA", name: "Canada", flagSymbol: "leaf.fill"),
        RegionOption(id: "AU", code: "AU", name: "Australia", flagSymbol: "sun.max.fill"),
        RegionOption(id: "AT", code: "AT", name: "Austria", flagSymbol: "mountain.2.fill"),
        RegionOption(id: "CH", code: "CH", name: "Switzerland", flagSymbol: "cross.fill"),
        RegionOption(id: "ES", code: "ES", name: "Spain", flagSymbol: "sun.horizon.fill"),
        RegionOption(id: "FR", code: "FR", name: "France", flagSymbol: "flag.fill")
    ]

    // MARK: - Properties

    var languageCode: String {
        get {
            access(keyPath: \.languageCode)
            return LocalizationService.shared.currentLanguage
        }
        set {
            withMutation(keyPath: \.languageCode) {
                LocalizationService.shared.currentLanguage = newValue
            }
        }
    }

    var currencyCode: String {
        didSet {
            UserDefaults.standard.set(currencyCode, forKey: "app_currency_code")
        }
    }

    var unitSystem: UnitSystem {
        didSet {
            UserDefaults.standard.set(unitSystem.rawValue, forKey: "app_unit_system")
        }
    }

    var regionCode: String {
        didSet {
            UserDefaults.standard.set(regionCode, forKey: "app_region_code")
            UserDefaults.standard.set(regionCode, forKey: CountryBlocklistCatalog.storageKey)
        }
    }

    // MARK: - Init

    init() {
        self.currencyCode = UserDefaults.standard.string(forKey: "app_currency_code") ?? "USD"

        let savedUnit = UserDefaults.standard.string(forKey: "app_unit_system") ?? UnitSystem.imperial.rawValue
        self.unitSystem = UnitSystem(rawValue: savedUnit) ?? .imperial

        let savedRegion = UserDefaults.standard.string(forKey: "app_region_code") ?? CountryBlocklistCatalog.currentCountryCode
        self.regionCode = savedRegion
    }

    // MARK: - Formatting Helpers

    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(Int(amount))"
    }

    func formatCurrencyPrecise(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(String(format: "%.2f", amount))"
    }

    func formatDistance(meters: Double) -> String {
        if unitSystem == .imperial {
            let feet = meters * 3.28084
            if feet < 1000 {
                return "\(Int(feet)) ft"
            } else {
                let miles = meters / 1609.34
                return String(format: "%.1f mi", miles)
            }
        } else {
            if meters < 1000 {
                return "\(Int(meters)) m"
            } else {
                let km = meters / 1000.0
                return String(format: "%.1f km", km)
            }
        }
    }
}
