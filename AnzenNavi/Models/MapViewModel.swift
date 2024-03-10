//
//  MapViewModel.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/03/10.
//

import Foundation
import MapKit

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 位置情報サービスの状態を確認
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location.coordinate
    }

    // 位置情報サービスの利用許可が変更された時の処理
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            // 適切なハンドリング（ユーザーに設定変更を促すなど）
            break
        }
    }

    // 位置情報の更新に失敗した場合の処理
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // エラーハンドリングの実装
        print("位置情報の取得に失敗: \(error)")
    }
}
