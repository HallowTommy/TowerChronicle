import SwiftUI
import MapKit

struct TowerMapView: View {
    @EnvironmentObject private var journal: TowerJournal
    @Binding var focusId: String?
    @State private var cameraPosition: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 30, longitude: 20),
            distance: 18_000_000,
            heading: 0,
            pitch: 0
        )
    )
    @State private var selected: Tower? = nil
    @State private var is3D: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            mapBody

            if let tower = selected {
                TowerPinPopover(tower: tower, isFavorite: journal.isFavorited(tower.id),
                                onToggleFavorite: {
                                    withAnimation(.bouncy(duration: 0.4, extraBounce: 0.2)) {
                                        journal.toggleFavorite(tower.id)
                                    }
                                },
                                onClose: { selected = nil })
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationTitle(LocalizedStringKey("map.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColor.deepNavy, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    toggle3D()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: is3D ? "view.2d" : "view.3d")
                        Text(is3D ? "2D" : "3D")
                    }
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppColor.onYellow)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColor.jackpotYellow, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            applyFocusIfNeeded()
        }
        .onChange(of: focusId) { _, _ in
            applyFocusIfNeeded()
        }
    }

    private var mapBody: some View {
        Map(position: $cameraPosition) {
            ForEach(journal.towers) { tower in
                Annotation(tower.name, coordinate: tower.coordinate) {
                    Button {
                        withAnimation(.bouncy(duration: 0.5, extraBounce: 0.15)) {
                            selected = tower
                            cameraPosition = .camera(
                                MapCamera(
                                    centerCoordinate: tower.coordinate,
                                    distance: 4_500,
                                    heading: 0,
                                    pitch: 60
                                )
                            )
                            is3D = true
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(AppColor.jackpotYellow)
                                .frame(width: 30, height: 30)
                                .glowYellow(radius: 8)
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundStyle(AppColor.deepNavy)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .mapStyle(.hybrid(elevation: .realistic, pointsOfInterest: .all, showsTraffic: false))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func toggle3D() {
        withAnimation(.bouncy(duration: 0.6, extraBounce: 0.15)) {
            if is3D {
                cameraPosition = .camera(
                    MapCamera(
                        centerCoordinate: CLLocationCoordinate2D(latitude: 30, longitude: 20),
                        distance: 18_000_000,
                        heading: 0,
                        pitch: 0
                    )
                )
                is3D = false
            } else {
                let coord = selected?.coordinate ?? CLLocationCoordinate2D(latitude: 30, longitude: 20)
                let dist: Double = selected != nil ? 4_500 : 5_000_000
                cameraPosition = .camera(
                    MapCamera(
                        centerCoordinate: coord,
                        distance: dist,
                        heading: 0,
                        pitch: 60
                    )
                )
                is3D = true
            }
        }
    }

    private func applyFocusIfNeeded() {
        guard let id = focusId, let tower = journal.tower(byId: id) else { return }
        selected = tower
        cameraPosition = .camera(
            MapCamera(
                centerCoordinate: tower.coordinate,
                distance: 4_500,
                heading: 0,
                pitch: 60
            )
        )
        is3D = true
        focusId = nil
    }
}

private struct TowerPinPopover: View {
    let tower: Tower
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(tower.asset)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(tower.name)
                        .font(.appH3)
                        .foregroundStyle(AppColor.textOnNavy)
                        .lineLimit(2)
                    Text("\(tower.city), \(tower.country)")
                        .font(.appCaption)
                        .foregroundStyle(AppColor.textSecondary)
                    HStack(spacing: 10) {
                        Label("\(tower.heightString) m", systemImage: "ruler.fill")
                            .font(.appCaption)
                            .foregroundStyle(AppColor.jackpotYellow)
                        Label(tower.region.titleKey, systemImage: tower.region.symbol)
                            .font(.appCaption)
                            .foregroundStyle(tower.region.accent)
                    }
                }
                Spacer(minLength: 0)
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(AppColor.textMuted)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 10) {
                NavigationLink {
                    TowerDetailView(tower: tower)
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.right.square.fill")
                        Text(LocalizedStringKey("map.callout.open"))
                    }
                }
                .buttonStyle(PrimaryYellowButton())

                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(isFavorite ? AppColor.jackpotYellow : AppColor.textOnNavy)
                        .padding(14)
                        .background(AppColor.surfaceRaised, in: Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppColor.surfacePanel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(AppColor.border, lineWidth: 1)
        )
        .shadow(color: AppColor.midnightNavy.opacity(0.55), radius: 18, y: 8)
    }
}
