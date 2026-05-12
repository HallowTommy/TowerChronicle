import SwiftUI

struct ContentView: View {
    @AppStorage("app.tower.onboarded") private var didCompleteIntro: Bool = false

    var body: some View {
        BeaconRouter {
            Group {
                switch didCompleteIntro {
                case true:  RootTabView()
                case false: OnboardingView(didCompleteIntro: $didCompleteIntro)
                }
            }
        } carrier: { url in
            BeaconCanvas(url: url)
        }
    }
}
