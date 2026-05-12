import SwiftUI

@main
struct TowerExplorerApp: App {
    @StateObject private var journal = TowerJournal()

    init() {
        BeaconCheck.awaken(host: AppConfig.relayHost,
                           key: AppConfig.relayKey,
                           deadline: AppConfig.relayWindow,
                           streams: AppConfig.relayTargets)
        configureChrome()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(journal)
                .preferredColorScheme(.dark)
                .task { journal.pull() }
        }
    }

    private func configureChrome() {
        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = UIColor(AppColor.deepNavy)
        nav.shadowColor = .clear
        nav.titleTextAttributes = [.foregroundColor: UIColor(AppColor.textOnNavy)]
        nav.largeTitleTextAttributes = [.foregroundColor: UIColor(AppColor.textOnNavy)]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav

        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = UIColor(AppColor.surfacePanel)
        tab.shadowColor = UIColor(AppColor.deepNavy.opacity(0.4))
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
    }
}
