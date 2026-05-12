import SwiftUI
import Combine

@MainActor
final class TowerJournal: ObservableObject {
    @AppStorage("app.tower.fav-list")        private var favRaw: String = ""
    @AppStorage("app.tower.viewed")          private var viewedRaw: String = ""
    @AppStorage("app.tower.search-history")  private var searchRaw: String = ""
    @AppStorage("app.tower.region-filter")   private var regionRaw: String = ""
    @AppStorage("app.tower.category-filter") private var categoryRaw: String = ""
    @AppStorage("app.tower.start-tab")       private var startTabRaw: String = "home"
    @AppStorage("app.tower.sort")            private var sortRaw: String = "popular"

    @Published private(set) var towers: [Tower] = []
    @Published private(set) var favorites: Set<String> = []
    @Published private(set) var viewed: Set<String> = []
    @Published private(set) var searchHistory: [String] = []
    @Published var regionFilter: Region? = nil
    @Published var categoryFilter: TowerCategory? = nil
    @Published var sort: SortMode = .popular

    enum SortMode: String, CaseIterable, Identifiable {
        case popular, height, recent, az
        var id: String { rawValue }
        var label: LocalizedStringKey {
            switch self {
            case .popular: return "explore.sort.popular"
            case .height:  return "explore.sort.height"
            case .recent:  return "explore.sort.recent"
            case .az:      return "explore.sort.az"
            }
        }
    }

    func pull() {
        towers = TowerLoader.load()
        favorites = parseSet(favRaw)
        viewed = parseSet(viewedRaw)
        searchHistory = parseList(searchRaw).reversed()
        regionFilter = Region(rawValue: regionRaw)
        categoryFilter = TowerCategory(rawValue: categoryRaw)
        sort = SortMode(rawValue: sortRaw) ?? .popular
    }

    func flush() {
        favRaw = encode(favorites)
        viewedRaw = encode(viewed)
        searchRaw = encode(Array(searchHistory.reversed()))
        regionRaw = regionFilter?.rawValue ?? ""
        categoryRaw = categoryFilter?.rawValue ?? ""
        sortRaw = sort.rawValue
    }

    func toggleFavorite(_ id: String) {
        if favorites.contains(id) {
            favorites.remove(id)
        } else {
            favorites.insert(id)
        }
        flush()
    }

    func isFavorited(_ id: String) -> Bool { favorites.contains(id) }

    func markViewed(_ id: String) {
        guard !viewed.contains(id) else { return }
        viewed.insert(id)
        flush()
    }

    func recordSearch(_ term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { return }
        var copy = searchHistory.filter { $0.caseInsensitiveCompare(trimmed) != .orderedSame }
        copy.insert(trimmed, at: 0)
        searchHistory = Array(copy.prefix(8))
        flush()
    }

    func resetFilters() {
        regionFilter = nil
        categoryFilter = nil
        flush()
    }

    func favoriteTowers() -> [Tower] {
        towers.filter { favorites.contains($0.id) }
    }

    func tower(byId id: String) -> Tower? {
        towers.first { $0.id == id }
    }

    func featuredTower() -> Tower? {
        let pool = ["eiffel", "burj-khalifa", "tokyo-skytree", "shanghai-tower", "petronas"]
        if let pick = pool.randomElement(), let t = tower(byId: pick) { return t }
        return towers.first
    }

    func popularTowers(limit: Int = 6) -> [Tower] {
        towers.sorted { $0.height_m > $1.height_m }.prefix(limit).map { $0 }
    }

    func filtered(query: String) -> [Tower] {
        var pool = towers
        if let region = regionFilter {
            pool = pool.filter { $0.region == region }
        }
        if let cat = categoryFilter {
            pool = pool.filter { $0.category == cat }
        }
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !q.isEmpty {
            pool = pool.filter { $0.matches.contains(q) }
        }
        switch sort {
        case .popular: pool.sort { $0.height_m > $1.height_m }
        case .height:  pool.sort { $0.height_m > $1.height_m }
        case .recent:  pool.sort { $0.year > $1.year }
        case .az:      pool.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        }
        return pool
    }

    private func parseSet(_ raw: String) -> Set<String> {
        Set(parseList(raw))
    }

    private func parseList(_ raw: String) -> [String] {
        raw.split(separator: "|").map { String($0) }.filter { !$0.isEmpty }
    }

    private func encode(_ values: Set<String>) -> String {
        values.sorted().joined(separator: "|")
    }

    private func encode(_ values: [String]) -> String {
        values.joined(separator: "|")
    }
}
