import SwiftUI

extension Font {
    static let appHero       = Font.system(size: 34, weight: .heavy, design: .rounded)
    static let appTitle      = Font.system(size: 26, weight: .heavy, design: .rounded)
    static let appH2         = Font.system(size: 20, weight: .heavy, design: .rounded)
    static let appH3         = Font.system(size: 17, weight: .bold, design: .rounded)
    static let appBody       = Font.system(size: 15, weight: .medium, design: .rounded)
    static let appCaption    = Font.system(size: 13, weight: .semibold, design: .rounded)
    static let appLabel      = Font.system(size: 11, weight: .heavy, design: .rounded)
    static let appHeight     = Font.system(size: 44, weight: .black, design: .rounded).monospacedDigit()
    static let appHeightLg   = Font.system(size: 64, weight: .black, design: .rounded).monospacedDigit()
    static let appCounter    = Font.system(size: 20, weight: .bold, design: .rounded).monospacedDigit()
}

struct GlowYellow: ViewModifier {
    var radius: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .shadow(color: AppColor.jackpotYellow.opacity(0.85), radius: radius, y: 0)
            .shadow(color: AppColor.jackpotYellow.opacity(0.35), radius: radius * 1.7, y: 0)
    }
}

struct TileSurface: ViewModifier {
    var radius: CGFloat = 20
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(AppColor.panelGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(AppColor.border, lineWidth: 1.5)
            )
            .shadow(color: AppColor.midnightNavy.opacity(0.85), radius: 8, y: 4)
    }
}

struct PrimaryYellowButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appH3)
            .foregroundStyle(AppColor.onYellow)
            .padding(.horizontal, 26)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(AppColor.yellowGradient)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(AppColor.amber.opacity(0.85), lineWidth: 1.5)
            )
            .shadow(color: AppColor.amber.opacity(0.85), radius: 0, y: 4)
            .shadow(color: AppColor.jackpotYellow.opacity(0.35), radius: 14, y: 0)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.bouncy(duration: 0.4, extraBounce: 0.2), value: configuration.isPressed)
    }
}

struct GhostBlueButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appH3)
            .foregroundStyle(AppColor.textOnNavy)
            .padding(.horizontal, 22)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(AppColor.surfaceRaised)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(AppColor.skyDeep.opacity(0.9), lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.bouncy(duration: 0.4, extraBounce: 0.2), value: configuration.isPressed)
    }
}

extension View {
    func glowYellow(radius: CGFloat = 16) -> some View { modifier(GlowYellow(radius: radius)) }
    func tileSurface(radius: CGFloat = 20) -> some View { modifier(TileSurface(radius: radius)) }
}
