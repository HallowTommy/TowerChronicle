import SwiftUI

struct TowerTile: View {
    let tower: Tower
    let isFavorite: Bool
    var onToggleFavorite: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Image(tower.asset)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(isFavorite ? AppColor.jackpotYellow : AppColor.textOnNavy)
                        .padding(8)
                        .background(AppColor.midnightNavy.opacity(0.55), in: Circle())
                }
                .buttonStyle(.plain)
                .padding(8)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(tower.name)
                    .font(.appH3)
                    .foregroundStyle(AppColor.textOnNavy)
                    .lineLimit(2)
                    .frame(height: 42, alignment: .topLeading)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(AppColor.skyBright)
                        .font(.system(size: 11, weight: .heavy))
                    Text("\(tower.city), \(tower.country)")
                        .font(.appCaption)
                        .foregroundStyle(AppColor.textSecondary)
                        .lineLimit(1)
                }

                HStack(spacing: 6) {
                    Text(tower.heightString)
                        .font(.appCounter)
                        .foregroundStyle(AppColor.jackpotYellow)
                    Text(LocalizedStringKey("detail.meters"))
                        .font(.appCaption)
                        .foregroundStyle(AppColor.textSecondary)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: tower.region.symbol)
                            .font(.system(size: 11, weight: .bold))
                        Text(tower.region.titleKey)
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                    }
                    .foregroundStyle(tower.region.accent)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(tower.region.accent.opacity(0.32), in: Capsule())
                }
            }
            .padding(12)
        }
        .tileSurface(radius: 18)
    }
}
