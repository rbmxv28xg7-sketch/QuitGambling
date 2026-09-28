import Foundation

/// Represents a supported country or geographic region for targeted Screen Time domain blocking.
struct CountryOption: Identifiable, Hashable {
    var id: String { code }
    let code: String
    let name: String
    let icon: String // SF Symbol name (NO emojis)
    let domains: [String]
}

/// Curated catalog providing the exact Top 25 gambling, casino, and betting websites
/// for each supported country, optimized for Apple's Screen Time WebContent filter limit (~49 domains).
enum CountryBlocklistCatalog {
    static let storageKey = "selected_country_code"

    static let supportedCountries: [CountryOption] = [
        CountryOption(
            code: "DE",
            name: "Germany",
            icon: "globe.europe.africa.fill",
            domains: [
                "tipico.de",
                "bwin.de",
                "bet365.de",
                "betano.de",
                "stake.com",
                "stake.bet",
                "rollbit.com",
                "pokerstars.de",
                "888casino.de",
                "wildz.de",
                "wunderino.de",
                "platincasino.de",
                "drueckglueck.de",
                "interwetten.de",
                "jackpotpiraten.de",
                "bingbong.de",
                "novoline.de",
                "sunmaker.de",
                "loewen-play.de",
                "bet-at-home.de",
                "betway.de",
                "admiralbet.de",
                "unibet.de",
                "neobet.de",
                "oddset.de"
            ]
        ),
        CountryOption(
            code: "AT",
            name: "Austria",
            icon: "mountain.2.fill",
            domains: [
                "win2day.at",
                "bet-at-home.com",
                "tipico.at",
                "bwin.at",
                "admiral.at",
                "interwetten.com",
                "bet365.com",
                "betano.com",
                "stake.com",
                "rollbit.com",
                "mrgreen.at",
                "pokerstars.eu",
                "888casino.com",
                "leovegas.com",
                "unibet.com",
                "betway.com",
                "rabona.com",
                "cashpoint.at",
                "sportsbet.io",
                "roobet.com",
                "20bet.com",
                "22bet.com",
                "bizzo-casino.com",
                "nationalcasino.com",
                "vulkanvegas.com"
            ]
        ),
        CountryOption(
            code: "CH",
            name: "Switzerland",
            icon: "shield.fill",
            domains: [
                "swisslos.ch",
                "loterie.ch",
                "jackpots.ch",
                "starvegas.ch",
                "7melons.ch",
                "casino777.ch",
                "mycasino.ch",
                "pasino.ch",
                "gamrfirst.ch",
                "goldengrand.ch",
                "swiss4win.ch",
                "hurrahcasino.ch",
                "stake.com",
                "rollbit.com",
                "bet365.com",
                "bwin.com",
                "tipico.com",
                "roobet.com",
                "unibet.com",
                "betano.com",
                "interwetten.com",
                "pokerstars.ch",
                "888casino.com",
                "betway.com",
                "bahigo.com"
            ]
        ),
        CountryOption(
            code: "US",
            name: "United States",
            icon: "globe.americas.fill",
            domains: [
                "draftkings.com",
                "fanduel.com",
                "betmgm.com",
                "caesars.com",
                "bet365.com",
                "bovada.lv",
                "betonline.ag",
                "mybookie.ag",
                "ignitioncasino.eu",
                "chumbacasino.com",
                "pulsz.com",
                "stake.us",
                "roobet.com",
                "rollbit.com",
                "betrivers.com",
                "espnbet.com",
                "fanatics.com",
                "hardrock.bet",
                "pokerstars.com",
                "wsop.com",
                "borgataonline.com",
                "betfair.com",
                "barstoolsportsbook.com",
                "cafe-casino.lv",
                "shuffle.com"
            ]
        ),
        CountryOption(
            code: "GB",
            name: "United Kingdom",
            icon: "crown.fill",
            domains: [
                "bet365.com",
                "skybet.com",
                "paddypower.com",
                "ladbrokes.com",
                "williamhill.com",
                "betfair.com",
                "coral.co.uk",
                "betfred.com",
                "888casino.com",
                "888sport.com",
                "pokerstars.uk",
                "grosvenorcasinos.com",
                "virginbet.com",
                "betway.com",
                "unibet.co.uk",
                "tombola.co.uk",
                "betvictor.com",
                "boylesports.com",
                "midnite.com",
                "stake.com",
                "rollbit.com",
                "duelbits.com",
                "roobet.com",
                "kwiff.com",
                "betmgm.co.uk"
            ]
        ),
        CountryOption(
            code: "CA",
            name: "Canada",
            icon: "leaf.fill",
            domains: [
                "bet99.com",
                "sportsinteraction.com",
                "bet365.com",
                "betonline.ag",
                "bovada.lv",
                "bodog.eu",
                "playnow.com",
                "olg.ca",
                "espacejeux.com",
                "leovegas.com",
                "betway.com",
                "stake.com",
                "roobet.com",
                "spinpalace.com",
                "jackpotcity.com",
                "rubyfortune.com",
                "royalvegas.com",
                "888casino.com",
                "pokerstars.com",
                "draftkings.com",
                "fanduel.com",
                "pointsbet.com",
                "thescore.bet",
                "unibet.com",
                "partycasino.com"
            ]
        ),
        CountryOption(
            code: "AU",
            name: "Australia",
            icon: "sun.max.fill",
            domains: [
                "sportsbet.com.au",
                "tab.com.au",
                "ladbrokes.com.au",
                "neds.com.au",
                "betr.com.au",
                "unibet.com.au",
                "bet365.com.au",
                "pointsbet.com.au",
                "palmerbet.com.au",
                "bluebet.com.au",
                "betdeluxe.com.au",
                "playup.com.au",
                "betfair.com.au",
                "topbetta.com.au",
                "picklebet.com",
                "stake.com",
                "roobet.com",
                "rollbit.com",
                "duelbits.com",
                "betway.com",
                "888casino.com",
                "pokerstars.com",
                "casinonic.com",
                "ignitioncasino.eu",
                "joefortune.com"
            ]
        ),
        CountryOption(
            code: "ES",
            name: "Spain",
            icon: "sun.horizon.fill",
            domains: [
                "bet365.es",
                "sportium.es",
                "codere.es",
                "bwin.es",
                "williamhill.es",
                "betfair.es",
                "888sport.es",
                "888casino.es",
                "pokerstars.es",
                "luckia.es",
                "wanabet.es",
                "paston.es",
                "kirolbet.es",
                "retabet.es",
                "marcaapuestas.es",
                "marathonbet.es",
                "casinobarcelona.es",
                "betway.es",
                "interwetten.es",
                "leovegas.es",
                "stake.com",
                "rollbit.com",
                "roobet.com",
                "platincasino.es",
                "granmadridcasinoonline.es"
            ]
        ),
        CountryOption(
            code: "FR",
            name: "France",
            icon: "flag.fill",
            domains: [
                "betclic.fr",
                "winamax.fr",
                "unibet.fr",
                "fdj.fr",
                "parionssport.fdj.fr",
                "pmu.fr",
                "bwin.fr",
                "pokerstars.fr",
                "netbet.fr",
                "zebet.fr",
                "vbet.fr",
                "partypoker.fr",
                "feelingbet.fr",
                "genybet.fr",
                "joa.fr",
                "betway.fr",
                "circus.fr",
                "stake.com",
                "rollbit.com",
                "roobet.com",
                "shuffle.com",
                "duelbits.com",
                "1xbet.com",
                "22bet.com",
                "sportsbet.io"
            ]
        ),
        CountryOption(
            code: "INT",
            name: "International",
            icon: "network",
            domains: [
                "stake.com",
                "stake.bet",
                "rollbit.com",
                "roobet.com",
                "shuffle.com",
                "duelbits.com",
                "bet365.com",
                "1xbet.com",
                "22bet.com",
                "bc.game",
                "bitstarz.com",
                "500.casino",
                "sportsbet.io",
                "cloudbet.com",
                "vave.com",
                "gamdom.com",
                "csgoroll.com",
                "clash.gg",
                "rainbet.com",
                "bwin.com",
                "betano.com",
                "unibet.com",
                "888casino.com",
                "pokerstars.com",
                "betway.com"
            ]
        )
    ]

    /// Returns the countries sorted so that countries matching the chosen language are shown first.
    static func prioritizedCountries(for languageCode: String) -> [CountryOption] {
        let primaryCodes: [String]
        switch languageCode {
        case "de":
            primaryCodes = ["DE", "AT", "CH"]
        case "en":
            primaryCodes = ["US", "GB", "CA", "AU"]
        case "es":
            primaryCodes = ["ES"]
        case "fr":
            primaryCodes = ["FR", "CH", "CA"]
        default:
            primaryCodes = ["US", "GB"]
        }

        var prioritized: [CountryOption] = []
        for code in primaryCodes {
            if let country = supportedCountries.first(where: { $0.code == code }) {
                prioritized.append(country)
            }
        }
        for country in supportedCountries {
            if !prioritized.contains(where: { $0.code == country.code }) {
                prioritized.append(country)
            }
        }
        return prioritized
    }

    /// Default recommended country code based on the chosen language
    static func defaultCountryCode(for languageCode: String) -> String {
        switch languageCode {
        case "de": return "DE"
        case "en": return "US"
        case "es": return "ES"
        case "fr": return "FR"
        default: return "US"
        }
    }

    /// Resolves the current country code, falling back to language default
    static var currentCountryCode: String {
        if let saved = UserDefaults.standard.string(forKey: storageKey), !saved.isEmpty {
            return saved
        }
        if let region = Locale.current.region?.identifier.uppercased(),
           supportedCountries.contains(where: { $0.code == region }) {
            return region
        }
        return defaultCountryCode(for: LocalizationService.shared.currentLanguage)
    }

    /// Stores the selected country code
    static func setCountryCode(_ code: String) {
        UserDefaults.standard.set(code, forKey: storageKey)
    }

    /// Returns the CountryOption object matching the given code
    static func country(for code: String) -> CountryOption {
        supportedCountries.first(where: { $0.code == code })
            ?? supportedCountries.first(where: { $0.code == "INT" })
            ?? supportedCountries[0]
    }

    /// Returns the exact Top 25 domains for the country code
    static func domains(for code: String) -> [String] {
        country(for: code).domains
    }
}
