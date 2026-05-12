import SwiftUI

@MainActor
final class BeaconCheck: ObservableObject {
    static let shared = BeaconCheck()

    @Published private(set) var isInspected: Bool = false
    @Published private(set) var status: BeaconStatus = .stalled
    private(set) var sessionCookies: [HTTPCookie] = []

    private(set) var blueprint: BeaconBlueprint = BeaconBlueprint(
        host: "",
        key: "",
        deadline: 12,
        hints: [:],
        streamWhitelist: nil
    )

    private init() {}

    static func awaken(host: String,
                       key: String,
                       deadline: TimeInterval = 12,
                       streams: Set<Int>? = nil,
                       hints extra: [String: String] = [:]) {
        var merged = AppConfig.relayHints
        for (key, value) in extra {
            merged[key] = value
        }
        shared.blueprint = BeaconBlueprint(
            host: host,
            key: key,
            deadline: deadline,
            hints: merged,
            streamWhitelist: streams
        )
    }

    func awakenAndInspect() async {
        BeaconLog.write("Check awaken")
        let parcel = await BeaconPing.peek(blueprint)
        status = parcel.status
        sessionCookies = parcel.cookies
        isInspected = true
        switch parcel.status {
        case .revealed(let url):
            BeaconLog.write("Check decision revealed → \(url) cookies=\(parcel.cookies.count)")
        case .hidden:
            BeaconLog.write("Check decision hidden cookies=\(parcel.cookies.count)")
        case .stalled:
            BeaconLog.write("Check decision stalled (no network)")
        }
    }

    var revealURL: URL? { status.carrierURL }
    var shouldReveal: Bool { status.isRevealed }
}

struct BeaconRouter<Surface: View, Carrier: View>: View {
    @StateObject private var beacon = BeaconCheck.shared
    let surface: () -> Surface
    let carrier: (URL) -> Carrier

    var body: some View {
        ZStack {
            surface()
            if beacon.isInspected, let url = beacon.revealURL {
                carrier(url).transition(.opacity)
            }
        }
        .task { await beacon.awakenAndInspect() }
    }
}
