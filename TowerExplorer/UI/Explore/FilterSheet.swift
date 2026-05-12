import SwiftUI

struct FilterSheet: View {
    @EnvironmentObject private var journal: TowerJournal
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    section(title: "explore.region") {
                        chipGrid(items: Region.allCases.map { ($0.rawValue, $0.titleKey, $0.symbol, $0.accent) },
                                 isSelected: { journal.regionFilter?.rawValue == $0 },
                                 onTap: { raw in
                                    let region = Region(rawValue: raw)
                                    journal.regionFilter = (journal.regionFilter == region) ? nil : region
                                    journal.flush()
                                 },
                                 onClear: {
                                    journal.regionFilter = nil
                                    journal.flush()
                                 },
                                 clearKey: "explore.region.all",
                                 isClearActive: journal.regionFilter == nil)
                    }

                    section(title: "explore.category") {
                        chipGrid(items: TowerCategory.allCases.map { ($0.rawValue, $0.titleKey, $0.symbol, $0.accent) },
                                 isSelected: { journal.categoryFilter?.rawValue == $0 },
                                 onTap: { raw in
                                    let cat = TowerCategory(rawValue: raw)
                                    journal.categoryFilter = (journal.categoryFilter == cat) ? nil : cat
                                    journal.flush()
                                 },
                                 onClear: {
                                    journal.categoryFilter = nil
                                    journal.flush()
                                 },
                                 clearKey: "explore.category.all",
                                 isClearActive: journal.categoryFilter == nil)
                    }

                    section(title: "explore.sort") {
                        VStack(spacing: 10) {
                            ForEach(TowerJournal.SortMode.allCases) { mode in
                                Button {
                                    journal.sort = mode
                                    journal.flush()
                                } label: {
                                    HStack {
                                        Text(mode.label)
                                            .font(.appBody)
                                            .foregroundStyle(AppColor.textOnNavy)
                                        Spacer()
                                        if journal.sort == mode {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(AppColor.jackpotYellow)
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(AppColor.surfaceRaised, in: RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(AppColor.deepNavy.ignoresSafeArea())
            .navigationTitle(LocalizedStringKey("explore.filters"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(LocalizedStringKey("explore.reset")) {
                        journal.resetFilters()
                    }
                    .foregroundStyle(AppColor.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(LocalizedStringKey("explore.apply")) {
                        dismiss()
                    }
                    .foregroundStyle(AppColor.jackpotYellow)
                    .fontWeight(.heavy)
                }
            }
        }
    }

    @ViewBuilder
    private func section<Content: View>(title: LocalizedStringKey, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.appH3)
                .foregroundStyle(AppColor.textOnNavy)
            content()
        }
    }

    @ViewBuilder
    private func chipGrid(items: [(String, LocalizedStringKey, String, Color)],
                          isSelected: @escaping (String) -> Bool,
                          onTap: @escaping (String) -> Void,
                          onClear: @escaping () -> Void,
                          clearKey: LocalizedStringKey,
                          isClearActive: Bool) -> some View {
        FlowChips {
            chip(label: clearKey, symbol: "circle.dashed", accent: AppColor.skyBase, active: isClearActive) {
                onClear()
            }
            ForEach(items, id: \.0) { item in
                let active = isSelected(item.0)
                chip(label: item.1, symbol: item.2, accent: item.3, active: active) {
                    onTap(item.0)
                }
            }
        }
    }

    @ViewBuilder
    private func chip(label: LocalizedStringKey, symbol: String, accent: Color, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.system(size: 11, weight: .heavy))
                Text(label)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
            }
            .foregroundStyle(active ? AppColor.onYellow : accent)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(active ? AppColor.jackpotYellow : AppColor.surfaceRaised, in: Capsule())
            .overlay(
                Capsule().strokeBorder(active ? AppColor.amber : accent.opacity(0.85), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct FlowChips: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var totalH: CGFloat = 0
        var lineH: CGFloat = 0
        var x: CGFloat = 0
        for sub in subviews {
            let s = sub.sizeThatFits(.unspecified)
            if x + s.width > maxWidth {
                totalH += lineH + lineSpacing
                x = 0
                lineH = 0
            }
            x += s.width + spacing
            lineH = max(lineH, s.height)
        }
        totalH += lineH
        return CGSize(width: maxWidth, height: totalH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var lineH: CGFloat = 0
        for sub in subviews {
            let s = sub.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX {
                x = bounds.minX
                y += lineH + lineSpacing
                lineH = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(s))
            x += s.width + spacing
            lineH = max(lineH, s.height)
        }
    }
}
