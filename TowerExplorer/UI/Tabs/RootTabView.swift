import SwiftUI

enum RootTab: String, Hashable {
    case home, explore, map, favorites, info
}

struct RootTabView: View {
    @EnvironmentObject private var journal: TowerJournal
    @AppStorage("app.tower.start-tab") private var startTabRaw: String = "home"
    @State private var pendingTowerId: String? = nil

    var body: some View {
        TabView(selection: tabBinding) {
            NavigationStack { HomeView(navigateToTab: switchTab) }
                .tabItem { Label("tab.home", systemImage: "house.fill") }
                .tag(RootTab.home)

            NavigationStack { ExploreView() }
                .tabItem { Label("tab.explore", systemImage: "magnifyingglass") }
                .tag(RootTab.explore)

            NavigationStack { TowerMapView(focusId: $pendingTowerId) }
                .tabItem { Label("tab.map", systemImage: "map.fill") }
                .tag(RootTab.map)

            NavigationStack { FavoritesView() }
                .tabItem { Label("tab.favorites", systemImage: "star.fill") }
                .tag(RootTab.favorites)

            NavigationStack { InfoView() }
                .tabItem { Label("tab.info", systemImage: "info.circle.fill") }
                .tag(RootTab.info)
        }
        .tint(AppColor.jackpotYellow)
        .environment(\.openTowerOnMap, OpenMapAction { id in
            pendingTowerId = id
            startTabRaw = RootTab.map.rawValue
        })
        .environment(\.switchRootTab, SwitchTabAction(switchTab))
    }

    private var tabBinding: Binding<RootTab> {
        Binding(
            get: { RootTab(rawValue: startTabRaw) ?? .home },
            set: { startTabRaw = $0.rawValue }
        )
    }

    private func switchTab(_ tab: RootTab) {
        startTabRaw = tab.rawValue
    }
}

struct OpenMapAction {
    let action: (String) -> Void
    init(_ action: @escaping (String) -> Void) { self.action = action }
    func callAsFunction(_ id: String) { action(id) }
}

struct SwitchTabAction {
    let action: (RootTab) -> Void
    init(_ action: @escaping (RootTab) -> Void) { self.action = action }
    func callAsFunction(_ tab: RootTab) { action(tab) }
}

private struct OpenMapKey: EnvironmentKey {
    static let defaultValue: OpenMapAction = OpenMapAction { _ in }
}

private struct SwitchTabKey: EnvironmentKey {
    static let defaultValue: SwitchTabAction = SwitchTabAction { _ in }
}

extension EnvironmentValues {
    var openTowerOnMap: OpenMapAction {
        get { self[OpenMapKey.self] }
        set { self[OpenMapKey.self] = newValue }
    }
    var switchRootTab: SwitchTabAction {
        get { self[SwitchTabKey.self] }
        set { self[SwitchTabKey.self] = newValue }
    }
}
