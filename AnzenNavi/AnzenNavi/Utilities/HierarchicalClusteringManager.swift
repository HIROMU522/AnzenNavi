//
//  HierarchicalClusteringManager.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2025/02/26.
//

import MapKit

class HierarchicalClusteringManager {
    // 避難所データ
    private var allShelters: [Shelter] = []
    
    // 階層ごとのグループ化データ
    private var sheltersByPrefecture: [String: [Shelter]] = [:]
    private var sheltersByMunicipality: [String: [Shelter]] = [:]
    
    // 避難所データをセットしてグループ化
    func setShelters(_ shelters: [Shelter]) {
        self.allShelters = shelters
        organizeByHierarchy()
    }
    
    // 現在のデータを取得
    func getShelters() -> [Shelter] {
        return allShelters
    }
    
    // 階層ごとにデータをグループ化
    private func organizeByHierarchy() {
        sheltersByPrefecture = [:]
        sheltersByMunicipality = [:]
        
        for shelter in allShelters {
            let components = AddressParser.parseJapaneseAddress(shelter.address)
            let prefecture = components.prefecture
            let municipality = components.municipality
            
            // 都道府県ごとにグループ化
            if sheltersByPrefecture[prefecture] == nil {
                sheltersByPrefecture[prefecture] = []
            }
            sheltersByPrefecture[prefecture]?.append(shelter)
            
            // 市区町村ごとにグループ化
            let municipalityKey = "\(prefecture)_\(municipality)"
            if sheltersByMunicipality[municipalityKey] == nil {
                sheltersByMunicipality[municipalityKey] = []
            }
            sheltersByMunicipality[municipalityKey]?.append(shelter)
        }
    }
    
    // 階層レベルに応じたアノテーションを取得
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
    
    // アノテーションを地図の表示範囲でフィルタリング
    private func filterAnnotationsInRegion<T: MKAnnotation>(_ annotations: [T], region: MKCoordinateRegion) -> [T] {
        return annotations.filter { annotation in
            region.contains(coordinate: annotation.coordinate)
        }
    }
    
    // 日本全体を表すアノテーション
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
    
    // 都道府県レベルのアノテーション
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
    
    // 市区町村レベルのアノテーション
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
    
    // 個別避難所のアノテーション
    private func createIndividualAnnotations(in region: MKCoordinateRegion) -> [MKAnnotation] {
        // 表示範囲内の避難所をフィルタリング
        let individualShelters = allShelters.filter { shelter in
            let coordinate = CLLocationCoordinate2D(latitude: shelter.latitude, longitude: shelter.longitude)
            return region.contains(coordinate: coordinate)
        }
        
        // 最大数を制限（パフォーマンス対策）
        let maxAnnotations = 300
        let limitedShelters = individualShelters.count > maxAnnotations ?
            Array(individualShelters.prefix(maxAnnotations)) : individualShelters
        
        return limitedShelters.map { shelter in
            return ShelterAnnotation(shelter: shelter)
        }
    }
}
