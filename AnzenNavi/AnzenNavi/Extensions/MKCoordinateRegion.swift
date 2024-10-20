//
//  MKCordinate.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/10/16.
//

import MapKit

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
