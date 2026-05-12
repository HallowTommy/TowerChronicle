import SwiftUI

enum AppColor {
    static let deepNavy = Color(hex: 0x143657)
    static let midnightNavy = Color(hex: 0x0C2440)
    static let surfacePanel = Color(hex: 0x1F4D78)
    static let surfaceRaised = Color(hex: 0x2B6498)
    static let border = Color(hex: 0x4A82B8)
    static let borderSoft = Color(hex: 0x6FA0CC)

    static let skyBase = Color(hex: 0x00C8FF)
    static let skyBright = Color(hex: 0x4FD3FF)
    static let skyDeep = Color(hex: 0x0094CC)
    static let skyDeeper = Color(hex: 0x005C82)

    static let jackpotYellow = Color(hex: 0xFDD84A)
    static let jackpotBright = Color(hex: 0xFFE76A)
    static let warmOrange = Color(hex: 0xF6A324)
    static let amber = Color(hex: 0xE0801A)

    static let cream = Color(hex: 0xFFF6D6)
    static let stone = Color(hex: 0xE8C887)

    static let onYellow = Color(hex: 0x1A0F00)
    static let textOnNavy = Color(hex: 0xF5FBFF)
    static let textSecondary = Color(hex: 0xC7E0F2)
    static let textMuted = Color(hex: 0x8FA8BD)

    static let success = Color(hex: 0x56C978)
    static let danger = Color(hex: 0xE8553D)

    static let skyGradient = LinearGradient(
        colors: [Color(hex: 0x00C8FF), Color(hex: 0x4FD3FF), Color(hex: 0xCFEEFF)],
        startPoint: .top, endPoint: .bottom
    )

    static let nightGradient = LinearGradient(
        colors: [Color(hex: 0x143657), Color(hex: 0x1F4D78), Color(hex: 0x2B6498)],
        startPoint: .top, endPoint: .bottom
    )

    static let yellowGradient = LinearGradient(
        colors: [Color(hex: 0xFDD84A), Color(hex: 0xF6A324)],
        startPoint: .top, endPoint: .bottom
    )

    static let panelGradient = LinearGradient(
        colors: [Color(hex: 0x2B6498), Color(hex: 0x1F4D78)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let heroGradient = LinearGradient(
        colors: [Color(hex: 0x005C82), Color(hex: 0x00C8FF), Color(hex: 0xFDD84A).opacity(0.45)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: alpha)
    }
}
