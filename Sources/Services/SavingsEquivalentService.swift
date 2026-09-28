import Foundation

/// Represents a tangible real-world item, experience, or milestone that saved money translates to.
struct SavingsEquivalent: Identifiable, Hashable {
    var id: String { title }
    let threshold: Double
    let title: String
    let shortTitle: String
    let icon: String // SF Symbol name (strictly NO emojis)
    let description: String
    let category: String
}

/// Service providing cognitive-behavioral tangible conversions of saved gambling money
/// into real-life purchasing power and meaningful experiences.
enum SavingsEquivalentService {

    static let equivalents: [SavingsEquivalent] = [
        SavingsEquivalent(
            threshold: 5,
            title: "Coffee & Pastry",
            shortTitle: "Coffee & Pastry",
            icon: "cup.and.saucer.fill",
            description: "Enjoy a fresh cup of coffee and pastry at your favorite café.",
            category: "Everyday"
        ),
        SavingsEquivalent(
            threshold: 15,
            title: "Inspiring Book or Audiobook",
            shortTitle: "A Great Book",
            icon: "book.fill",
            description: "New perspectives and wisdom for your personal growth.",
            category: "Education"
        ),
        SavingsEquivalent(
            threshold: 30,
            title: "Movie Night with Snacks",
            shortTitle: "1x Movie Night",
            icon: "popcorn.fill",
            description: "An exciting film on the big screen with friends.",
            category: "Leisure"
        ),
        SavingsEquivalent(
            threshold: 60,
            title: "Fine Restaurant Dinner",
            shortTitle: "1x Fine Dinner",
            icon: "fork.knife",
            description: "A wonderful dinner enjoyed with complete peace of mind.",
            category: "Dining"
        ),
        SavingsEquivalent(
            threshold: 120,
            title: "Weekly Family Groceries",
            shortTitle: "1x Weekly Groceries",
            icon: "cart.fill",
            description: "High-quality, nourishing food for a full week.",
            category: "Everyday"
        ),
        SavingsEquivalent(
            threshold: 200,
            title: "Quality Brand Sneakers",
            shortTitle: "New Sneakers",
            icon: "shoeprints.fill",
            description: "Comfortable shoes for your gamble-free journey.",
            category: "Reward"
        ),
        SavingsEquivalent(
            threshold: 350,
            title: "Weekend City Getaway",
            shortTitle: "Weekend Getaway",
            icon: "tram.fill",
            description: "Travel tickets and two nights exploring an exciting city.",
            category: "Experience"
        ),
        SavingsEquivalent(
            threshold: 600,
            title: "Spa & Wellness Weekend",
            shortTitle: "Wellness Weekend",
            icon: "sparkles",
            description: "Sauna, massage, and deep restoration for mind and body.",
            category: "Wellness"
        ),
        SavingsEquivalent(
            threshold: 1_000,
            title: "New Smartphone or Tablet",
            shortTitle: "New Smartphone",
            icon: "iphone.gen3",
            description: "Modern technology that enriches your daily life.",
            category: "Tech"
        ),
        SavingsEquivalent(
            threshold: 1_800,
            title: "1-Week Beach Vacation",
            shortTitle: "1-Week Beach Trip",
            icon: "sun.max.fill",
            description: "Sun, sand, and ocean waves instead of casino noise.",
            category: "Travel"
        ),
        SavingsEquivalent(
            threshold: 3_500,
            title: "Dream International Journey",
            shortTitle: "Dream Vacation",
            icon: "airplane.departure",
            description: "An unforgettable journey you will cherish for a lifetime.",
            category: "Travel"
        ),
        SavingsEquivalent(
            threshold: 6_000,
            title: "Reliable Used Car",
            shortTitle: "A Used Car",
            icon: "car.fill",
            description: "True freedom and independent mobility on four wheels.",
            category: "Freedom"
        ),
        SavingsEquivalent(
            threshold: 10_000,
            title: "Solid Emergency Fund",
            shortTitle: "$10,000 Safety Fund",
            icon: "shield.lefthalf.filled",
            description: "Real financial security and enduring peace of mind.",
            category: "Security"
        )
    ]

    /// Returns the highest unlocked real-world equivalent for the given amount
    static func currentEquivalent(for saved: Double) -> SavingsEquivalent {
        let unlocked = equivalents.filter { $0.threshold <= saved }
        return unlocked.last ?? equivalents[0]
    }

    /// Returns the next upcoming equivalent above the saved amount
    static func nextEquivalent(for saved: Double) -> SavingsEquivalent? {
        equivalents.first { $0.threshold > saved }
    }

    /// Calculates progress and remaining euros toward the next tangible milestone
    static func progressToNext(for saved: Double) -> (next: SavingsEquivalent, remaining: Double, progress: Double)? {
        guard let next = nextEquivalent(for: saved) else { return nil }
        let currentThreshold = equivalents.last(where: { $0.threshold <= saved })?.threshold ?? 0
        let span = next.threshold - currentThreshold
        guard span > 0 else { return (next, 0, 1.0) }
        let progress = min(max((saved - currentThreshold) / span, 0.0), 1.0)
        let remaining = max(next.threshold - saved, 0.0)
        return (next, remaining, progress)
    }

    /// Generates quick multiplier items (e.g. "4x Restaurant-Essen")
    static func quickMultipliers(for saved: Double) -> [(icon: String, text: String)] {
        var results: [(icon: String, text: String)] = []

        if saved >= 60 {
            let count = Int(saved / 60)
            results.append(("fork.knife", "%dx Dinners out with friends".loc(count)))
        }

        if saved >= 30 {
            let count = Int(saved / 30)
            results.append(("popcorn.fill", "%dx Movie nights with snacks".loc(count)))
        }

        if saved >= 120 {
            let count = Int(saved / 120)
            results.append(("cart.fill", "%dx Weekly grocery trips".loc(count)))
        }

        if saved >= 5 {
            let count = Int(saved / 5)
            results.append(("cup.and.saucer.fill", "%dx Coffee & pastry treats".loc(count)))
        }

        return Array(results.prefix(3))
    }
}
