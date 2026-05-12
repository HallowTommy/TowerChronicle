import SwiftUI

enum Region: String, Codable, CaseIterable, Identifiable, Hashable {
    case europe
    case asia
    case americas
    case africa
    case middleEast = "middle_east"

    var id: String { rawValue }

    var titleKey: LocalizedStringKey {
        switch self {
        case .europe:     return "region.europe"
        case .asia:       return "region.asia"
        case .americas:   return "region.americas"
        case .africa:     return "region.africa"
        case .middleEast: return "region.middle_east"
        }
    }

    var symbol: String {
        switch self {
        case .europe:     return "globe.europe.africa.fill"
        case .asia:       return "globe.asia.australia.fill"
        case .americas:   return "globe.americas.fill"
        case .africa:     return "globe.europe.africa.fill"
        case .middleEast: return "globe.central.south.asia.fill"
        }
    }

    var accent: Color {
        switch self {
        case .europe:     return AppColor.skyBase
        case .asia:       return AppColor.warmOrange
        case .americas:   return AppColor.skyBright
        case .africa:     return AppColor.stone
        case .middleEast: return AppColor.jackpotYellow
        }
    }
}
