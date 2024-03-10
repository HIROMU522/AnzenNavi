//
//  ButtonView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/03/10.
//

import SwiftUI
import MapKit

struct Buttons: View {
    @Binding var searchResults: [MKMapItem]
    @Binding var position: MapCameraPosition

    var visibleRegion: MKCoordinateRegion?
    
    var body: some View {
        HStack {
            Button {
                search(for: "避難場所")
            } label: {
                Label("避難場所", systemImage: "figure.walk.diamond")
            }
            .buttonStyle(.bordered)
        }
        .labelStyle(.iconOnly)
    }
    
    func search(for query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest

        // visibleRegionがnilでない場合、その値を使用して検索範囲を設定
        if let region = visibleRegion {
            request.region = region
        } else {
            // visibleRegionがnilの場合、デフォルトの位置と範囲を設定
            request.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 35.689487, longitude: 139.691706),
                span: MKCoordinateSpan(latitudeDelta: 0.0025, longitudeDelta: 0.0025))
        }
        
        Task {
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            searchResults = response?.mapItems ?? []
        }
    }
}

