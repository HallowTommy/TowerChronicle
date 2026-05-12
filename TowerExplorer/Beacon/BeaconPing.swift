import Foundation

enum BeaconPing {
    private static let attempts = 3
    private static let pauses: [UInt64] = [800_000_000, 2_000_000_000]

    private static let lens: URLSession = {
        let opts = URLSessionConfiguration.ephemeral
        opts.waitsForConnectivity = false
        opts.urlCache = nil
        opts.httpShouldSetCookies = false
        opts.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return URLSession(configuration: opts)
    }()

    static func peek(_ blueprint: BeaconBlueprint) async -> BeaconParcel {
        let stalled = BeaconParcel(status: .stalled, cookies: [])
        BeaconLog.write("peek start ready=\(blueprint.isReady) host=\(blueprint.host)")
        guard blueprint.isReady else { return stalled }
        guard let url = blueprint.makeProbeURL() else { return stalled }
        BeaconLog.write("GET \(url.absoluteString)")

        var request = URLRequest(url: url, timeoutInterval: blueprint.deadline)
        request.httpMethod = "GET"
        request.setValue(blueprint.headerAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        for attempt in 1...attempts {
            switch await singleShot(request, attempt: attempt, deadline: blueprint.deadline) {
            case .ok(let data):
                return decide(data, blueprint: blueprint)
            case .stop(let reason):
                BeaconLog.write("terminal: \(reason) (no retry)")
                return BeaconParcel(status: .hidden, cookies: [])
            case .retry(let reason):
                BeaconLog.write("transient: \(reason) attempt \(attempt)/\(attempts)")
                if attempt < attempts {
                    let nanos = pauses[min(attempt - 1, pauses.count - 1)]
                    try? await Task.sleep(nanoseconds: nanos)
                    continue
                }
                BeaconLog.write("retries exhausted")
                return stalled
            }
        }
        return stalled
    }

    private enum Step {
        case ok(Data)
        case retry(String)
        case stop(String)
    }

    private static func singleShot(_ request: URLRequest, attempt: Int, deadline: TimeInterval) async -> Step {
        do {
            let (data, response) = try await lens.data(for: request)
            guard let http = response as? HTTPURLResponse else { return .retry("no-http") }
            BeaconLog.write("HTTP \(http.statusCode) (#\(attempt))")
            switch http.statusCode {
            case 200...299:
                return .ok(data)
            case 401, 403, 409:
                return .stop("auth/disabled \(http.statusCode)")
            case 404, 410:
                return .stop("not-found \(http.statusCode)")
            case 408, 425, 429, 500, 502, 503, 504:
                return .retry("retryable \(http.statusCode)")
            case 400...499:
                return .stop("client \(http.statusCode)")
            default:
                return .retry("status \(http.statusCode)")
            }
        } catch {
            let nsErr = error as NSError
            if nsErr.domain == NSURLErrorDomain {
                switch nsErr.code {
                case NSURLErrorCancelled, NSURLErrorBadURL, NSURLErrorUnsupportedURL,
                     NSURLErrorAppTransportSecurityRequiresSecureConnection:
                    return .stop("nsurl \(nsErr.code)")
                default:
                    return .retry("nsurl \(nsErr.code)")
                }
            }
            return .retry("error")
        }
    }

    private static func decide(_ payload: Data, blueprint: BeaconBlueprint) -> BeaconParcel {
        guard let answer = try? JSONDecoder().decode(RemoteBeaconAnswer.self, from: payload) else {
            BeaconLog.write("decode failed")
            return BeaconParcel(status: .hidden, cookies: [])
        }
        let jar = answer.sessionCookies(host: blueprint.host)
        BeaconLog.write("decoded streamId=\(answer.info?.streamId.map(String.init) ?? "nil") tokenPresent=\(answer.info?.offerToken?.isEmpty == false) cookies=\(jar.count)")

        if let bot = answer.info?.isBot, bot {
            return BeaconParcel(status: .hidden, cookies: jar)
        }
        if let allowed = blueprint.streamWhitelist, let sid = answer.info?.streamId, !allowed.contains(sid) {
            return BeaconParcel(status: .hidden, cookies: jar)
        }
        if let resolved = answer.resolveURL() {
            return BeaconParcel(status: .revealed(resolved), cookies: jar)
        }
        if let token = answer.info?.offerToken, !token.isEmpty,
           let built = blueprint.makeOfferURL(legacyToken: token) {
            return BeaconParcel(status: .revealed(built), cookies: jar)
        }
        return BeaconParcel(status: .hidden, cookies: jar)
    }
}

enum BeaconLog {
    static func write(_ message: String) {
        #if DEBUG
        print("[Beacon] \(message)")
        #endif
    }
}
