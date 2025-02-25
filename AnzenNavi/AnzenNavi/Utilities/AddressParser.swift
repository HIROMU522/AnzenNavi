//
//  AddressParser.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2025/02/26.
//

import Foundation

struct AddressComponents {
    let prefecture: String
    let municipality: String
    let detail: String
}

class AddressParser {
    
    static func parseJapaneseAddress(_ address: String) -> AddressComponents {
        // 都道府県のパターン
        let prefecturePatterns = [
            "北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県",
            "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県", "東京都", "神奈川県",
            "新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県",
            "静岡県", "愛知県", "三重県", "滋賀県", "京都府", "大阪府", "兵庫県",
            "奈良県", "和歌山県", "鳥取県", "島根県", "岡山県", "広島県", "山口県",
            "徳島県", "香川県", "愛媛県", "高知県", "福岡県", "佐賀県", "長崎県",
            "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"
        ]
        
        // 都道府県の抽出
        var prefecture = ""
        for pattern in prefecturePatterns {
            if address.hasPrefix(pattern) {
                prefecture = pattern
                break
            }
        }
        
        // 都道府県を除いた残りの住所
        var remainingAddress = address
        if !prefecture.isEmpty {
            remainingAddress = address.replacingOccurrences(of: prefecture, with: "")
        }
        
        // 市区町村の抽出（最初の「市」「区」「町」「村」まで）
        var municipality = ""
        var detail = remainingAddress
        
        // 市を検索
        if let cityRange = remainingAddress.range(of: "市") {
            let cityEndIndex = cityRange.upperBound
            municipality = String(remainingAddress[..<cityEndIndex])
            detail = String(remainingAddress[cityEndIndex...])
        }
        // 区を検索（市が見つからなかった場合）
        else if let wardRange = remainingAddress.range(of: "区") {
            let wardEndIndex = wardRange.upperBound
            municipality = String(remainingAddress[..<wardEndIndex])
            detail = String(remainingAddress[wardEndIndex...])
        }
        // 町を検索（市と区が見つからなかった場合）
        else if let townRange = remainingAddress.range(of: "町") {
            let townEndIndex = townRange.upperBound
            municipality = String(remainingAddress[..<townEndIndex])
            detail = String(remainingAddress[townEndIndex...])
        }
        // 村を検索（市、区、町が見つからなかった場合）
        else if let villageRange = remainingAddress.range(of: "村") {
            let villageEndIndex = villageRange.upperBound
            municipality = String(remainingAddress[..<villageEndIndex])
            detail = String(remainingAddress[villageEndIndex...])
        }
        
        // 先頭と末尾の空白を削除
        detail = detail.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return AddressComponents(
            prefecture: prefecture,
            municipality: municipality,
            detail: detail
        )
    }
}
