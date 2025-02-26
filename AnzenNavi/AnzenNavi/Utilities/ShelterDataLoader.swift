//
//  ShelterDataLoader.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/10/15.
//

import Foundation

struct ShelterDataLoader {
    private static var cachedShelters: [Shelter]?
    
    static func loadSheltersFromJSON() -> [Shelter] {
        if let cached = cachedShelters {
            return cached
        }
        
        guard let url = Bundle.main.url(forResource: "shelters_data", withExtension: "json") else {
            print("shelters_data.json が見つかりません")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let sheltersData = try decoder.decode([String: [Shelter]].self, from: data)
            if let shelters = sheltersData["shelters"] {
                print("読み込んだ避難所の数: \(shelters.count)")
                cachedShelters = shelters
                
                return ShelterDataEnhancer.enhanceShelterData(shelters)
            } else {
                print("JSON データのパースに失敗しました")
                return []
            }
        } catch {
            print("エラー: \(error)")
            return []
        }
    }
    
    static func loadLimitedSheltersFromJSON(limit: Int = 1000) -> [Shelter] {
        let allShelters = loadSheltersFromJSON()
        return Array(allShelters.prefix(min(limit, allShelters.count)))
    }
}
