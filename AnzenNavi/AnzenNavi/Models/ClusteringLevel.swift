//
//  ClusteringLevel.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2025/02/26.
//

import Foundation
import MapKit

enum ClusteringLevel: Int {
    case country = 0
    case prefecture = 1
    case municipality = 2
    case individual = 3
    
    static func forZoomLevel(_ zoomLevel: Double) -> ClusteringLevel {
        switch zoomLevel {
        case 0..<6:   return .country
        case 6..<9:   return .prefecture
        case 9..<12:  return .municipality
        default:      return .individual
        }
    }
    
    var recommendedZoomLevel: Double {
        switch self {
        case .country:      return 5.0
        case .prefecture:   return 7.5
        case .municipality: return 10.5
        case .individual:   return 14.0
        }
    }
}
