import SwiftUI

enum TowerCategory: String, Codable, CaseIterable, Identifiable, Hashable {
    case famous
    case modern
    case historic
    case observation
    case record

    var id: String { rawValue }

    var titleKey: LocalizedStringKey {
        switch self {
        case .famous:      return "category.famous"
        case .modern:      return "category.modern"
        case .historic:    return "category.historic"
        case .observation: return "category.observation"
        case .record:      return "category.record"
        }
    }

    var symbol: String {
        switch self {
        case .famous:      return "star.fill"
        case .modern:      return "rectangle.portrait.fill"
        case .historic:    return "clock.fill"
        case .observation: return "binoculars.fill"
        case .record:      return "trophy.fill"
        }
    }

    var accent: Color {
        switch self {
        case .famous:      return AppColor.jackpotYellow
        case .modern:      return AppColor.skyBright
        case .historic:    return AppColor.stone
        case .observation: return AppColor.skyBase
        case .record:      return AppColor.warmOrange
        }
    }
}
