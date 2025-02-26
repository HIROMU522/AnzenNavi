//
//  ShelterDataEnhancer.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2025/02/26.
//

import Foundation

struct ShelterDataEnhancer {
    static func enhanceShelterData(_ shelters: [Shelter]) -> [Shelter] {
        
        return shelters.map { shelter in
            if shelter.designated_shelter {
                var enhancedShelter = shelter
                
                if shelter.address.contains("市") || shelter.address.contains("区") {
                    enhancedShelter.capacity = determineCapacity(name: shelter.name)
                }

                enhancedShelter.facilities = getBasicFacilities()
                enhancedShelter.accessInfo = nil
                enhancedShelter.phoneNumber = nil
                enhancedShelter.notes = nil
                enhancedShelter.status = .unknown
                enhancedShelter.lastUpdated = nil
                
                return enhancedShelter
            }
            
            return shelter
        }
    }
    
    private static func determineCapacity(name: String) -> Int? {
        if name.contains("学校") || name.contains("体育館") || name.contains("センター") {
            return 500
        } else if name.contains("公民館") || name.contains("会館") {
            return 200
        } else if name.contains("公園") {
            return 1000
        }
        return nil
    }
    
    private static func getBasicFacilities() -> [Shelter.Facility] {
        return [.toilet, .wifi, .power, .water, .medical, .barrierFree]
    }
    
    static func getAllFacilities() -> [Shelter.Facility] {
        return Shelter.Facility.allCases
    }
}
