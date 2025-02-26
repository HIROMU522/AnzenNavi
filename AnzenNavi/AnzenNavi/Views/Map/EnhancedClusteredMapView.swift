//
//  EnhancedClusteredMapView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2025/02/26.
//

import SwiftUI
import MapKit

struct EnhancedClusteredMapView: UIViewRepresentable {
    @Binding var annotations: [MKAnnotation]
    @Binding var selectedShelter: Shelter?
    @Binding var cameraPosition: MKCoordinateRegion?
    @Binding var currentZoomLevel: Double
    
    var onRegionChange: ((MKCoordinateRegion) -> Void)?
    var onClusterTapped: ((MKAnnotation) -> Void)?
    var clearSelectionOnTap: Bool = false  // マップタップで選択を解除するかどうか
    
    let manager = CLLocationManager()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        mapView.showsUserLocation = true
        manager.requestWhenInUseAuthorization()
        mapView.userTrackingMode = .follow
        
        // 標準のアノテーションビューを登録
        mapView.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
        
        // マップタップのジェスチャー認識を追加
        if clearSelectionOnTap {
            let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleMapTap(_:)))
            tapGesture.delegate = context.coordinator
            mapView.addGestureRecognizer(tapGesture)
        }
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.delegate = context.coordinator
        
        // アノテーションの更新
        let currentAnnotations = uiView.annotations.filter { !($0 is MKUserLocation) }
        
        // 既存のアノテーションから削除するべきものを特定
        let annotationsToRemove = currentAnnotations.filter { annotation in
            !annotations.contains { $0.isEqual(annotation) }
        }
        
        // 新しく追加するべきアノテーションを特定
        let annotationsToAdd = annotations.filter { annotation in
            !currentAnnotations.contains { $0.isEqual(annotation) }
        }
        
        // 削除と追加を行う
        if !annotationsToRemove.isEmpty {
            uiView.removeAnnotations(annotationsToRemove)
        }
        
        if !annotationsToAdd.isEmpty {
            uiView.addAnnotations(annotationsToAdd)
        }
        
        // 選択中の避難所があれば、対応するアノテーションを選択状態にする
        if let selectedShelter = selectedShelter {
            for annotation in uiView.annotations {
                if let shelterAnnotation = annotation as? ShelterAnnotation,
                   shelterAnnotation.shelter.id == selectedShelter.id {
                    uiView.selectAnnotation(shelterAnnotation, animated: true)
                    break
                }
            }
        }
        
        // カメラ位置の更新
        if let cameraPosition = cameraPosition {
            uiView.setRegion(cameraPosition, animated: true)
            DispatchQueue.main.async {
                self.cameraPosition = nil  // 一度適用したら設定をクリア
            }
        }
        
        // 現在のズームレベルを更新
        let newZoomLevel = uiView.currentZoomLevel
        if abs(newZoomLevel - currentZoomLevel) > 0.1 { // 変化が一定以上ある場合のみ更新
            DispatchQueue.main.async {
                self.currentZoomLevel = newZoomLevel  // 次のサイクルに更新を延期
            }
        }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        var parent: EnhancedClusteredMapView
        
        init(_ parent: EnhancedClusteredMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let region = mapView.region
            let newZoomLevel = mapView.currentZoomLevel
            
            DispatchQueue.main.async {
                self.parent.currentZoomLevel = newZoomLevel
                self.parent.onRegionChange?(region)
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation {
                // 階層的アノテーションの場合
                if let hierarchicalAnnotation = annotation as? HierarchicalAnnotation {
                    // タップイベントを親に通知
                    parent.onClusterTapped?(hierarchicalAnnotation)
                    mapView.deselectAnnotation(annotation, animated: true)
                }
                // 避難所アノテーションの場合
                else if let shelterAnnotation = annotation as? ShelterAnnotation {
                    DispatchQueue.main.async {
                        self.parent.selectedShelter = shelterAnnotation.shelter
                    }
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            // ここでは選択解除時の動作を制御しない（マップ移動時に解除されないようにするため）
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // ユーザーの現在地は標準の青い点で表示
            if annotation is MKUserLocation {
                return nil
            }
            
            // 階層的アノテーションの場合
            if let hierarchicalAnnotation = annotation as? HierarchicalAnnotation {
                let identifier = "HierarchicalAnnotation"
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                    ?? MKMarkerAnnotationView(annotation: hierarchicalAnnotation, reuseIdentifier: identifier)
                
                annotationView.annotation = hierarchicalAnnotation
                annotationView.canShowCallout = true
                
                // 階層に応じた表示スタイルを設定
                switch hierarchicalAnnotation.level {
                case .country:
                    annotationView.markerTintColor = .systemBlue
                    annotationView.glyphImage = UIImage(systemName: "flag.fill")
                    
                case .prefecture:
                    annotationView.markerTintColor = .systemGreen
                    annotationView.glyphText = "\(hierarchicalAnnotation.count)"
                    
                case .municipality:
                    annotationView.markerTintColor = .systemOrange
                    annotationView.glyphText = "\(hierarchicalAnnotation.count)"
                    
                case .individual:
                    // 個別避難所は通常のアノテーションで表示
                    break
                }
                
                return annotationView
            }
            
            // 避難所アノテーションの場合
            if let shelterAnnotation = annotation as? ShelterAnnotation {
                let identifier = "ShelterAnnotation"
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                    ?? MKMarkerAnnotationView(annotation: shelterAnnotation, reuseIdentifier: identifier)
                
                annotationView.annotation = shelterAnnotation
                annotationView.canShowCallout = true
                annotationView.markerTintColor = shelterAnnotation.shelter.designated_shelter ? .systemRed : .systemPurple
                annotationView.glyphImage = UIImage(systemName: "house.fill")
                
                return annotationView
            }
            
            return nil
        }
        
        // マップタップのハンドラ
        @objc func handleMapTap(_ gestureRecognizer: UITapGestureRecognizer) {
            if gestureRecognizer.state == .ended {
                let mapView = gestureRecognizer.view as! MKMapView
                let point = gestureRecognizer.location(in: mapView)
                
                // タップした場所がアノテーション上でなかった場合のみ選択を解除
                if !didTapOnAnnotation(mapView, at: point) {
                    DispatchQueue.main.async {
                        self.parent.selectedShelter = nil
                    }
                }
            }
        }
        
        // タップがアノテーション上かどうかを判定
        private func didTapOnAnnotation(_ mapView: MKMapView, at point: CGPoint) -> Bool {
            for annotation in mapView.annotations {
                if let view = mapView.view(for: annotation) {
                    // アノテーションビューの領域を拡大（タップしやすくするため）
                    let expandedRect = view.frame.insetBy(dx: -22, dy: -22)
                    if expandedRect.contains(point) {
                        return true
                    }
                }
            }
            return false
        }
        
        // UIGestureRecognizerDelegateメソッド
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            // アノテーションビュー上のタップは無視する（アノテーション選択を優先）
            if let view = touch.view, view is MKAnnotationView || view.superview is MKAnnotationView {
                return false
            }
            return true
        }
    }
}

// MKMapViewの拡張：現在のズームレベルを計算
extension MKMapView {
    var currentZoomLevel: Double {
        return log2(360 * (Double(self.frame.size.width / 256) / self.region.span.longitudeDelta)) + 1
    }
}
