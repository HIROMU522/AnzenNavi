//
//  HierarchicalClusteringManager.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2025/02/26.
//

import MapKit

class HierarchicalClusteringManager {
    private var allShelters: [Shelter] = []
    
    private var sheltersByPrefecture: [String: [Shelter]] = [:]
    private var sheltersByMunicipality: [String: [Shelter]] = [:]
    
    func setShelters(_ shelters: [Shelter]) {
        self.allShelters = shelters
        organizeByHierarchy()
    }
    
    func getShelters() -> [Shelter] {
        return allShelters
    }
    
    private func organizeByHierarchy() {
        sheltersByPrefecture = [:]
        sheltersByMunicipality = [:]
        
        for shelter in allShelters {
            let components = AddressParser.parseJapaneseAddress(shelter.address)
            let prefecture = components.prefecture
            let municipality = components.municipality
            
            if sheltersByPrefecture[prefecture] == nil {
                sheltersByPrefecture[prefecture] = []
            }
            sheltersByPrefecture[prefecture]?.append(shelter)
            
            let municipalityKey = "\(prefecture)_\(municipality)"
            if sheltersByMunicipality[municipalityKey] == nil {
                sheltersByMunicipality[municipalityKey] = []
            }
            sheltersByMunicipality[municipalityKey]?.append(shelter)
        }
    }
    
    func getAnnotations(for level: ClusteringLevel, in region: MKCoordinateRegion) -> [MKAnnotation] {
        switch level {
        case .country:
            return [createCountryAnnotation()]
            
        case .prefecture:
            return createPrefectureAnnotations(in: region)
            
        case .municipality:
            return createMunicipalityAnnotations(in: region)
            
        case .individual:
            return createIndividualAnnotations(in: region)
        }
    }
    
    private func filterAnnotationsInRegion<T: MKAnnotation>(_ annotations: [T], region: MKCoordinateRegion) -> [T] {
        return annotations.filter { annotation in
            region.contains(coordinate: annotation.coordinate)
        }
    }
    
    private func createCountryAnnotation() -> MKAnnotation {
        let totalCount = allShelters.count
        
        return HierarchicalAnnotation(
            coordinate: CLLocationCoordinate2D(latitude: 36.2048, longitude: 138.2529), // 日本の中心付近
            title: "日本",
            subtitle: "全国の避難所: \(totalCount)箇所",
            level: .country,
            count: totalCount,
            identifier: "japan",
            shelters: allShelters
        )
    }
    
    private func createPrefectureAnnotations(in region: MKCoordinateRegion) -> [MKAnnotation] {
        let annotations = sheltersByPrefecture.map { prefecture, shelters in
            return HierarchicalAnnotation(
                title: prefecture,
                subtitle: "\(shelters.count)箇所の避難所",
                level: .prefecture,
                identifier: prefecture,
                shelters: shelters
            )
        }
        
        return filterAnnotationsInRegion(annotations, region: region)
    }
    
    private func createMunicipalityAnnotations(in region: MKCoordinateRegion) -> [MKAnnotation] {
        let annotations = sheltersByMunicipality.map { key, shelters in
            let components = key.split(separator: "_")
            let municipality = components.count > 1 ? String(components[1]) : ""
            
            return HierarchicalAnnotation(
                title: municipality,
                subtitle: "\(shelters.count)箇所の避難所",
                level: .municipality,
                identifier: key,
                shelters: shelters
            )
        }
        
        return filterAnnotationsInRegion(annotations, region: region)
    }
    
    private func createIndividualAnnotations(in region: MKCoordinateRegion) -> [MKAnnotation] {
        let individualShelters = allShelters.filter { shelter in
            let coordinate = CLLocationCoordinate2D(latitude: shelter.latitude, longitude: shelter.longitude)
            return region.contains(coordinate: coordinate)
        }
        
        let maxAnnotations = 300
        let limitedShelters = individualShelters.count > maxAnnotations ?
            Array(individualShelters.prefix(maxAnnotations)) : individualShelters
        
        return limitedShelters.map { shelter in
            return ShelterAnnotation(shelter: shelter)
        }
    }
}
