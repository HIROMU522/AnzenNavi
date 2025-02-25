//
//  HierarchicalAnnotation.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2025/02/26.
//

import MapKit

class HierarchicalAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var level: ClusteringLevel
    var count: Int
    var identifier: String
    var shelters: [Shelter]
    
    init(coordinate: CLLocationCoordinate2D,
         title: String,
         subtitle: String? = nil,
         level: ClusteringLevel,
         count: Int,
         identifier: String,
         shelters: [Shelter]) {
        
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.level = level
        self.count = count
        self.identifier = identifier
        self.shelters = shelters
        
        super.init()
    }
    
    // 包含されている避難所から中心座標を計算するコンビニエンスイニシャライザ
    convenience init(title: String,
                     subtitle: String? = nil,
                     level: ClusteringLevel,
                     identifier: String,
                     shelters: [Shelter]) {
        
        let coordinate = Self.calculateCenterCoordinate(for: shelters)
        
        self.init(
            coordinate: coordinate,
            title: title,
            subtitle: subtitle,
            level: level,
            count: shelters.count,
            identifier: identifier,
            shelters: shelters
        )
    }
    
    // 複数の避難所の中心座標を計算するヘルパーメソッド
    static func calculateCenterCoordinate(for shelters: [Shelter]) -> CLLocationCoordinate2D {
        guard !shelters.isEmpty else {
            return CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917) // 東京
        }
        
        let totalLat = shelters.reduce(0.0) { $0 + $1.latitude }
        let totalLong = shelters.reduce(0.0) { $0 + $1.longitude }
        
        return CLLocationCoordinate2D(
            latitude: totalLat / Double(shelters.count),
            longitude: totalLong / Double(shelters.count)
        )
    }
}
