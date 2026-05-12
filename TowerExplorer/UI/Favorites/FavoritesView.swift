import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var journal: TowerJournal
    @Environment(\.switchRootTab) private var switchTab

    private var favorites: [Tower] { journal.favoriteTowers() }

    var body: some View {
        Group {
            if favorites.isEmpty {
                EmptyState(symbol: "star",
                           titleKey: "favorites.empty.title",
                           subtitleKey: "favorites.empty.subtitle",
                           ctaKey: "favorites.empty.cta") {
                    switchTab(.explore)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(favorites) { tower in
                            NavigationLink {
                                TowerDetailView(tower: tower)
                            } label: {
                                FavoriteRow(tower: tower) {
                                    withAnimation(.bouncy(duration: 0.4, extraBounce: 0.2)) {
                                        journal.toggleFavorite(tower.id)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(AppColor.deepNavy.ignoresSafeArea())
        .navigationTitle(LocalizedStringKey("favorites.title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct FavoriteRow: View {
    let tower: Tower
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(tower.asset)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(tower.name)
                    .font(.appH3)
                    .foregroundStyle(AppColor.textOnNavy)
                    .lineLimit(2)
                Text("\(tower.city), \(tower.country)")
                    .font(.appCaption)
                    .foregroundStyle(AppColor.textSecondary)
                HStack(spacing: 8) {
                    Label("\(tower.heightString) m", systemImage: "ruler.fill")
                        .font(.appCaption)
                        .foregroundStyle(AppColor.jackpotYellow)
                    Label(tower.region.titleKey, systemImage: tower.region.symbol)
                        .font(.appCaption)
                        .foregroundStyle(tower.region.accent)
                }
            }
            Spacer(minLength: 0)
            Button(action: onRemove) {
                Image(systemName: "star.slash.fill")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(AppColor.danger)
                    .padding(10)
                    .background(AppColor.danger.opacity(0.12), in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .tileSurface(radius: 18)
    }
}
