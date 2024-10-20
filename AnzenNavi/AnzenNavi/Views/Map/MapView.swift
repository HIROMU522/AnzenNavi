//
//  MapView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/09/22.
//

import SwiftUI
import MapKit

struct MapView: View {
    let manager = CLLocationManager()
    @State private var cameraPosition: MKCoordinateRegion?
    @Binding var selectedShelter: Shelter?
    @State private var allShelters: [Shelter] = []
    @State private var annotations: [ShelterAnnotation] = []
    @State private var showZoomMessage: Bool = false
    
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            mapView
            userLocationButton
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
            cameraPosition: $cameraPosition,
            onRegionChange: { region in
                updateAnnotations(for: region)
            }
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    private var userLocationButton: some View {
        VStack {
            Spacer()
            HStack {
                locationButton
                    .padding(.leading)
                Spacer()
            }
            .padding(.bottom, 200)
        }
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
    
    private var locationButton: some View {
        Button(action: {
            if let currentCoordinate = manager.location?.coordinate {
                let region = MKCoordinateRegion(center: currentCoordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                self.cameraPosition = region
            }
        }) {
            Image(systemName: "location.fill")
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
    
    // MARK: - Helper Properties
    
    private var backgroundColor: Color {
        scheme == .dark ? Color(.systemGray5) : Color(.systemGray6)
    }
}
