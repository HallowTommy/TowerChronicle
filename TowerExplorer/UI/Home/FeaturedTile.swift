import SwiftUI

struct FeaturedTile: View {
    let tower: Tower

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                Label("home.featured", systemImage: "sparkles")
                    .font(.appLabel)
                    .foregroundStyle(AppColor.jackpotYellow)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppColor.jackpotYellow.opacity(0.34), in: Capsule())

                Text(tower.name)
                    .font(.appH2)
                    .foregroundStyle(AppColor.textOnNavy)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 5) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(AppColor.skyBright)
                        .font(.system(size: 12, weight: .heavy))
                    Text("\(tower.city), \(tower.country)")
                        .font(.appCaption)
                        .foregroundStyle(AppColor.textSecondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                HStack(alignment: .lastTextBaseline, spacing: 5) {
                    Text(tower.heightString)
                        .font(.system(size: 36, weight: .black, design: .rounded).monospacedDigit())
                        .foregroundStyle(AppColor.jackpotYellow)
                        .glowYellow(radius: 10)
                    Text(LocalizedStringKey("detail.meters"))
                        .font(.appH3)
                        .foregroundStyle(AppColor.textOnNavy)
                }
            }
            .padding(.leading, 18)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(tower.asset)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 170)
                .frame(maxHeight: .infinity)
                .clipped()
        }
        .background(AppColor.heroGradient)
        .frame(height: 230)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(AppColor.skyDeep.opacity(0.9), lineWidth: 1)
        )
        .shadow(color: AppColor.midnightNavy.opacity(0.85), radius: 14, y: 6)
    }
}
