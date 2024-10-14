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
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        ZStack {
            mapView
            userLocationButton
        }
        .onAppear {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    // MARK: - View Components
    
    private var mapView: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()
        }
    }
    
    private var userLocationButton: some View {
        VStack {
            Spacer()
            HStack {
                locationButton
                    .padding(.leading)
                Spacer()
            }
            .padding(.bottom, 150)
        }
    }
    
    private var locationButton: some View {
        Button(action: {
            if let currentCoordinate = manager.location?.coordinate {
                cameraPosition = .userLocation(fallback: .region(MKCoordinateRegion(center: currentCoordinate, latitudinalMeters: 500, longitudinalMeters: 500)))
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

#Preview {
    MapView()
}

