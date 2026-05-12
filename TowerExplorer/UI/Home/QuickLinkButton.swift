import SwiftUI

struct QuickLinkButton: View {
    let titleKey: LocalizedStringKey
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .heavy))
                Text(titleKey)
                    .font(.appCaption)
                    .lineLimit(1)
            }
            .foregroundStyle(AppColor.onYellow)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(AppColor.yellowGradient)
            .clipShape(Capsule())
            .shadow(color: AppColor.amber.opacity(0.85), radius: 0, y: 3)
            .shadow(color: AppColor.jackpotYellow.opacity(0.3), radius: 12, y: 0)
        }
        .buttonStyle(.plain)
    }
}
