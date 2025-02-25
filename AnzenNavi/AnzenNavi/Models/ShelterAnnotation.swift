//
//  ShelterAnnotation.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/10/15.
//

import Foundation
import MapKit

class ShelterAnnotation: NSObject, MKAnnotation {
    let shelter: Shelter
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var shelterId: String { shelter.id }
    
    init(shelter: Shelter) {
        self.shelter = shelter
        self.coordinate = CLLocationCoordinate2D(latitude: shelter.latitude, longitude: shelter.longitude)
        self.title = shelter.name
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? ShelterAnnotation else { return false }
        return self.shelterId == other.shelterId
    }
}
