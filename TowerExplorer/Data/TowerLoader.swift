import Foundation

enum TowerLoader {
    static func load() -> [Tower] {
        guard let url = Bundle.main.url(forResource: "towers", withExtension: "json") else {
            return []
        }
        guard let data = try? Data(contentsOf: url) else { return [] }
        let decoder = JSONDecoder()
        guard let list = try? decoder.decode([Tower].self, from: data) else { return [] }
        return list
    }
}
