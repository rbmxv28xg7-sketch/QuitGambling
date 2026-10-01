import SwiftUI

// MARK: - Hotline Info Model
struct HotlineInfo: Identifiable, Hashable {
    var id: String { number }
    let name: String
    let number: String
}

// MARK: - Hotline Directory & Starred Storage
@MainActor
enum HotlineDirectory {
    static let starredKey = "starred_hotline_numbers_v1"

    static var userCountryCode: String {
        if let region = Locale.current.region?.identifier {
            return region.uppercased()
        }
        if let code = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            return code.uppercased()
        }
        return "DE"
    }

    static let usHotlines: [HotlineInfo] = [
        HotlineInfo(name: "US National Helpline", number: "1-800-522-4700"),
        HotlineInfo(name: "988 Crisis Lifeline", number: "988")
    ]

    static func localHotlines(for code: String = userCountryCode) -> (countryTitle: String, hotlines: [HotlineInfo]) {
        switch code {
        case "AT":
            return ("Austria", [
                HotlineInfo(name: "Austrian Gambling Help", number: "01 544 13 57"),
                HotlineInfo(name: "Austrian Crisis Line", number: "142"),
                HotlineInfo(name: "Addiction & Substance Counseling", number: "01 4000 53700")
            ])
        case "CH":
            return ("Switzerland", [
                HotlineInfo(name: "SOS Gambling Help", number: "0800 040 080"),
                HotlineInfo(name: "The Offering Hand Crisis Line", number: "143"),
                HotlineInfo(name: "Careplay Counseling", number: "0800 801 112")
            ])
        case "GB":
            return ("United Kingdom", [
                HotlineInfo(name: "UK GamCare", number: "0808 8020 133"),
                HotlineInfo(name: "Samaritans", number: "116 123")
            ])
        case "CA":
            return ("Canada", [
                HotlineInfo(name: "Problem Gambling Helpline", number: "1-888-230-3505"),
                HotlineInfo(name: "Crisis Helpline", number: "988")
            ])
        case "AU":
            return ("Australia", [
                HotlineInfo(name: "AU Gambling Help", number: "1800 858 858"),
                HotlineInfo(name: "Lifeline", number: "13 11 14")
            ])
        case "FR":
            return ("France", [
                HotlineInfo(name: "Joueurs Info Service", number: "09 74 75 13 13"),
                HotlineInfo(name: "SOS Amitié", number: "09 72 39 40 50")
            ])
        case "ES":
            return ("Spain", [
                HotlineInfo(name: "FEJAR Línea de Ayuda", number: "900 200 225"),
                HotlineInfo(name: "Teléfono de la Esperanza", number: "717 003 717")
            ])
        case "IT":
            return ("Italy", [
                HotlineInfo(name: "Telefono Verde Gioco d'Azzardo", number: "800 558 822"),
                HotlineInfo(name: "Telefono Amico", number: "02 2327 2327")
            ])
        case "NL":
            return ("Netherlands", [
                HotlineInfo(name: "Loket Kansspel", number: "0800 24 000 22"),
                HotlineInfo(name: "De Luisterlijn", number: "088 0767 000")
            ])
        case "DE":
            return ("Germany", [
                HotlineInfo(name: "BZgA Gambling Helpline", number: "0800 1 37 27 00"),
                HotlineInfo(name: "Telefonseelsorge Crisis Line", number: "0800 111 0 111"),
                HotlineInfo(name: "OASIS Exclusion Help", number: "0800 137 2700")
            ])
        default: // "US" as standard
            return ("United States", [
                HotlineInfo(name: "1-800-GAMBLER (NCPG)", number: "1-800-426-2537"),
                HotlineInfo(name: "988 Suicide & Crisis Lifeline", number: "988"),
                HotlineInfo(name: "SAMHSA National Helpline", number: "1-800-662-4357")
            ])
        }
    }

    static var defaultStarredNumbers: [String] {
        []
    }

    static func getStarredNumbers() -> [String] {
        Array(HotlineStore.shared.starredNumbers)
    }

    static func setStarredNumbers(_ list: [String]) {
        HotlineStore.shared.starredNumbers = Set(list)
    }

    static func isStarred(number: String) -> Bool {
        HotlineStore.shared.isStarred(number: number)
    }

    static func toggleStar(number: String) {
        HotlineStore.shared.toggleStar(number: number)
    }

    static func allAvailableHotlines() -> [HotlineInfo] {
        var all = localHotlines().hotlines
        for us in usHotlines {
            if !all.contains(where: { $0.number == us.number }) {
                all.append(us)
            }
        }
        return all
    }

    static func starredHotlines() -> [HotlineInfo] {
        HotlineStore.shared.starredHotlines()
    }
}

// MARK: - Reactive Hotline Store (Observable)
@Observable
@MainActor
final class HotlineStore {
    static let shared = HotlineStore()

    var starredNumbers: Set<String> = []

    init() {
        self.starredNumbers = Set(HotlineStore.loadSavedStarredNumbers())
    }

    private static let storageKey = "starred_hotline_numbers_v3"

    private static func loadSavedStarredNumbers() -> [String] {
        if let raw = UserDefaults.standard.string(forKey: storageKey),
           let data = raw.data(using: .utf8),
           let list = try? JSONDecoder().decode([String].self, from: data) {
            return list
        }
        return []
    }

    func isStarred(number: String) -> Bool {
        starredNumbers.contains(number)
    }

    func toggleStar(number: String) {
        if starredNumbers.contains(number) {
            starredNumbers.remove(number)
        } else {
            starredNumbers.insert(number)
        }
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(Array(starredNumbers)),
           let str = String(data: data, encoding: .utf8) {
            UserDefaults.standard.set(str, forKey: HotlineStore.storageKey)
        }
    }

    func starredHotlines() -> [HotlineInfo] {
        let all = HotlineDirectory.allAvailableHotlines()
        return all.filter { starredNumbers.contains($0.number) }
    }
}

// MARK: - Hotline Compatibility Service
@MainActor
enum HotlineService {
    static var detectedCountryCode: String {
        HotlineDirectory.userCountryCode
    }

    static func primaryEmergencyNumber() -> String {
        let starred = HotlineDirectory.starredHotlines()
        if let first = starred.first {
            return first.number.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
        }
        let code = detectedCountryCode
        if code == "US" {
            return "18005224700"
        }
        let hotlines = HotlineDirectory.localHotlines(for: code).hotlines
        return hotlines.first?.number.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "") ?? "08001372700"
    }

    struct CountryStub {
        let countryName: String
    }

    static func hotlines(for code: String) -> CountryStub {
        if code == "US" {
            return CountryStub(countryName: "USA")
        }
        return CountryStub(countryName: HotlineDirectory.localHotlines(for: code).countryTitle)
    }
}

// MARK: - Hotline List View
struct HotlineListView: View {
    @State private var store = HotlineStore.shared

    private var userCountry: (countryTitle: String, hotlines: [HotlineInfo]) {
        HotlineDirectory.localHotlines()
    }

    private var isUserInUS: Bool {
        HotlineDirectory.userCountryCode == "US"
    }

    var body: some View {
        ZStack {
            FlutedGlassBackgroundView()

            ScrollView(showsIndicators: false) {
                VStack(spacing: Design.Spacing.lg) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("A single call can change everything.")
                            .font(.headline)
                            .foregroundStyle(Design.Colors.textPrimary)

                        Text("Tap the star to add a helpline to your quick-access favorites.")
                            .font(.caption)
                            .foregroundStyle(Design.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)

                    // 1. Local Country (if not USA)
                    if !isUserInUS {
                        hotlineSection(userCountry.countryTitle) {
                            ForEach(Array(userCountry.hotlines.enumerated()), id: \.element.id) { index, item in
                                if index > 0 {
                                    Divider().background(Color.white.opacity(0.12))
                                }
                                HotlineRow(
                                    name: item.name,
                                    number: item.number,
                                    isStarred: store.isStarred(number: item.number),
                                    onToggleStar: {
                                        withAnimation(Design.Anim.spring) {
                                            store.toggleStar(number: item.number)
                                        }
                                        SensoryFeedbackService.shared.selectionClick()
                                    }
                                )
                            }
                        }
                    }

                    // 2. United States (USA) – always visible
                    hotlineSection("United States (USA)") {
                        ForEach(Array(HotlineDirectory.usHotlines.enumerated()), id: \.element.id) { index, item in
                            if index > 0 {
                                Divider().background(Color.white.opacity(0.12))
                            }
                            HotlineRow(
                                name: item.name,
                                number: item.number,
                                isStarred: store.isStarred(number: item.number),
                                onToggleStar: {
                                    withAnimation(Design.Anim.spring) {
                                        store.toggleStar(number: item.number)
                                    }
                                    SensoryFeedbackService.shared.selectionClick()
                                }
                            )
                        }
                    }

                    // If user is in US, optional international section
                    if isUserInUS {
                        hotlineSection("Germany (International)") {
                            let deHotlines = HotlineDirectory.localHotlines(for: "DE").hotlines
                            ForEach(Array(deHotlines.enumerated()), id: \.element.id) { index, item in
                                if index > 0 {
                                    Divider().background(Color.white.opacity(0.12))
                                }
                                HotlineRow(
                                    name: item.name,
                                    number: item.number,
                                    isStarred: store.isStarred(number: item.number),
                                    onToggleStar: {
                                        withAnimation(Design.Anim.spring) {
                                            store.toggleStar(number: item.number)
                                        }
                                        SensoryFeedbackService.shared.selectionClick()
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, Design.Spacing.md)
                .padding(.bottom, 96)
            }
        }
        .navigationTitle("Helplines")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func hotlineSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Design.Spacing.xs) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(Design.Colors.gold)
                .padding(.leading, 8)

            VStack(spacing: Design.Spacing.md) {
                content()
            }
            .liquidGlass(cornerRadius: Design.Radius.card, padding: Design.Spacing.md)
        }
    }
}

// MARK: - Hotline Row View
struct HotlineRow: View {
    let name: String
    let number: String
    let isStarred: Bool
    let onToggleStar: () -> Void

    var body: some View {
        HStack(spacing: Design.Spacing.sm) {
            VStack(alignment: .leading, spacing: Design.Spacing.xs) {
                Text(name)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.white)
                    .lineLimit(1)

                Text(number)
                    .font(.subheadline)
                    .foregroundStyle(Design.Colors.textSecondary)
                    .lineLimit(1)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onToggleStar()
            }

            Spacer()

            HStack(spacing: 4) {
                // Star Button - nur der kleine Stern
                Button {
                    onToggleStar()
                } label: {
                    Image(systemName: isStarred ? "star.fill" : "star")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(isStarred ? Design.Colors.gold : Design.Colors.textTertiary)
                        .scaleEffect(isStarred ? 1.08 : 1.0)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // Call Button
                Button {
                    SensoryFeedbackService.shared.selectionClick()
                    let cleanNumber = number
                        .replacingOccurrences(of: " ", with: "")
                        .replacingOccurrences(of: "-", with: "")
                    if let url = URL(string: "tel:\(cleanNumber)") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Image(systemName: "phone.fill")
                        .font(.title3)
                        .foregroundStyle(Design.Colors.sos)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, Design.Spacing.xs)
    }
}

#Preview {
    NavigationStack {
        HotlineListView()
    }
}
