import Foundation
import CoreLocation

struct Tower: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let city: String
    let country: String
    let region: Region
    let category: TowerCategory
    let height_m: Int
    let year: Int
    let type: String
    let description: String
    let fact: String
    let lat: Double
    let lon: Double
    let asset: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var heightString: String {
        "\(height_m)"
    }

    var matches: String {
        "\(name) \(city) \(country)".lowercased()
    }
}
