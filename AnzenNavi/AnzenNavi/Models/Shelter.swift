//
//  Shelter.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/10/15.
//

import Foundation

public struct Shelter: Codable, Equatable {
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let disasters: [String]
    let designated_shelter: Bool
}


