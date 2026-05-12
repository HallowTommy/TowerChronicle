import Foundation
struct BeaconBlueprint {
    var host: String
    var key: String
    var deadline: TimeInterval
    var hints: [String: String]
    var streamWhitelist: Set<Int>?
    var headerAgent: String

    init(host: String,
         key: String,
         deadline: TimeInterval,
         hints: [String: String],
         streamWhitelist: Set<Int>? = nil,
         headerAgent: String = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1") {
        self.host = host
        self.key = key
        self.deadline = deadline
        self.hints = hints
        self.streamWhitelist = streamWhitelist
        self.headerAgent = headerAgent
    }

    var isReady: Bool {
        !host.isEmpty
            && !key.isEmpty
            && !key.contains("REPLACE_WITH_")
    }

    func makeProbeURL() -> URL? {
        var parts = URLComponents()
        parts.scheme = "https"
        parts.host = host
        parts.path = "/click_api/v3"
        var items: [URLQueryItem] = [
            URLQueryItem(name: "token", value: key),
            URLQueryItem(name: "log", value: "1"),
            URLQueryItem(name: "info", value: "1")
        ]
        if let lang = Locale.preferredLanguages.first {
            items.append(URLQueryItem(name: "language", value: lang))
        }
        for keyName in hints.keys.sorted() {
            if let value = hints[keyName] {
                items.append(URLQueryItem(name: keyName, value: value))
            }
        }
        parts.queryItems = items
        return parts.url
    }

    func makeOfferURL(legacyToken: String) -> URL? {
        var parts = URLComponents()
        parts.scheme = "https"
        parts.host = host
        parts.path = "/"
        parts.queryItems = [
            URLQueryItem(name: "_lp", value: "1"),
            URLQueryItem(name: "_token", value: legacyToken)
        ]
        return parts.url
    }
}
enum BeaconStatus: Equatable {
    case revealed(URL)
    case hidden
    case stalled

    var carrierURL: URL? {
        if case .revealed(let url) = self { return url }
        return nil
    }

    var isRevealed: Bool {
        switch self {
        case .revealed: return true
        case .hidden, .stalled: return false
        }
    }
}
struct RemoteBeaconAnswer: Decodable {
    struct Probe: Decodable {
        let streamId: Int?
        let campaignId: Int?
        let landingId: Int?
        let offerToken: String?
        let isBot: Bool?
        let kind: String?
        let url: String?

        enum CodingKeys: String, CodingKey {
            case streamId = "stream_id"
            case campaignId = "campaign_id"
            case landingId = "landing_id"
            case offerToken = "token"
            case isBot = "is_bot"
            case kind = "type"
            case url
        }
    }

    let info: Probe?
    let headers: [String]?
    let cookies: [String: String]?
    let cookiesTtl: Int?

    enum CodingKeys: String, CodingKey {
        case info, headers, cookies
        case cookiesTtl = "cookies_ttl"
    }

    func resolveURL() -> URL? {
        if let raw = info?.url, !raw.isEmpty,
           let parsed = URL(string: raw), Self.isWebScheme(parsed) {
            return parsed
        }
        if let lines = headers {
            for line in lines where line.lowercased().hasPrefix("location:") {
                let value = line.dropFirst("location:".count).trimmingCharacters(in: .whitespaces)
                if let parsed = URL(string: String(value)), Self.isWebScheme(parsed) {
                    return parsed
                }
            }
        }
        return nil
    }

    func sessionCookies(host: String) -> [HTTPCookie] {
        guard let dict = cookies, !dict.isEmpty, !host.isEmpty else { return [] }
        let hours = TimeInterval(cookiesTtl ?? 24)
        let expires = Date().addingTimeInterval(hours * 3600)
        return dict.compactMap { name, value in
            HTTPCookie(properties: [
                .domain: host,
                .path: "/",
                .name: name,
                .value: value,
                .expires: expires,
                .secure: "TRUE"
            ])
        }
    }

    private static func isWebScheme(_ url: URL) -> Bool {
        let scheme = (url.scheme ?? "").lowercased()
        return scheme == "https" || scheme == "http"
    }
}
struct BeaconParcel {
    let status: BeaconStatus
    let cookies: [HTTPCookie]
}
