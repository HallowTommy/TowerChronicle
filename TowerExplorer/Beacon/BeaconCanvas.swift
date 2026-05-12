import SwiftUI
@preconcurrency import WebKit

@MainActor
final class CanvasModel: NSObject, ObservableObject {
    @Published private(set) var canRetreat: Bool = false
    @Published private(set) var canAdvance: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var loadFraction: Double = 0

    let canvas: WKWebView
    let homeAnchor: URL

    private var kvoBag: [NSKeyValueObservation] = []
    private var reloadAttempts = 0
    private let reloadCeiling = 4

    init(homeAnchor: URL, headerAgent: String, sessionCookies: [HTTPCookie] = []) {
        self.homeAnchor = homeAnchor

        let setup = WKWebViewConfiguration()
        setup.allowsInlineMediaPlayback = true
        setup.mediaTypesRequiringUserActionForPlayback = []
        setup.websiteDataStore = .default()

        let wv = WKWebView(frame: .zero, configuration: setup)
        wv.allowsBackForwardNavigationGestures = true
        wv.scrollView.bounces = true
        wv.isOpaque = false
        wv.backgroundColor = .clear
        wv.scrollView.backgroundColor = .clear
        wv.customUserAgent = headerAgent
        self.canvas = wv

        super.init()

        wv.navigationDelegate = self
        kvoBag = [
            wv.observe(\.canGoBack, options: [.initial, .new]) { [weak self] wv, _ in
                Task { @MainActor in self?.canRetreat = wv.canGoBack }
            },
            wv.observe(\.canGoForward, options: [.initial, .new]) { [weak self] wv, _ in
                Task { @MainActor in self?.canAdvance = wv.canGoForward }
            },
            wv.observe(\.isLoading, options: [.initial, .new]) { [weak self] wv, _ in
                Task { @MainActor in self?.isLoading = wv.isLoading }
            },
            wv.observe(\.estimatedProgress, options: [.initial, .new]) { [weak self] wv, _ in
                Task { @MainActor in self?.loadFraction = wv.estimatedProgress }
            }
        ]

        BeaconLog.write("Canvas init target=\(homeAnchor.absoluteString) cookies=\(sessionCookies.count)")
        if sessionCookies.isEmpty {
            wv.load(URLRequest(url: homeAnchor))
        } else {
            let store = wv.configuration.websiteDataStore.httpCookieStore
            Task { @MainActor [weak self] in
                for cookie in sessionCookies {
                    BeaconLog.write("Canvas set cookie \(cookie.name) domain=\(cookie.domain)")
                    await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
                        store.setCookie(cookie) { cont.resume() }
                    }
                }
                BeaconLog.write("Canvas cookies set, loading")
                self?.canvas.load(URLRequest(url: homeAnchor))
            }
        }
    }

    deinit {
        kvoBag.forEach { $0.invalidate() }
    }

    func retreat() { canvas.goBack() }
    func advance() { canvas.goForward() }
    func reload() { canvas.reload() }
    func returnHome() { canvas.load(URLRequest(url: homeAnchor)) }

    nonisolated static func isRetryable(_ err: NSError) -> Bool {
        guard err.domain == NSURLErrorDomain else { return false }
        switch err.code {
        case NSURLErrorTimedOut,
             NSURLErrorNetworkConnectionLost,
             NSURLErrorNotConnectedToInternet,
             NSURLErrorDNSLookupFailed,
             NSURLErrorCannotConnectToHost,
             NSURLErrorCannotFindHost,
             NSURLErrorInternationalRoamingOff,
             NSURLErrorDataNotAllowed:
            return true
        default:
            return false
        }
    }

    private func scheduleRelaunch(reason: String) async {
        guard reloadAttempts < reloadCeiling else {
            BeaconLog.write("Canvas reload limit \(reloadAttempts)/\(reloadCeiling)")
            return
        }
        reloadAttempts += 1
        let waitSec = min(8, 1 << (reloadAttempts - 1))
        BeaconLog.write("Canvas reload #\(reloadAttempts) in \(waitSec)s — \(reason)")
        try? await Task.sleep(nanoseconds: UInt64(waitSec) * 1_000_000_000)
        if canvas.url == nil {
            canvas.load(URLRequest(url: homeAnchor))
        } else {
            canvas.reload()
        }
    }
}

extension CanvasModel: WKNavigationDelegate {
    func webView(_ wv: WKWebView, decidePolicyFor action: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard let target = action.request.url else { return .cancel }
        switch (target.scheme ?? "").lowercased() {
        case "tel", "mailto", "itms-apps", "itms-appss", "sms":
            await UIApplication.shared.open(target)
            return .cancel
        default:
            return .allow
        }
    }

    nonisolated func webView(_ wv: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        BeaconLog.write("Canvas start nav → \(wv.url?.absoluteString ?? "nil")")
    }

    nonisolated func webView(_ wv: WKWebView, didFinish navigation: WKNavigation!) {
        BeaconLog.write("Canvas finish nav → \(wv.url?.absoluteString ?? "nil")")
        Task { @MainActor [weak self] in self?.reloadAttempts = 0 }
    }

    nonisolated func webView(_ wv: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let nsErr = error as NSError
        BeaconLog.write("Canvas didFail \(nsErr.domain) \(nsErr.code) \(nsErr.localizedDescription)")
        if nsErr.domain == NSURLErrorDomain, nsErr.code == NSURLErrorCancelled { return }
        guard Self.isRetryable(nsErr) else { return }
        Task { @MainActor [weak self] in
            await self?.scheduleRelaunch(reason: "didFail \(nsErr.code)")
        }
    }

    nonisolated func webView(_ wv: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let nsErr = error as NSError
        BeaconLog.write("Canvas provisional fail \(nsErr.domain) \(nsErr.code) \(nsErr.localizedDescription)")
        if nsErr.domain == NSURLErrorDomain, nsErr.code == NSURLErrorCancelled { return }
        guard Self.isRetryable(nsErr) else { return }
        Task { @MainActor [weak self] in
            await self?.scheduleRelaunch(reason: "provisional \(nsErr.code)")
        }
    }
}

private struct BeaconShell: UIViewRepresentable {
    let canvas: WKWebView
    func makeUIView(context: Context) -> WKWebView { canvas }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct BeaconCanvas: View {
    @StateObject private var model: CanvasModel

    init(url: URL) {
        _model = StateObject(wrappedValue: CanvasModel(
            homeAnchor: url,
            headerAgent: BeaconCheck.shared.blueprint.headerAgent,
            sessionCookies: BeaconCheck.shared.sessionCookies
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                BeaconShell(canvas: model.canvas)
                    .ignoresSafeArea(edges: [.top, .horizontal])

                if model.isLoading {
                    GeometryReader { geo in
                        Rectangle()
                            .fill(AppColor.jackpotYellow)
                            .frame(width: geo.size.width * model.loadFraction, height: 2)
                            .animation(.easeInOut(duration: 0.2), value: model.loadFraction)
                    }
                    .frame(height: 2)
                    .ignoresSafeArea(edges: [.top, .horizontal])
                }
            }

            BeaconNavBar(model: model)
        }
        .background(AppColor.midnightNavy.ignoresSafeArea())
    }
}

private struct BeaconNavBar: View {
    @ObservedObject var model: CanvasModel

    var body: some View {
        HStack(spacing: 0) {
            navTap(symbol: "chevron.left", on: model.canRetreat) { model.retreat() }
            navTap(symbol: "chevron.right", on: model.canAdvance) { model.advance() }
            navTap(symbol: "house.fill", on: true, weight: .semibold) { model.returnHome() }
            navTap(symbol: "arrow.clockwise", on: true) { model.reload() }
        }
        .padding(.top, 10)
        .padding(.bottom, 4)
        .background(
            AppColor.midnightNavy.ignoresSafeArea(edges: .bottom)
        )
        .overlay(
            Rectangle().fill(AppColor.jackpotYellow.opacity(0.18)).frame(height: 0.5),
            alignment: .top
        )
    }

    @ViewBuilder
    private func navTap(symbol: String, on enabled: Bool, weight: Font.Weight = .regular, action: @escaping () -> Void) -> some View {
        Button(action: {
            switch enabled {
            case true:
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                action()
            case false:
                break
            }
        }) {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: weight))
                .foregroundStyle(enabled ? AppColor.textOnNavy.opacity(0.92) : AppColor.textOnNavy.opacity(0.25))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .contentShape(Rectangle())
        }
        .disabled(!enabled)
        .buttonStyle(.plain)
    }
}
