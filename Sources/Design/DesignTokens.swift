import SwiftUI

/// Centralized design system for FreiSpiel.
enum Design {

    // MARK: - Colors

    enum Colors {
        static let primary = Color("SageGreen")
        static let primaryLight = Color("EucalyptusLight")
        static let secondary = Color("SlateBlue")
        static let accent = Color("Terracotta")
        static let gold = Color("MutedGold")
        static let sos = Color("BrickRed")
        static let surface = Color("Surface")
        static let surfaceHover = Color("SurfaceHover")
        static let background = Color("Background")

        static let calendarClean = Color("SageGreen").opacity(0.35)
        static let calendarCraving = Color.orange.opacity(0.35)
        static let calendarRelapse = Color("BrickRed").opacity(0.35)
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Radius

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }

    // MARK: - Animations

    enum Anim {
        static let fast = Animation.easeOut(duration: 0.15)
        static let normal = Animation.easeOut(duration: 0.25)
        static let slow = Animation.easeOut(duration: 0.4)
        static let spring = Animation.spring(duration: 0.5, bounce: 0.3)
    }

    // MARK: - Milestones

    enum Milestone: CaseIterable {
        case day1, day3, week1, week2, month1, month3, month6, year1

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

        var icon: String {
            switch self {
            case .day1: "leaf.fill"
            case .day3: "leaf.arrow.circlepath"
            case .week1: "tree.fill"
            case .week2: "tree.fill"
            case .month1: "mountain.2.fill"
            case .month3: "sun.max.fill"
            case .month6: "star.fill"
            case .year1: "crown.fill"
            }
        }

        var label: String {
            switch self {
            case .day1: String(localized: "milestone_1day", defaultValue: "1 Tag")
            case .day3: String(localized: "milestone_3days", defaultValue: "3 Tage")
            case .week1: String(localized: "milestone_1week", defaultValue: "1 Woche")
            case .week2: String(localized: "milestone_2weeks", defaultValue: "2 Wochen")
            case .month1: String(localized: "milestone_1month", defaultValue: "1 Monat")
            case .month3: String(localized: "milestone_3months", defaultValue: "3 Monate")
            case .month6: String(localized: "milestone_6months", defaultValue: "6 Monate")
            case .year1: String(localized: "milestone_1year", defaultValue: "1 Jahr")
            }
        }
    }

    // MARK: - Triggers

    enum Trigger: String, CaseIterable, Identifiable {
        case boredom, stress, payday, sports, alcohol, loneliness, socialMedia, argument, other

        var id: String { rawValue }

        var label: String {
            switch self {
            case .boredom: "Langeweile"
            case .stress: "Stress"
            case .payday: "Gehalt/Geld"
            case .sports: "Sportereignis"
            case .alcohol: "Alkohol"
            case .loneliness: "Einsamkeit"
            case .socialMedia: "Social Media"
            case .argument: "Streit"
            case .other: "Sonstiges"
            }
        }

        var icon: String {
            switch self {
            case .boredom: "clock.fill"
            case .stress: "bolt.fill"
            case .payday: "banknote.fill"
            case .sports: "sportscourt.fill"
            case .alcohol: "wineglass.fill"
            case .loneliness: "person.fill.questionmark"
            case .socialMedia: "iphone"
            case .argument: "exclamationmark.bubble.fill"
            case .other: "ellipsis.circle.fill"
            }
        }
    }

    // MARK: - Mood

    enum Mood: Int, CaseIterable, Identifiable {
        case terrible = 1, bad, neutral, good, great

        var id: Int { rawValue }

        var emoji: String {
            switch self {
            case .terrible: "😢"
            case .bad: "😕"
            case .neutral: "😐"
            case .good: "🙂"
            case .great: "😊"
            }
        }
    }
}
