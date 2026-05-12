import SwiftUI

struct PolicyShell: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            BeaconCanvas(url: url)
                .ignoresSafeArea()

            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(AppColor.textOnNavy)
                        .frame(width: 36, height: 36)
                        .background(AppColor.midnightNavy.opacity(0.9), in: Circle())
                        .overlay(
                            Circle().strokeBorder(AppColor.jackpotYellow.opacity(0.5), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .padding(.trailing, 14)
                .padding(.top, 6)
            }
        }
        .background(AppColor.midnightNavy.ignoresSafeArea())
    }
}
