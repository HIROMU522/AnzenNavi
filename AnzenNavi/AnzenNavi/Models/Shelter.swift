//
//  Shelter.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/10/15.
//

import Foundation
import SwiftUI

public struct Shelter: Codable, Identifiable, Equatable {
    // 一意のID（緯度経度の組み合わせを使用）
    public var id: String { "\(latitude)-\(longitude)" }
    
    // 既存フィールド
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let disasters: [String]
    let designated_shelter: Bool
    
    // 新規追加フィールド
    var capacity: Int?  // 収容可能人数
    var facilities: [Facility]?  // 利用可能な設備
    var accessInfo: String?  // アクセス情報
    var status: ShelterStatus?  // 開設状況
    var lastUpdated: Date?  // 情報更新日時
    var phoneNumber: String?  // 連絡先
    var notes: String?  // 備考・追加情報
    
    // 設備タイプの列挙型
    enum Facility: String, Codable, CaseIterable, Identifiable {
        case toilet = "トイレ"
        case wifi = "Wi-Fi"
        case power = "電源"
        case shower = "シャワー"
        case food = "食料"
        case water = "水"
        case medical = "医療"
        case barrierFree = "バリアフリー"
        case pet = "ペット可"
        case parking = "駐車場"
        
        public var id: String { self.rawValue }
        
        // アイコン名（SF Symbols）
        var iconName: String {
            switch self {
            case .toilet: return "toilet"
            case .wifi: return "wifi"
            case .power: return "bolt.fill"
            case .shower: return "drop.fill"
            case .food: return "fork.knife"
            case .water: return "drop"
            case .medical: return "cross.case.fill"
            case .barrierFree: return "figure.roll"
            case .pet: return "pawprint.fill"
            case .parking: return "car.fill"
            }
        }
        
        // 表示用の色
        var displayColor: Color {
            return .blue
        }
    }
    
    // 避難所の状態
    enum ShelterStatus: String, Codable {
        case open = "開設中"
        case closed = "未開設"
        case full = "満員"
        case limited = "一部利用可"
        case unknown = "状況不明"
        
        var color: String {
            switch self {
            case .open: return "green"
            case .closed: return "gray"
            case .full: return "red"
            case .limited: return "orange"
            case .unknown: return "gray"
            }
        }
    }
    
    // 利用可能な設備かどうかを判定
    func isFacilityAvailable(_ facility: Facility) -> Bool {
        guard let facilities = facilities else {
            return false
        }
        return facilities.contains(facility)
    }
    
    // Equatableプロトコル準拠のための実装
    public static func == (lhs: Shelter, rhs: Shelter) -> Bool {
        lhs.id == rhs.id
    }
    
    // モデル変更に伴い、既存のJSONファイルと互換性を持たせるためのCodingKeys
    enum CodingKeys: String, CodingKey {
        case name, address, latitude, longitude, disasters, designated_shelter
        case capacity, facilities, accessInfo, status, lastUpdated, phoneNumber, notes
    }
    
    // サンプルデータを生成するための初期化メソッド
    static func sample() -> Shelter {
        return Shelter(
            name: "サンプル避難所",
            address: "東京都新宿区新宿1-1-1",
            latitude: 35.6895,
            longitude: 139.6917,
            disasters: ["地震", "洪水", "火災"],
            designated_shelter: true,
            capacity: 500,
            facilities: [.toilet, .wifi, .power, .water],
            accessInfo: nil,
            status: .unknown,
            lastUpdated: nil,
            phoneNumber: nil,
            notes: nil
        )
    }
}
