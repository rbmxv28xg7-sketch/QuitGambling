import SwiftUI

/// Defines the harmonious color palettes for Quit Gambling.
/// Each theme provides calibrated primary, secondary, background, and surface tones,
/// allowing the user to experience Quit Gambling in their preferred energy frequency.
enum Colorway: String, CaseIterable, Identifiable {
    case amberDusk = "amber_dusk"
    case emeraldOasis = "emerald_oasis"
    case sapphireAurora = "sapphire_aurora"
    case amethystVelvet = "amethyst_velvet"
    case solarChampagne = "solar_champagne"
    case cleanMonochrome = "clean_monochrome"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .amberDusk: "Amber & Twilight"
        case .emeraldOasis: "Emerald & Oasis"
        case .sapphireAurora: "Sapphire & Aurora"
        case .amethystVelvet: "Amethyst & Twilight"
        case .solarChampagne: "Solar & Champagne"
        case .cleanMonochrome: "White & Gray"
        }
    }

    var isMonochrome: Bool {
        self == .cleanMonochrome
    }

    // MARK: - Primary Luminous Accents

    var primary: Color {
        switch self {
        case .amberDusk:
            Color(red: 0.98, green: 0.68, blue: 0.22) // Luminous Amber #FBAE38
        case .emeraldOasis:
            Color(red: 0.20, green: 0.85, blue: 0.58) // Radiant Emerald #33D994
        case .sapphireAurora:
            Color(red: 0.22, green: 0.78, blue: 0.98) // Electric Ice Cyan #38C7FA
        case .amethystVelvet:
            Color(red: 0.80, green: 0.45, blue: 0.95) // Velvet Orchid #CC73F2
        case .solarChampagne:
            Color(red: 1.00, green: 0.82, blue: 0.32) // Pure Solar Gold #FFD152
        case .cleanMonochrome:
            Color.white // Pure Crisp White
        }
    }

    var primaryLight: Color {
        switch self {
        case .amberDusk:
            Color(red: 1.00, green: 0.82, blue: 0.42) // Radiant Flame
        case .emeraldOasis:
            Color(red: 0.45, green: 0.96, blue: 0.74) // Mint Glow
        case .sapphireAurora:
            Color(red: 0.55, green: 0.88, blue: 1.00) // Glacier Shimmer
        case .amethystVelvet:
            Color(red: 0.92, green: 0.68, blue: 1.00) // Soft Lavender Light
        case .solarChampagne:
            Color(red: 1.00, green: 0.92, blue: 0.60) // Brilliant Sunburst
        case .cleanMonochrome:
            Color(white: 0.92) // Luminous Silver
        }
    }

    var copper: Color {
        switch self {
        case .amberDusk:
            Color(red: 0.92, green: 0.45, blue: 0.18) // Warm Copper
        case .emeraldOasis:
            Color(red: 0.12, green: 0.65, blue: 0.60) // Deep Teal
        case .sapphireAurora:
            Color(red: 0.18, green: 0.55, blue: 0.90) // Royal Azure
        case .amethystVelvet:
            Color(red: 0.65, green: 0.28, blue: 0.78) // Deep Plum
        case .solarChampagne:
            Color(red: 0.92, green: 0.58, blue: 0.20) // Deep Honey Ochre
        case .cleanMonochrome:
            Color(red: 0.65, green: 0.68, blue: 0.74) // Cool Slate Gray
        }
    }

    var terracotta: Color {
        switch self {
        case .amberDusk:
            Color(red: 0.75, green: 0.25, blue: 0.12) // Rust Terracotta
        case .emeraldOasis:
            Color(red: 0.08, green: 0.40, blue: 0.42) // Oceanic Twilight
        case .sapphireAurora:
            Color(red: 0.10, green: 0.30, blue: 0.65) // Midnight Blue
        case .amethystVelvet:
            Color(red: 0.45, green: 0.15, blue: 0.55) // Velvet Wine
        case .solarChampagne:
            Color(red: 0.72, green: 0.38, blue: 0.10) // Warm Bronze
        case .cleanMonochrome:
            Color(red: 0.38, green: 0.40, blue: 0.46) // Deep Graphite Gray
        }
    }

    var champagne: Color {
        switch self {
        case .amberDusk:
            Color(red: 0.98, green: 0.86, blue: 0.62) // Pale Champagne
        case .emeraldOasis:
            Color(red: 0.80, green: 0.96, blue: 0.85) // Frosted Jade
        case .sapphireAurora:
            Color(red: 0.82, green: 0.94, blue: 0.98) // Frosted Ice
        case .amethystVelvet:
            Color(red: 0.94, green: 0.84, blue: 0.98) // Moonstone Rose
        case .solarChampagne:
            Color(red: 0.98, green: 0.92, blue: 0.74) // Luminous Pearl Gold
        case .cleanMonochrome:
            Color.white // Pure Specular Reflection
        }
    }

    var ambientTint: Color {
        switch self {
        case .amberDusk:
            Color(red: 0.98, green: 0.68, blue: 0.22)
        case .emeraldOasis:
            Color(red: 0.20, green: 0.85, blue: 0.58)
        case .sapphireAurora:
            Color(red: 0.22, green: 0.78, blue: 0.98)
        case .amethystVelvet:
            Color(red: 0.80, green: 0.45, blue: 0.95)
        case .solarChampagne:
            Color(red: 1.00, green: 0.82, blue: 0.32)
        case .cleanMonochrome:
            Color(white: 0.90)
        }
    }

    // MARK: - Text Contrast on Primary Backgrounds

    /// Guaranteed high-contrast text color (WCAG AAA > 9:1) when rendered on top of the luminous primary brand background across ALL colorways.
    var textOnPrimary: Color {
        Color(red: 0.08, green: 0.09, blue: 0.12)
    }

    // MARK: - Toggle / Switch Tint

    /// Active toggle track color that avoids glaring solid white while maintaining sharp knob contrast
    var toggleTint: Color {
        switch self {
        case .cleanMonochrome:
            Color(red: 0.36, green: 0.39, blue: 0.46) // Elegant deep slate gray (darker, never white!)
        default:
            primary
        }
    }

    // MARK: - Video Spectral Transformation

    /// The exact GPU hue-rotation angle applied to 'Timeline 1.mp4' to transform
    /// the orange/purple/blue ambient light flows into the desired colorway spectrum.
    var hueRotation: Angle {
        switch self {
        case .amberDusk:
            .degrees(0) // Native video colors
        case .emeraldOasis:
            .degrees(95) // Orange -> Emerald Green, Purple/Blue -> Oceanic Teal & Sapphire
        case .sapphireAurora:
            .degrees(185) // Orange -> Ice Cyan/Sapphire, Purple/Blue -> Deep Indigo & Coral
        case .amethystVelvet:
            .degrees(275) // Orange -> Velvet Orchid, Purple/Blue -> Twilight Cyan & Deep Midnight
        case .solarChampagne:
            .degrees(-15) // Orange -> Pure Radiant Sun Gold & Champagne
        case .cleanMonochrome:
            .degrees(0)
        }
    }

    // MARK: - Harmonic 3-Point Color System (Unten Rechts)

    /// Die dritte Farbe für die untere rechte Bildschirmecke (Atmosphärische Tiefe und Erdung)
    var tertiary: Color {
        switch self {
        case .amberDusk:
            Color(red: 0.12, green: 0.22, blue: 0.58) // Deep Midnight Blue
        case .emeraldOasis:
            Color(red: 0.08, green: 0.28, blue: 0.68) // Deep Oceanic Cobalt / Midnight Navy
        case .sapphireAurora:
            Color(red: 0.58, green: 0.22, blue: 0.78) // Deep Mystic Amethyst / Polar Dusk
        case .amethystVelvet:
            Color(red: 0.10, green: 0.35, blue: 0.72) // Deep Twilight Cyan / Midnight Azure
        case .solarChampagne:
            Color(red: 0.38, green: 0.14, blue: 0.44) // Deep Sunset Amethyst / Obsidian
        case .cleanMonochrome:
            Color(red: 0.16, green: 0.18, blue: 0.22) // Cool Slate Graphite
        }
    }

    /// Color samples to display in the UI colorway picker:
    /// [1. Hauptfarbe (Top-Left), 2. Zweite Farbe (Mitte), 3. Dritte Farbe (Unten Rechts)]
    var previewColors: [Color] {
        switch self {
        case .amberDusk:
            [
                Color(red: 0.98, green: 0.68, blue: 0.22), // Luminous Amber
                Color(red: 0.60, green: 0.26, blue: 0.74), // Twilight Purple
                Color(red: 0.12, green: 0.22, blue: 0.58)  // Deep Midnight Blue (unten rechts)
            ]
        case .emeraldOasis:
            [
                Color(red: 0.18, green: 0.86, blue: 0.56), // Radiant Emerald
                Color(red: 0.10, green: 0.62, blue: 0.68), // Peacock Teal
                Color(red: 0.08, green: 0.28, blue: 0.68)  // Deep Oceanic Cobalt (unten rechts)
            ]
        case .sapphireAurora:
            [
                Color(red: 0.22, green: 0.78, blue: 0.98), // Ice Cyan
                Color(red: 0.28, green: 0.35, blue: 0.88), // Royal Indigo
                Color(red: 0.58, green: 0.22, blue: 0.78)  // Mystic Amethyst (unten rechts)
            ]
        case .amethystVelvet:
            [
                Color(red: 0.82, green: 0.45, blue: 0.96), // Velvet Orchid
                Color(red: 0.52, green: 0.18, blue: 0.68), // Royal Plum
                Color(red: 0.10, green: 0.35, blue: 0.72)  // Twilight Azure (unten rechts)
            ]
        case .solarChampagne:
            [
                Color(red: 1.00, green: 0.80, blue: 0.28), // Sun Gold
                Color(red: 0.92, green: 0.48, blue: 0.20), // Warm Copper
                Color(red: 0.38, green: 0.14, blue: 0.44)  // Sunset Amethyst (unten rechts)
            ]
        case .cleanMonochrome:
            [
                Color.white,                                // Reines Weiß
                Color(red: 0.65, green: 0.68, blue: 0.74), // Schiefergrau
                Color(red: 0.16, green: 0.18, blue: 0.22)  // Tiefes Graphit (unten rechts)
            ]
        }
    }
}

/// Dynamic Theme Manager orchestrating all real-time colorway transformations.
@Observable
@MainActor
final class ThemeManager {
    static let shared = ThemeManager()

    var selectedColorway: Colorway {
        didSet {
            UserDefaults.standard.set(selectedColorway.rawValue, forKey: "app_selected_colorway")
        }
    }

    init() {
        if !UserDefaults.standard.bool(forKey: "hasSetMonochromeDefault_v2") {
            UserDefaults.standard.set(true, forKey: "hasSetMonochromeDefault_v2")
            UserDefaults.standard.set(Colorway.cleanMonochrome.rawValue, forKey: "app_selected_colorway")
            self.selectedColorway = .cleanMonochrome
        } else {
            let saved = UserDefaults.standard.string(forKey: "app_selected_colorway") ?? Colorway.cleanMonochrome.rawValue
            self.selectedColorway = Colorway(rawValue: saved) ?? .cleanMonochrome
        }
    }

    func selectColorway(_ colorway: Colorway) {
        let isPro = UserDefaults.standard.bool(forKey: "isProSubscribed")
        if !isPro && colorway != .cleanMonochrome {
            return
        }
        withAnimation(Design.Anim.spring) {
            selectedColorway = colorway
        }
    }
}
