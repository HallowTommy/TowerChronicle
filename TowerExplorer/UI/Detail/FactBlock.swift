import SwiftUI

struct FactBlock: View {
    let fact: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColor.jackpotYellow.opacity(0.34))
                    .frame(width: 44, height: 44)
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(AppColor.jackpotYellow)
                    .glowYellow(radius: 8)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(LocalizedStringKey("detail.fact"))
                    .font(.appLabel)
                    .foregroundStyle(AppColor.jackpotYellow)
                Text(fact)
                    .font(.appBody)
                    .foregroundStyle(AppColor.textOnNavy)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColor.surfaceRaised)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(AppColor.jackpotYellow.opacity(0.35), lineWidth: 1)
        )
    }
}
