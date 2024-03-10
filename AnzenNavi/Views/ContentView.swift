//
//  ContentView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/03/10.
//

import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    @State private var menuState: MenuState = .closed
    @State private var searchResults: [MKMapItem] = []
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedResult: MKMapItem?
    @State private var route: MKRoute?
    @State private var realTimeInfoDict: [String: [String]] = [:]
    @State private var isProfilePresented = false
    
    
    
    private let menuPartialHeight: CGFloat = 100
    private let menuHalfOpenHeight: CGFloat = 300
    private let menuFullHeightOffset: CGFloat = 60
    private let dragThreshold: CGFloat = 200.0
    private let locationManager = CLLocationManager()
    
    
    enum MenuState {
        case closed, halfOpen, open
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Map(position: $position, selection: $selectedResult) {
                    
                    ForEach(searchResults, id: \.self) { result in
                        Marker(item: result)
                    }
                    .annotationTitles(.hidden)
                    
                    UserAnnotation()
                    
                    if let route {
                        MapPolyline(route)
                            .stroke(.blue, lineWidth: 5)
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                
                if menuState == .open {
                    Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                }
                
                // ContentView内
                SlideUpMenuView(menuState: $menuState,
                                isProfilePresented: $isProfilePresented,
                                selectedResult: $selectedResult,
                                route: $route,
                                searchResults: $searchResults,
                                position: $position,
                                visibleRegion: visibleRegion)

                    .frame(height: geometry.size.height)
                    .offset(y: menuOffset(for: geometry.size.height))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: menuState)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                withAnimation {
                                    handleDragChange(gesture.translation.height)
                                }
                            }
                            .onEnded { gesture in
                                withAnimation {
                                    handleDragEnd(gesture.translation.height, screenHeight: geometry.size.height)
                                }
                            }
                    )
                    .contentShape(Rectangle())
                
                if menuState == .open {
                    Rectangle().foregroundColor(.clear).edgesIgnoringSafeArea(.all)
                    
                }
                // プロフィール画面を表示
                if isProfilePresented {
                    ProfileView(isPresented: $isProfilePresented)
                        .transition(.move(edge: .bottom))
                        .animation(.spring(), value: isProfilePresented)
                        .frame(height: UIScreen.main.bounds.height / 2)
                        .offset(y: UIScreen.main.bounds.height / 4) // 画面の半分の高さから表示
                }
            }
        }
        .onAppear {
            // 位置情報の使用許可をリクエスト
            locationManager.requestWhenInUseAuthorization()
        }
        .onChange(of: searchResults) {
            position = .automatic
        }
        .onChange(of: selectedResult) {
            getDirections()
        }
        .onMapCameraChange { context in
            visibleRegion = context.region
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
    }
    
    private func handleDragChange(_ dragAmount: CGFloat) {
        if dragAmount < 0 && menuState == .closed {
            menuState = .halfOpen
        }
    }
    
    private func handleDragEnd(_ dragAmount: CGFloat, screenHeight: CGFloat) {
        if dragAmount < -dragThreshold {
            menuState = menuState == .closed ? .halfOpen : .open
        } else if dragAmount > dragThreshold {
            menuState = menuState == .open ? .halfOpen : .closed
        }
    }
    
    private func menuOffset(for screenHeight: CGFloat) -> CGFloat {
        switch menuState {
        case .closed:
            return screenHeight - menuPartialHeight
        case .halfOpen:
            return screenHeight - menuHalfOpenHeight
        case .open:
            return menuFullHeightOffset
        }
    }
    
    
    
    func getDirections() {
        route = nil
        guard let selectedResult = selectedResult else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = selectedResult
        
        Task {
            let directions = MKDirections(request: request)
            if let response = try? await directions.calculate() {
                route = response.routes.first
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

