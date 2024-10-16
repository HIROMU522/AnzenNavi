//
//  MapView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/09/22.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Binding var selectedShelter: Shelter?
    @State private var allShelters: [Shelter] = []
    @State private var annotations: [ShelterAnnotation] = []
    @State private var showZoomMessage: Bool = false

    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            mapView
            if showZoomMessage {
                zoomMessage
            }
        }
        .onAppear {
            loadShelters()
        }
    }

    // MARK: - View Components

    private var mapView: some View {
        ClusteredMapView(
            annotations: $annotations,
            selectedShelter: $selectedShelter,
            onRegionChange: { region in
                updateAnnotations(for: region)
            }
        )
        .edgesIgnoringSafeArea(.all)
    }

    private var zoomMessage: some View {
        Text("マップを拡大して避難所を表示")
            .padding()
            .background(backgroundColor.opacity(0.8))
            .cornerRadius(8)
            .padding()
    }

    // MARK: - Helper Methods

    private func loadShelters() {
        DispatchQueue.global(qos: .userInitiated).async {
            let shelters = ShelterDataLoader.loadSheltersFromJSON()
            DispatchQueue.main.async {
                self.allShelters = shelters
            }
        }
    }

    private func updateAnnotations(for region: MKCoordinateRegion) {
        let zoomLevelThreshold = 10.0
        let zoomLevel = log2(360 * (Double(UIScreen.main.bounds.size.width / 256) / region.span.longitudeDelta)) + 1

        if zoomLevel >= zoomLevelThreshold {
            DispatchQueue.global(qos: .userInitiated).async {
                let visibleShelters = self.allShelters.filter { shelter in
                    region.contains(coordinate: CLLocationCoordinate2D(latitude: shelter.latitude, longitude: shelter.longitude))
                }
                let newAnnotations = visibleShelters.map { ShelterAnnotation(shelter: $0) }
                DispatchQueue.main.async {
                    self.annotations = newAnnotations
                    self.showZoomMessage = false
                    print("表示中のアノテーション数: \(self.annotations.count)")
                }
            }
        } else {
            DispatchQueue.main.async {
                self.annotations.removeAll()
                self.showZoomMessage = true
            }
        }
    }

    // MARK: - Helper Properties

    private var backgroundColor: Color {
        scheme == .dark ? Color(.systemGray5) : Color(.systemGray6)
    }
}

extension MKCoordinateRegion {
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        let regionCenter = center
        let latitudeDelta = span.latitudeDelta / 2.0
        let longitudeDelta = span.longitudeDelta / 2.0

        let minLat = regionCenter.latitude - latitudeDelta
        let maxLat = regionCenter.latitude + latitudeDelta
        let minLon = regionCenter.longitude - longitudeDelta
        let maxLon = regionCenter.longitude + longitudeDelta

        return (minLat...maxLat).contains(coordinate.latitude) && (minLon...maxLon).contains(coordinate.longitude)
    }
}
