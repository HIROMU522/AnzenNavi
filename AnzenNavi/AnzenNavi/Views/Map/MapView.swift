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
    @State private var isInitialLoad: Bool = true
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            mapView
            userLocationButton
            
            if showZoomMessage {
                zoomMessageView
            }
            
            if isInitialLoad {
                loadingView
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
            },
            clearSelectionOnTap: true  // マップのタップで選択を解除するフラグ
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    private var loadingView: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
                
                Text("データを読み込み中...")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 10)
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
        // バックグラウンドスレッドでデータを非同期に読み込む
        DispatchQueue.global(qos: .userInitiated).async {
            // データをバッチに分けて処理する
            let allShelters = ShelterDataLoader.loadSheltersFromJSON()
            
            // メインスレッドでデータモデルを更新
            DispatchQueue.main.async {
                // まず、少数のサンプルデータだけを設定して初期表示
                let initialBatchSize = min(1000, allShelters.count)
                let initialBatch = Array(allShelters.prefix(initialBatchSize))
                
                self.hierarchicalClusteringManager.setShelters(initialBatch)
                self.updateInitialAnnotations()
                
                // 残りのデータは別のタスクでバックグラウンド処理
                DispatchQueue.global(qos: .utility).async {
                    // 残りのデータを処理
                    let remainingShelters = Array(allShelters.suffix(from: initialBatchSize))
                    
                    // バッチ処理（5000件ずつ）
                    let batchSize = 5000
                    for i in stride(from: 0, to: remainingShelters.count, by: batchSize) {
                        let end = min(i + batchSize, remainingShelters.count)
                        let batch = Array(remainingShelters[i..<end])
                        
                        DispatchQueue.main.async {
                            // 現在のデータに追加
                            let currentShelters = self.hierarchicalClusteringManager.getShelters()
                            self.hierarchicalClusteringManager.setShelters(currentShelters + batch)
                            
                            // すべてのバッチが完了したらローディング表示を終了
                            if end == remainingShelters.count {
                                self.isInitialLoad = false
                                self.allShelters = allShelters
                                
                                // 現在の表示領域のアノテーションを更新
                                if let region = self.cameraPosition {
                                    self.updateAnnotations(for: region)
                                }
                            }
                        }
                        
                        // バッチ間で少し待機してUIスレッドをブロックしないようにする
                        Thread.sleep(forTimeInterval: 0.1)
                    }
                    
                    // データが少ない場合はここでローディングを終了
                    if remainingShelters.isEmpty {
                        DispatchQueue.main.async {
                            self.isInitialLoad = false
                            self.allShelters = allShelters
                        }
                    }
                }
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
            self.cameraPosition = japanRegion
            updateAnnotations(for: japanRegion)
        }
        
        // 初期ロードが終わったら非表示にする
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isInitialLoad = false
        }
    }
    
    private func updateAnnotations(for region: MKCoordinateRegion) {
        // 拡大レベルに応じて表示するアノテーションを決定
        let level = ClusteringLevel.forZoomLevel(currentZoomLevel)
        
        // 表示領域が広すぎる場合はメッセージを表示
        if level == .country || level == .prefecture {
            DispatchQueue.main.async {
                self.showZoomMessage = true
                self.annotations = []
            }
            return
        }
        
        // バックグラウンドでアノテーションを準備
        DispatchQueue.global(qos: .userInitiated).async {
            // アノテーションの最大数を制限（パフォーマンス改善のため）
            let maxAnnotations = 300
            
            // 階層に応じたアノテーションを取得
            var newAnnotations = self.hierarchicalClusteringManager.getAnnotations(for: level, in: region)
            
            // 数が多すぎる場合は制限
            if newAnnotations.count > maxAnnotations {
                // より高い階層のアノテーションに切り替え
                if level == .individual {
                    newAnnotations = self.hierarchicalClusteringManager.getAnnotations(for: .municipality, in: region)
                } else if level == .municipality {
                    newAnnotations = self.hierarchicalClusteringManager.getAnnotations(for: .prefecture, in: region)
                }
                
                // それでも多すぎる場合は制限
                if newAnnotations.count > maxAnnotations {
                    newAnnotations = Array(newAnnotations.prefix(maxAnnotations))
                }
            }
            
            // UIの更新はメインスレッドで行う
            DispatchQueue.main.async {
                self.annotations = newAnnotations
                self.showZoomMessage = (level != .individual && !newAnnotations.isEmpty) || newAnnotations.count >= maxAnnotations
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
