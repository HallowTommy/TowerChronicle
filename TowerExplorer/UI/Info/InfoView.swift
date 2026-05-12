import SwiftUI

struct InfoView: View {
    @State private var policyOpen: Bool = false

    private var version: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                aboutBlock
                actionsBlock
                creditsBlock
            }
            .padding(20)
            .padding(.bottom, 28)
        }
        .background(AppColor.deepNavy.ignoresSafeArea())
        .navigationTitle(LocalizedStringKey("info.title"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var aboutBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(AppColor.jackpotYellow.opacity(0.34))
                        .frame(width: 56, height: 56)
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundStyle(AppColor.jackpotYellow)
                        .glowYellow(radius: 6)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(LocalizedStringKey("app.tagline"))
                        .font(.appH2)
                        .foregroundStyle(AppColor.textOnNavy)
                }
                Spacer()
            }

            Text(LocalizedStringKey("info.about.body"))
                .font(.appBody)
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .tileSurface(radius: 18)
    }

    private var actionsBlock: some View {
        VStack(spacing: 0) {
            Button {
                policyOpen = true
            } label: {
                row(symbol: "lock.shield.fill", titleKey: "info.privacy", trailing: nil)
            }
            .buttonStyle(.plain)
            divider
            row(symbol: "info.circle.fill", titleKey: "info.version", trailing: version)
            divider
            Button {
                openSupportMail()
            } label: {
                row(symbol: "envelope.fill", titleKey: "info.support", trailing: nil)
            }
            .buttonStyle(.plain)
        }
        .tileSurface(radius: 18)
        .fullScreenCover(isPresented: $policyOpen) {
            PolicyShell(url: AppConfig.privacyPolicyURL)
        }
    }

    private var creditsBlock: some View {
        Text(LocalizedStringKey("info.credits"))
            .font(.appCaption)
            .foregroundStyle(AppColor.textMuted)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
    }

    private var divider: some View {
        Rectangle()
            .fill(AppColor.border)
            .frame(height: 1)
            .padding(.leading, 50)
    }

    private func row(symbol: String, titleKey: LocalizedStringKey, trailing: String?) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(AppColor.jackpotYellow)
                .frame(width: 28)
            Text(titleKey)
                .font(.appBody)
                .foregroundStyle(AppColor.textOnNavy)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.appCaption)
                    .foregroundStyle(AppColor.textSecondary)
                    .monospacedDigit()
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(AppColor.textMuted)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    private func openSupportMail() {
        let subject = NSLocalizedString("info.support.subject", comment: "")
        guard let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let mailto = "mailto:\(AppConfig.supportEmail)?subject=\(encodedSubject)"
        guard let url = URL(string: mailto) else { return }
        UIApplication.shared.open(url)
    }
}
