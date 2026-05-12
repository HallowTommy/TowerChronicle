import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var journal: TowerJournal
    @State private var query: String = ""
    @State private var showFilters: Bool = false

    private var results: [Tower] {
        journal.filtered(query: query)
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SearchBar(text: $query) {
                    journal.recordSearch(query)
                }

                filterRow

                resultsHeader

                if results.isEmpty {
                    emptyState
                } else {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(results) { tower in
                            NavigationLink {
                                TowerDetailView(tower: tower)
                            } label: {
                                TowerTile(tower: tower, isFavorite: journal.isFavorited(tower.id)) {
                                    withAnimation(.bouncy(duration: 0.4, extraBounce: 0.2)) {
                                        journal.toggleFavorite(tower.id)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(AppColor.deepNavy.ignoresSafeArea())
        .navigationTitle(LocalizedStringKey("explore.title"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showFilters) {
            FilterSheet()
                .environmentObject(journal)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var filterRow: some View {
        HStack(spacing: 8) {
            Button {
                showFilters = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "slider.horizontal.3")
                    Text(LocalizedStringKey("explore.filters"))
                }
                .font(.appCaption)
                .foregroundStyle(AppColor.onYellow)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppColor.jackpotYellow, in: Capsule())
            }
            .buttonStyle(.plain)

            if let region = journal.regionFilter {
                ActiveChip(label: region.titleKey, accent: region.accent) {
                    journal.regionFilter = nil
                    journal.flush()
                }
            }
            if let cat = journal.categoryFilter {
                ActiveChip(label: cat.titleKey, accent: cat.accent) {
                    journal.categoryFilter = nil
                    journal.flush()
                }
            }
            Spacer()
        }
    }

    private var resultsHeader: some View {
        HStack {
            Text(String(format: NSLocalizedString("explore.results_count", comment: ""), results.count))
                .font(.appCaption)
                .foregroundStyle(AppColor.textSecondary)
            Spacer()
            Menu {
                ForEach(TowerJournal.SortMode.allCases) { mode in
                    Button(mode.label) {
                        journal.sort = mode
                        journal.flush()
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(journal.sort.label)
                        .font(.appCaption)
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 11, weight: .heavy))
                }
                .foregroundStyle(AppColor.skyBright)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppColor.surfaceRaised, in: Capsule())
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50, weight: .thin))
                .foregroundStyle(AppColor.skyBase)
            Text(LocalizedStringKey("explore.empty"))
                .font(.appBody)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
            Button(LocalizedStringKey("explore.reset")) {
                journal.resetFilters()
                query = ""
            }
            .buttonStyle(GhostBlueButton())
            .padding(.horizontal, 60)
        }
        .padding(.vertical, 60)
    }
}

private struct ActiveChip: View {
    let label: LocalizedStringKey
    let accent: Color
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .heavy, design: .rounded))
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .heavy))
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(accent)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(accent.opacity(0.32), in: Capsule())
        .overlay(Capsule().strokeBorder(accent.opacity(0.85), lineWidth: 1))
    }
}
