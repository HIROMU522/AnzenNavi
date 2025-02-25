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
    @State private var annotations: [MKAnnotation] = []
    @State private var showZoomMessage: Bool = false
    @State private var currentZoomLevel: Double = 0.0
    @State private var hierarchicalClusteringManager = HierarchicalClusteringManager()
    
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            mapView
            userLocationButton
            
            if showZoomMessage {
                zoomMessageView
            }
        }
        .onAppear {
            loadShelters()
        }
    }
    
    // MARK: - View Components
    
    private var mapView: some View {
        EnhancedClusteredMapView(
            annotations: $annotations,
            selectedShelter: $selectedShelter,
            cameraPosition: $cameraPosition,
            currentZoomLevel: $currentZoomLevel,
            onRegionChange: { region in
                updateAnnotations(for: region)
            },
            onClusterTapped: { annotation in
                handleClusterTap(annotation)
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
            .padding(.bottom, 230)
        }
    }
    
    private var zoomMessageView: some View {
        VStack {
            Spacer().frame(height: 100)
            Text("拡大すると避難所が表示されます")
                .padding()
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
            Spacer()
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadShelters() {
        DispatchQueue.global(qos: .userInitiated).async {
            let shelters = ShelterDataLoader.loadSheltersFromJSON()
            DispatchQueue.main.async {
                self.allShelters = shelters
                self.hierarchicalClusteringManager.setShelters(shelters)
                self.updateInitialAnnotations()
            }
        }
    }
    
    private func updateInitialAnnotations() {
        // 初期状態では日本全体のアノテーションを表示
        if let initialRegion = cameraPosition {
            updateAnnotations(for: initialRegion)
        } else {
            // デフォルトの表示領域（日本全体）
            let japanRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 36.2048, longitude: 138.2529),
                span: MKCoordinateSpan(latitudeDelta: 20.0, longitudeDelta: 20.0)
            )
            updateAnnotations(for: japanRegion)
        }
    }
    
    private func updateAnnotations(for region: MKCoordinateRegion) {
        let level = ClusteringLevel.forZoomLevel(currentZoomLevel)
        
        DispatchQueue.global(qos: .userInitiated).async {
            let newAnnotations = self.hierarchicalClusteringManager.getAnnotations(for: level, in: region)
            
            DispatchQueue.main.async {
                self.annotations = newAnnotations
                self.showZoomMessage = level != .individual && !newAnnotations.isEmpty
            }
        }
    }
    
    private func handleClusterTap(_ annotation: MKAnnotation) {
        if let hierarchicalAnnotation = annotation as? HierarchicalAnnotation {
            let zoomLevel = hierarchicalAnnotation.level.recommendedZoomLevel
            let newRegion = MKCoordinateRegion(
                center: hierarchicalAnnotation.coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 360 / pow(2, zoomLevel) * 0.5,
                    longitudeDelta: 360 / pow(2, zoomLevel) * 0.5
                )
            )
            
            self.cameraPosition = newRegion
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
}
