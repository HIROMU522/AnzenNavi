//
//  FavoriteSheltersManager.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2025/02/26.
//

import Foundation

class FavoriteSheltersManager {
    static let shared = FavoriteSheltersManager()
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "favoriteShelters"
    
    func getFavorites() -> [String] {
        return userDefaults.stringArray(forKey: favoritesKey) ?? []
    }
    
    func addFavorite(shelter: Shelter) {
        var favorites = getFavorites()
        let shelterId = shelter.id
        
        if !favorites.contains(shelterId) {
            favorites.append(shelterId)
            userDefaults.set(favorites, forKey: favoritesKey)
        }
    }
    
    func removeFavorite(shelter: Shelter) {
        var favorites = getFavorites()
        let shelterId = shelter.id
        
        favorites.removeAll(where: { $0 == shelterId })
        userDefaults.set(favorites, forKey: favoritesKey)
    }
    
    func isFavorite(shelter: Shelter) -> Bool {
        let favorites = getFavorites()
        return favorites.contains(shelter.id)
    }
    
    func toggleFavorite(shelter: Shelter) -> Bool {
        if isFavorite(shelter: shelter) {
            removeFavorite(shelter: shelter)
            return false
        } else {
            addFavorite(shelter: shelter)
            return true
        }
    }
}
