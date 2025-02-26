//
//  ShelterDataEnhancer.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2025/02/26.
//

import Foundation

struct ShelterDataEnhancer {
    /// 避難所データに追加情報を付与する
    static func enhanceShelterData(_ shelters: [Shelter]) -> [Shelter] {
        // 本来は各避難所の固有情報をデータベースから取得するが、
        // デモ用に一部の避難所にのみ情報を追加（ランダム生成ではなく）
        
        return shelters.map { shelter in
            // 指定避難所のみに追加情報を設定
            if shelter.designated_shelter {
                var enhancedShelter = shelter
                
                // 特定の施設のみに収容人数情報を追加
                if shelter.address.contains("市") || shelter.address.contains("区") {
                    enhancedShelter.capacity = determineCapacity(name: shelter.name)
                }
                
                // 利用可能な設備情報（最大6つの代表的な設備）
                enhancedShelter.facilities = getBasicFacilities()
                
                // 固定情報として設定（実際のデータを入れる場合は置き換える）
                // 現時点では情報なしとして表示するため、nilのままにしておく
                enhancedShelter.accessInfo = nil
                enhancedShelter.phoneNumber = nil
                enhancedShelter.notes = nil
                
                // ステータスは指定避難所のみ開設可能性あり
                enhancedShelter.status = .unknown
                
                // 情報更新日は現時点ではなし
                enhancedShelter.lastUpdated = nil
                
                return enhancedShelter
            }
            
            // 指定避難所でない場合は情報追加なし
            return shelter
        }
    }
    
    // 施設名から適切な収容人数を推定（実際のデータがあれば置き換え）
    private static func determineCapacity(name: String) -> Int? {
        // 学校や大きな施設は収容人数が多い傾向
        if name.contains("学校") || name.contains("体育館") || name.contains("センター") {
            return 500
        } else if name.contains("公民館") || name.contains("会館") {
            return 200
        } else if name.contains("公園") {
            return 1000
        }
        // その他の施設は情報なしとして nil を返す
        return nil
    }
    
    // 基本的な設備情報を返す
    private static func getBasicFacilities() -> [Shelter.Facility] {
        // 代表的な設備6つを返す（本来はデータベースから取得）
        return [.toilet, .wifi, .power, .water, .medical, .barrierFree]
    }
    
    // すべての利用可能な設備情報を返す
    static func getAllFacilities() -> [Shelter.Facility] {
        return Shelter.Facility.allCases
    }
}
