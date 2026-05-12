import SwiftUI

struct EmptyState: View {
    let symbol: String
    let titleKey: LocalizedStringKey
    let subtitleKey: LocalizedStringKey
    var ctaKey: LocalizedStringKey? = nil
    var ctaAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(AppColor.jackpotYellow.opacity(0.34))
                    .frame(width: 130, height: 130)
                Image(systemName: symbol)
                    .font(.system(size: 56, weight: .heavy))
                    .foregroundStyle(AppColor.jackpotYellow)
                    .glowYellow(radius: 10)
            }
            VStack(spacing: 8) {
                Text(titleKey)
                    .font(.appH2)
                    .foregroundStyle(AppColor.textOnNavy)
                    .multilineTextAlignment(.center)
                Text(subtitleKey)
                    .font(.appBody)
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            if let ctaKey, let ctaAction {
                Button(ctaKey, action: ctaAction)
                    .buttonStyle(PrimaryYellowButton())
                    .padding(.horizontal, 60)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 60)
    }
}
