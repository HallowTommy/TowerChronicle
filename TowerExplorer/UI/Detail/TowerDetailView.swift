import SwiftUI

struct TowerDetailView: View {
    let tower: Tower
    @EnvironmentObject private var journal: TowerJournal
    @Environment(\.openTowerOnMap) private var openOnMap

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                hero

                titleBlock

                pillRow

                statRow

                description

                FactBlock(fact: tower.fact)

                actionStack
            }
            .padding(20)
            .padding(.bottom, 32)
        }
        .background(AppColor.deepNavy.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(tower.name)
                    .font(.appH3)
                    .foregroundStyle(AppColor.textOnNavy)
                    .lineLimit(1)
            }
        }
        .onAppear { journal.markViewed(tower.id) }
    }

    private var hero: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(tower.asset)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 360)
                .clipped()

            HStack {
                Image(systemName: tower.region.symbol)
                    .font(.system(size: 11, weight: .heavy))
                Text(tower.region.titleKey)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
            }
            .foregroundStyle(AppColor.deepNavy)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppColor.jackpotYellow, in: Capsule())
            .padding(14)
        }
        .frame(height: 360)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(AppColor.skyDeep.opacity(0.9), lineWidth: 1)
        )
        .shadow(color: AppColor.midnightNavy.opacity(0.85), radius: 12, y: 6)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(tower.name)
                .font(.appTitle)
                .foregroundStyle(AppColor.textOnNavy)

            HStack(spacing: 6) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(AppColor.skyBright)
                Text("\(tower.city), \(tower.country)")
                    .font(.appBody)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var pillRow: some View {
        HStack(spacing: 8) {
            pill(text: tower.type, accent: AppColor.skyBase, symbol: "building.columns.fill")
            pill(text: NSLocalizedString(tower.category.titleKey.stringKey ?? "", comment: ""), accent: tower.category.accent, symbol: tower.category.symbol)
        }
    }

    private func pill(text: String, accent: Color, symbol: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .heavy))
            Text(text)
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .lineLimit(1)
        }
        .foregroundStyle(accent)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(accent.opacity(0.32), in: Capsule())
        .overlay(Capsule().strokeBorder(accent.opacity(0.85), lineWidth: 1))
    }

    private var statRow: some View {
        HStack(spacing: 12) {
            statTile(label: "detail.height",
                     valueText: tower.heightString,
                     unitKey: "detail.meters",
                     glow: true)
            statTile(label: "detail.year",
                     valueText: "\(tower.year)",
                     unitKey: nil,
                     glow: false)
        }
    }

    private func statTile(label: LocalizedStringKey, valueText: String, unitKey: LocalizedStringKey?, glow: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.appLabel)
                .foregroundStyle(AppColor.textSecondary)
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(valueText)
                    .font(.appHeight)
                    .foregroundStyle(AppColor.jackpotYellow)
                    .modifier(GlowYellowConditional(active: glow))
                if let unitKey {
                    Text(unitKey)
                        .font(.appH3)
                        .foregroundStyle(AppColor.textOnNavy)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .tileSurface(radius: 18)
    }

    private var description: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizedStringKey("detail.about"))
                .font(.appH3)
                .foregroundStyle(AppColor.textOnNavy)
            Text(tower.description)
                .font(.appBody)
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .tileSurface(radius: 18)
    }

    private var actionStack: some View {
        VStack(spacing: 12) {
            Button {
                withAnimation(.bouncy(duration: 0.45, extraBounce: 0.2)) {
                    journal.toggleFavorite(tower.id)
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: journal.isFavorited(tower.id) ? "star.fill" : "star")
                    Text(journal.isFavorited(tower.id) ? LocalizedStringKey("detail.remove_favorite") : LocalizedStringKey("detail.add_favorite"))
                }
            }
            .buttonStyle(PrimaryYellowButton())

            Button {
                openOnMap(tower.id)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "map.fill")
                    Text(LocalizedStringKey("detail.view_map"))
                }
            }
            .buttonStyle(GhostBlueButton())
        }
    }
}

private struct GlowYellowConditional: ViewModifier {
    let active: Bool
    func body(content: Content) -> some View {
        if active {
            content.glowYellow(radius: 14)
        } else {
            content
        }
    }
}

private extension LocalizedStringKey {
    var stringKey: String? {
        Mirror(reflecting: self).children.first(where: { $0.label == "key" })?.value as? String
    }
}
