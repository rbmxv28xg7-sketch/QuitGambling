import SwiftUI

/// Design System for FreiSpiel: Warm Amber & Terracotta Fluted Glass Theme.
/// Harmonized with the 'Timeline 1' amber/terracotta/mahogany video background.
enum Design {

    // MARK: - Warm Amber, Copper & Obsidian Palette

    @MainActor
    enum Colors {
        // Mahogany & Deep Obsidian Canvas
        static let obsidian = Color(red: 0.05, green: 0.05, blue: 0.07) // True Deep Obsidian
        static let background = Color.black

        // Liquid Glass Surface Overlays (Neutral Obsidian Glass from Screenshot)
        static let surface = Color(red: 0.12, green: 0.13, blue: 0.16).opacity(0.65)
        static let surfaceElevated = Color(red: 0.16, green: 0.17, blue: 0.20).opacity(0.75)
        static let surfaceHighlight = Color.white.opacity(0.12)
        static let surfaceHover = Color(red: 0.18, green: 0.19, blue: 0.23).opacity(0.75)


        // Dynamic Harmonic Brand Colors (Driven by ThemeManager)
        static var amberGold: Color { ThemeManager.shared.selectedColorway.primary }
        static var warmFlame: Color { ThemeManager.shared.selectedColorway.primaryLight }
        static var copper: Color { ThemeManager.shared.selectedColorway.copper }
        static var terracotta: Color { ThemeManager.shared.selectedColorway.terracotta }
        static var champagne: Color { ThemeManager.shared.selectedColorway.champagne }

        // Semantic Signal Colors
        static let signalGreen = Color(red: 0.20, green: 0.85, blue: 0.58) // Crisp Radiant Emerald #33D994
        static let signalRed = Color(red: 0.88, green: 0.24, blue: 0.18) // Deep Crimson Rust #E03D2E
        static var signalGold: Color { ThemeManager.shared.selectedColorway.champagne }

        // App Standard Mappings
        static var primary: Color { ThemeManager.shared.selectedColorway.primary }
        static var primaryLight: Color { ThemeManager.shared.selectedColorway.primaryLight }
        static let secondary = Color(white: 0.95) // Luminous Crisp Silver
        static var gold: Color { ThemeManager.shared.selectedColorway.champagne }
        static var goldGradient: LinearGradient {
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.85, blue: 0.4), Color(red: 0.95, green: 0.70, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        static var accent: Color { ThemeManager.shared.selectedColorway.primary }
        static let sos = signalRed

        // High-Contrast Luminous Typography (Crisp Pure White & Frosted Silver)
        static let ivory = Color.white
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.90) // Crisp, readable, never muddy
        static let textTertiary = Color.white.opacity(0.80) // High-contrast tertiary (was 0.72)
        static var textOnPrimary: Color { ThemeManager.shared.selectedColorway.textOnPrimary }
        static var toggleTint: Color { ThemeManager.shared.selectedColorway.toggleTint }

        // Calendar Status
        static var calendarClean: Color { ThemeManager.shared.selectedColorway.primary.opacity(0.22) }
        static var calendarCraving: Color { ThemeManager.shared.selectedColorway.copper.opacity(0.28) }
        static let calendarRelapse = signalRed.opacity(0.28)

        // Compatibility Aliases
        static var bioluminescentEmerald: Color { ThemeManager.shared.selectedColorway.primary }
        static var bioluminescentMint: Color { ThemeManager.shared.selectedColorway.primaryLight }
        static var bioluminescentTeal: Color { ThemeManager.shared.selectedColorway.primary }
        static let velvetCoral = signalRed
    }

    // MARK: - Strict 8pt Spatial Rhythm

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let hero: CGFloat = 64
    }

    // MARK: - Corner Radii

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 14
        static let card: CGFloat = 24
        static let lg: CGFloat = 26
        static let xl: CGFloat = 30
        static let pill: CGFloat = 100
    }

    // MARK: - Tactile Animations

    enum Anim {
        static let fast = Animation.easeOut(duration: 0.15)
        static let normal = Animation.easeOut(duration: 0.22)
        static let smooth = Animation.easeInOut(duration: 0.30)
        static let spring = Animation.spring(response: 0.38, dampingFraction: 0.82)
    }

    // MARK: - Milestones

    enum Milestone: CaseIterable, Identifiable {
        case day1, day3, week1, week2, month1, month3, month6, year1

        var id: Int { days }

        var days: Int {
            switch self {
            case .day1: 1
            case .day3: 3
            case .week1: 7
            case .week2: 14
            case .month1: 30
            case .month3: 90
            case .month6: 180
            case .year1: 365
            }
        }

        var title: String {
            switch self {
            case .day1: "The Spark"
            case .day3: "The Foundation"
            case .week1: "The Shield"
            case .week2: "The Flame"
            case .month1: "The Summit"
            case .month3: "The Dawn"
            case .month6: "The North Star"
            case .year1: "Crown of Freedom"
            }
        }

        var subtitle: String {
            switch self {
            case .day1: "Day 1 • First Step"
            case .day3: "Day 3 • 72h Threshold"
            case .week1: "Day 7 • 1 Week Strong"
            case .week2: "Day 14 • Dopamine Reset"
            case .month1: "Day 30 • 1 Full Month"
            case .month3: "Day 90 • Neuroplasticity"
            case .month6: "Day 180 • New Identity"
            case .year1: "Day 365 • Absolute Freedom"
            }
        }

        var rank: String {
            switch self {
            case .day1: "Bronze"
            case .day3: "Bronze +"
            case .week1: "Silver"
            case .week2: "Silver +"
            case .month1: "Gold"
            case .month3: "Platinum"
            case .month6: "Diamond"
            case .year1: "Legend"
            }
        }

        var icon: String {
            switch self {
            case .day1: "sparkles"
            case .day3: "leaf.fill"
            case .week1: "shield.fill"
            case .week2: "flame.fill"
            case .month1: "mountain.2.fill"
            case .month3: "sun.max.fill"
            case .month6: "star.fill"
            case .year1: "crown.fill"
            }
        }

        var label: String {
            switch self {
            case .day1: "1 Day"
            case .day3: "3 Days"
            case .week1: "1 Week"
            case .week2: "2 Weeks"
            case .month1: "1 Month"
            case .month3: "3 Months"
            case .month6: "6 Months"
            case .year1: "1 Year"
            }
        }

        var colors: [Color] {
            switch self {
            case .day1:
                [Color(red: 0.96, green: 0.68, blue: 0.28), Color(red: 0.85, green: 0.42, blue: 0.12)]
            case .day3:
                [Color(red: 0.20, green: 0.85, blue: 0.58), Color(red: 0.08, green: 0.58, blue: 0.40)]
            case .week1:
                [Color(red: 0.25, green: 0.72, blue: 0.98), Color(red: 0.12, green: 0.45, blue: 0.88)]
            case .week2:
                [Color(red: 0.78, green: 0.38, blue: 0.98), Color(red: 0.52, green: 0.18, blue: 0.85)]
            case .month1:
                [Color(red: 0.98, green: 0.35, blue: 0.45), Color(red: 0.80, green: 0.15, blue: 0.28)]
            case .month3:
                [Color(red: 1.00, green: 0.75, blue: 0.20), Color(red: 0.90, green: 0.50, blue: 0.10)]
            case .month6:
                [Color(red: 0.55, green: 0.60, blue: 0.98), Color(red: 0.35, green: 0.38, blue: 0.85)]
            case .year1:
                [Color(red: 1.00, green: 0.88, blue: 0.45), Color(red: 0.95, green: 0.72, blue: 0.20), Color(red: 0.85, green: 0.55, blue: 0.15)]
            }
        }

        var summaryBenefit: String {
            switch self {
            case .day1: "Cortisol levels drop, heart rate calms"
            case .day3: "Peak physical restlessness subsides"
            case .week1: "REM deep sleep measurably restores"
            case .week2: "Dopamine receptors recover noticeably"
            case .month1: "Prefrontal cortex strengthens impulse control"
            case .month3: "Addiction triggers in the brain fade"
            case .month6: "Grounded identity as a free individual"
            case .year1: "Full annual cycle lived in freedom"
            }
        }

        var scientificFact: String {
            switch self {
            case .day1:
                "The first 24 hours without a wager halts the synthetic dopamine rollercoaster. Your stress hormone cortisol begins normalizing immediately as clarity returns."
            case .day3:
                "The critical 72-hour milestone! The most intense physical restlessness of withdrawal breaks here. Your brain begins recognizing that you hold conscious control."
            case .week1:
                "One full week free! Your sleep architecture (deep REM sleep) measurably restores. Mental clarity, concentration, and emotional balance return."
            case .week2:
                "Dopamine reset: Overstimulated D2 dopamine receptors begin upregulating. Everyday pleasures like good food, music, and conversation become genuinely rewarding again."
            case .month1:
                "30 days of self-mastery! Your prefrontal cortex—the command center for logical reasoning and impulse control—has reclaimed leadership over impulsive cravings."
            case .month3:
                "Neuroplasticity in action: Old gambling pathways in the brain atrophy from disuse, while new, healthy neural connections become permanent highways."
            case .month6:
                "Half a year of transformation! This is no longer luck—it is a grounded new way of living. Your vulnerability to acute gambling urges has dropped to a minimum."
            case .year1:
                "365 days: The crown of freedom! You navigated every season, high, and low without gambling. You have reclaimed your life, your dignity, and your future."
            }
        }
    }

    // MARK: - Triggers & Moods

    enum Trigger: String, CaseIterable, Identifiable {
        case boredom = "Boredom"
        case stress = "Stress"
        case payday = "Payday / Money"
        case sports = "Sports Event"
        case alcohol = "Alcohol"
        case loneliness = "Loneliness"
        case socialMedia = "Social Media"
        case argument = "Conflict"
        case other = "Other"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .boredom: "clock.fill"
            case .stress: "bolt.fill"
            case .payday: "banknote.fill"
            case .sports: "sportscourt.fill"
            case .alcohol: "wineglass.fill"
            case .loneliness: "person.fill"
            case .socialMedia: "iphone"
            case .argument: "bubble.left.and.exclamationmark.bubble.right.fill"
            case .other: "ellipsis.circle.fill"
            }
        }
    }

    enum Mood: Int, CaseIterable, Identifiable {
        case terrible = 1, bad, neutral, good, great

        var id: Int { rawValue }

        var iconName: String {
            switch self {
            case .terrible: "face.dashed"
            case .bad: "face.dashed"
            case .neutral: "face.smiling"
            case .good: "face.smiling"
            case .great: "face.smiling.inverse"
            }
        }

        var label: String {
            switch self {
            case .terrible: "Overwhelmed"
            case .bad: "Anxious"
            case .neutral: "Stable"
            case .good: "Optimistic"
            case .great: "Empowered"
            }
        }

        var fullTitle: String {
            switch self {
            case .terrible: "Overwhelmed"
            case .bad: "Anxious"
            case .neutral: "Stable & Calm"
            case .good: "Optimistic"
            case .great: "Strong & Free"
            }
        }

        @MainActor
        var color: Color {
            switch self {
            case .terrible: return Color(red: 0.92, green: 0.40, blue: 0.40) // Soft Coral Red
            case .bad: return Color(red: 0.95, green: 0.62, blue: 0.35)      // Warm Peach Orange
            case .neutral: return Color(red: 0.65, green: 0.72, blue: 0.82)  // Calming Slate Blue/Silver
            case .good: return Color(red: 0.45, green: 0.82, blue: 0.60)     // Fresh Mint Green
            case .great: return Color(red: 0.32, green: 0.88, blue: 0.54)    // Radiant Emerald
            }
        }

        @MainActor
        var luminousColor: Color {
            switch self {
            case .terrible: return Color(red: 1.00, green: 0.48, blue: 0.48) // High-contrast Luminous Coral Red
            case .bad: return Color(red: 1.00, green: 0.70, blue: 0.38)      // High-contrast Golden Amber
            case .neutral: return Color(red: 0.78, green: 0.85, blue: 0.94)  // High-contrast Ice Slate
            case .good: return Color(red: 0.50, green: 0.90, blue: 0.66)     // High-contrast Fresh Mint
            case .great: return Color(red: 0.38, green: 0.96, blue: 0.60)    // High-contrast Vivid Emerald
            }
        }

        var emoji: String {
            String(rawValue)
        }
    }
}

