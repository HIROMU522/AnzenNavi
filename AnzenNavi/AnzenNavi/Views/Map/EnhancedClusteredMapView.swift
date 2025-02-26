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
    var clearSelectionOnTap: Bool = false
    
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
        
        mapView.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
        
        if clearSelectionOnTap {
            let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleMapTap(_:)))
            tapGesture.delegate = context.coordinator
            mapView.addGestureRecognizer(tapGesture)
        }
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.delegate = context.coordinator
        
        let currentAnnotations = uiView.annotations.filter { !($0 is MKUserLocation) }
        
        let annotationsToRemove = currentAnnotations.filter { annotation in
            !annotations.contains { $0.isEqual(annotation) }
        }
        
        let annotationsToAdd = annotations.filter { annotation in
            !currentAnnotations.contains { $0.isEqual(annotation) }
        }
        
        if !annotationsToRemove.isEmpty {
            uiView.removeAnnotations(annotationsToRemove)
        }
        
        if !annotationsToAdd.isEmpty {
            uiView.addAnnotations(annotationsToAdd)
        }
        
        if let selectedShelter = selectedShelter {
            for annotation in uiView.annotations {
                if let shelterAnnotation = annotation as? ShelterAnnotation,
                   shelterAnnotation.shelter.id == selectedShelter.id {
                    uiView.selectAnnotation(shelterAnnotation, animated: true)
                    break
                }
            }
        }
        
        if let cameraPosition = cameraPosition {
            uiView.setRegion(cameraPosition, animated: true)
            DispatchQueue.main.async {
                self.cameraPosition = nil
            }
        }
        
        let newZoomLevel = uiView.currentZoomLevel
        if abs(newZoomLevel - currentZoomLevel) > 0.1 {
            DispatchQueue.main.async {
                self.currentZoomLevel = newZoomLevel
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
                if let hierarchicalAnnotation = annotation as? HierarchicalAnnotation {
                    parent.onClusterTapped?(hierarchicalAnnotation)
                    mapView.deselectAnnotation(annotation, animated: true)
                }
                else if let shelterAnnotation = annotation as? ShelterAnnotation {
                    DispatchQueue.main.async {
                        self.parent.selectedShelter = shelterAnnotation.shelter
                    }
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            if let hierarchicalAnnotation = annotation as? HierarchicalAnnotation {
                let identifier = "HierarchicalAnnotation"
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                    ?? MKMarkerAnnotationView(annotation: hierarchicalAnnotation, reuseIdentifier: identifier)
                
                annotationView.annotation = hierarchicalAnnotation
                annotationView.canShowCallout = true
                
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
                    break
                }
                
                return annotationView
            }
            
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
        
        @objc func handleMapTap(_ gestureRecognizer: UITapGestureRecognizer) {
            if gestureRecognizer.state == .ended {
                let mapView = gestureRecognizer.view as! MKMapView
                let point = gestureRecognizer.location(in: mapView)
                
                if !didTapOnAnnotation(mapView, at: point) {
                    DispatchQueue.main.async {
                        self.parent.selectedShelter = nil
                    }
                }
            }
        }
        
        private func didTapOnAnnotation(_ mapView: MKMapView, at point: CGPoint) -> Bool {
            for annotation in mapView.annotations {
                if let view = mapView.view(for: annotation) {
                    let expandedRect = view.frame.insetBy(dx: -22, dy: -22)
                    if expandedRect.contains(point) {
                        return true
                    }
                }
            }
            return false
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            if let view = touch.view, view is MKAnnotationView || view.superview is MKAnnotationView {
                return false
            }
            return true
        }
    }
}

extension MKMapView {
    var currentZoomLevel: Double {
        return log2(360 * (Double(self.frame.size.width / 256) / self.region.span.longitudeDelta)) + 1
    }
}
