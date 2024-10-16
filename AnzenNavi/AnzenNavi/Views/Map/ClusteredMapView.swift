//
//  ClusteredMapView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/10/16.
//
import SwiftUI
import MapKit

struct ClusteredMapView: UIViewRepresentable {
    @Binding var annotations: [ShelterAnnotation]
    @Binding var selectedShelter: Shelter?
    let manager = CLLocationManager()
    var onRegionChange: ((MKCoordinateRegion) -> Void)?
    let zoomLevelThreshold: Double = 10.0

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
        mapView.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier
        )

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.delegate = context.coordinator

        uiView.removeAnnotations(uiView.annotations)

        uiView.addAnnotations(annotations)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: ClusteredMapView

        init(_ parent: ClusteredMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let region = mapView.region
            let zoomLevel = mapView.currentZoomLevel
            if zoomLevel >= parent.zoomLevelThreshold {
                parent.onRegionChange?(region)
            } else {
                parent.annotations.removeAll()
                DispatchQueue.main.async {
                    self.parent.selectedShelter = nil
                }
            }
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let shelterAnnotation = view.annotation as? ShelterAnnotation {
                DispatchQueue.main.async {
                    self.parent.selectedShelter = shelterAnnotation.shelter
                }
            }
        }

        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            DispatchQueue.main.async {
                self.parent.selectedShelter = nil
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }

            if let cluster = annotation as? MKClusterAnnotation {
                let identifier = MKMapViewDefaultClusterAnnotationViewReuseIdentifier
                let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: cluster) as? MKMarkerAnnotationView
                clusterView?.markerTintColor = .systemBlue
                clusterView?.glyphText = "\(cluster.memberAnnotations.count)"
                return clusterView
            }

            let identifier = MKMapViewDefaultAnnotationViewReuseIdentifier
            let markerView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation) as? MKMarkerAnnotationView
            markerView?.canShowCallout = true
            markerView?.markerTintColor = .systemRed
            markerView?.glyphImage = UIImage(systemName: "house.fill")
            markerView?.clusteringIdentifier = "shelter"
            return markerView
        }
    }
}

extension MKMapView {
    var currentZoomLevel: Double {
        return log2(360 * (Double(self.frame.size.width / 256) / self.region.span.longitudeDelta)) + 1
    }
}


