import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var journal: TowerJournal
    @Environment(\.switchRootTab) private var switchTab
    @State private var detailTower: Tower? = nil
    let navigateToTab: (RootTab) -> Void

    private var featured: Tower? { journal.featuredTower() }
    private var popular: [Tower] { journal.popularTowers(limit: 8) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header

                if let featured {
                    NavigationLink {
                        TowerDetailView(tower: featured)
                    } label: {
                        FeaturedTile(tower: featured)
                    }
                    .buttonStyle(.plain)
                }

                quickLinks

                popularSection
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 40)
        }
        .background(AppColor.deepNavy.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(LocalizedStringKey("app.tagline"))
                .font(.appHero)
                .foregroundStyle(AppColor.textOnNavy)
        }
        .padding(.top, 8)
    }

    private var quickLinks: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            QuickLinkButton(titleKey: "home.quick.famous", symbol: "star.fill") {
                journal.categoryFilter = .famous
                journal.flush()
                navigateToTab(.explore)
            }
            QuickLinkButton(titleKey: "home.quick.cities", symbol: "building.2.crop.circle.fill") {
                journal.regionFilter = nil
                journal.categoryFilter = nil
                journal.flush()
                navigateToTab(.explore)
            }
            QuickLinkButton(titleKey: "home.quick.favorites", symbol: "heart.fill") {
                navigateToTab(.favorites)
            }
            QuickLinkButton(titleKey: "home.quick.map", symbol: "map.fill") {
                navigateToTab(.map)
            }
        }
    }

    private var popularSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(LocalizedStringKey("home.popular"))
                    .font(.appH2)
                    .foregroundStyle(AppColor.textOnNavy)
                Spacer()
                Button {
                    navigateToTab(.explore)
                } label: {
                    HStack(spacing: 4) {
                        Text(LocalizedStringKey("home.see_all"))
                            .font(.appCaption)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .heavy))
                    }
                    .foregroundStyle(AppColor.skyBright)
                }
                .buttonStyle(.plain)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(popular) { tower in
                        NavigationLink {
                            TowerDetailView(tower: tower)
                        } label: {
                            PopularTile(tower: tower, isFavorite: journal.isFavorited(tower.id))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

private struct PopularTile: View {
    let tower: Tower
    let isFavorite: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                Image(tower.asset)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                if isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(AppColor.jackpotYellow)
                        .padding(8)
                        .background(AppColor.midnightNavy.opacity(0.55), in: Circle())
                        .padding(6)
                        .glowYellow(radius: 6)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(tower.name)
                    .font(.appH3)
                    .foregroundStyle(AppColor.textOnNavy)
                    .lineLimit(2)
                    .frame(height: 42, alignment: .topLeading)
                Text("\(tower.city) · \(tower.heightString) m")
                    .font(.appCaption)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .padding(10)
        .frame(width: 178)
        .tileSurface(radius: 18)
    }
}
