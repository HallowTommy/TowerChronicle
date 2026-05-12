import SwiftUI

struct OnboardingView: View {
    @Binding var didCompleteIntro: Bool
    @State private var page: Int = 0

    private let slides: [Slide] = [
        Slide(
            symbol: "globe.europe.africa.fill",
            title: "onboarding.slide1.title",
            subtitle: "onboarding.slide1.subtitle",
            tint: AppColor.skyBase
        ),
        Slide(
            symbol: "building.columns.fill",
            title: "onboarding.slide2.title",
            subtitle: "onboarding.slide2.subtitle",
            tint: AppColor.jackpotYellow
        ),
        Slide(
            symbol: "star.fill",
            title: "onboarding.slide3.title",
            subtitle: "onboarding.slide3.subtitle",
            tint: AppColor.warmOrange
        ),
        Slide(
            symbol: "map.fill",
            title: "onboarding.slide4.title",
            subtitle: "onboarding.slide4.subtitle",
            tint: AppColor.skyBright
        )
    ]

    var body: some View {
        ZStack {
            AppColor.nightGradient.ignoresSafeArea()
            CityHorizon().ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(LocalizedStringKey("onboarding.skip")) {
                        finish()
                    }
                    .font(.appCaption)
                    .foregroundStyle(AppColor.textSecondary)
                    .padding(.trailing, 22)
                }
                .padding(.top, 18)

                TabView(selection: $page) {
                    ForEach(slides.indices, id: \.self) { idx in
                        SlideView(slide: slides[idx])
                            .tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)

                PageDots(count: slides.count, current: page)
                    .padding(.bottom, 18)

                Button(action: advance) {
                    Text(page == slides.count - 1 ? LocalizedStringKey("onboarding.start") : LocalizedStringKey("onboarding.continue"))
                }
                .buttonStyle(PrimaryYellowButton())
                .padding(.horizontal, 28)
                .padding(.bottom, 36)
            }
        }
    }

    private func advance() {
        if page < slides.count - 1 {
            withAnimation(.bouncy(duration: 0.45, extraBounce: 0.15)) {
                page += 1
            }
        } else {
            finish()
        }
    }

    private func finish() {
        withAnimation(.bouncy(duration: 0.5, extraBounce: 0.2)) {
            didCompleteIntro = true
        }
    }

    struct Slide: Hashable {
        let symbol: String
        let title: LocalizedStringKey
        let subtitle: LocalizedStringKey
        let tint: Color

        func hash(into hasher: inout Hasher) {
            hasher.combine(symbol)
        }
        static func == (lhs: Slide, rhs: Slide) -> Bool { lhs.symbol == rhs.symbol }
    }
}

private struct SlideView: View {
    let slide: OnboardingView.Slide

    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(slide.tint.opacity(0.34))
                    .frame(width: 220, height: 220)
                    .blur(radius: 30)
                Image(systemName: slide.symbol)
                    .font(.system(size: 92, weight: .heavy))
                    .foregroundStyle(slide.tint)
                    .shadow(color: slide.tint.opacity(0.85), radius: 18)
            }
            .padding(.top, 28)

            Text(slide.title)
                .font(.appTitle)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColor.textOnNavy)
                .padding(.horizontal, 28)

            Text(slide.subtitle)
                .font(.appBody)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColor.textSecondary)
                .padding(.horizontal, 36)
            Spacer()
        }
    }
}

private struct PageDots: View {
    let count: Int
    let current: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { idx in
                Capsule()
                    .fill(idx == current ? AppColor.jackpotYellow : AppColor.borderSoft)
                    .frame(width: idx == current ? 26 : 10, height: 10)
                    .animation(.bouncy(duration: 0.4, extraBounce: 0.15), value: current)
            }
        }
    }
}

private struct CityHorizon: View {
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                LinearGradient(
                    colors: [AppColor.skyDeep.opacity(0.0), AppColor.skyDeep.opacity(0.45)],
                    startPoint: .top, endPoint: .bottom
                )
                Path { p in
                    let baseY = geo.size.height - 120
                    p.move(to: CGPoint(x: 0, y: baseY))
                    var x: CGFloat = 0
                    let widths: [CGFloat] = [40, 28, 56, 36, 22, 70, 30, 44, 24, 38, 50, 26, 62]
                    let heights: [CGFloat] = [70, 110, 150, 90, 80, 180, 100, 130, 75, 95, 140, 85, 120]
                    var i = 0
                    while x < geo.size.width {
                        let w = widths[i % widths.count]
                        let h = heights[i % heights.count]
                        p.addLine(to: CGPoint(x: x, y: baseY - h))
                        p.addLine(to: CGPoint(x: x + w, y: baseY - h))
                        p.addLine(to: CGPoint(x: x + w, y: baseY))
                        x += w
                        i += 1
                    }
                    p.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                    p.addLine(to: CGPoint(x: 0, y: geo.size.height))
                    p.closeSubpath()
                }
                .fill(AppColor.midnightNavy.opacity(0.85))
            }
        }
    }
}
