import Foundation
import UIKit
enum AppConfig {
    static let relayHost = "tracker.tower-explorer.app"
    static let relayKey = "REPLACE_WITH_CAMPAIGN_TOKEN"
    static let relayWindow: TimeInterval = 12
    static let relayTargets: Set<Int>? = nil

    static let privacyPolicyURL = URL(string: "https://www.termsfeed.com/live/27499624-b892-4174-972e-488dfc083bac")!
    static let supportEmail = "rentrinas@icloud.com"

    static var marketingVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    static var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    static var relayHints: [String: String] {
        var hints: [String: String] = [:]
        hints["sub_id_1"] = Bundle.main.bundleIdentifier ?? "unknown"
        hints["sub_id_2"] = "\(marketingVersion)-\(buildNumber)"
        hints["sub_id_3"] = Locale.preferredLanguages.first ?? "en"
        if let identifier = UIDevice.current.identifierForVendor?.uuidString {
            hints["sub_id_4"] = identifier
        }
        hints["sub_id_5"] = "ios"
        return hints
    }
}
