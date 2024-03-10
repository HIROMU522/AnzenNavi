//
//  ItemInfoView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/03/10.
//

import SwiftUI
import MapKit

struct ItemInfoView: View {
    var selectedResult: MKMapItem
    var route: MKRoute?
    @State private var evacuees: Int = 0 // 避難者数を追加

    var body: some View {
        VStack(alignment: .leading) {
            if let name = selectedResult.name {
                Text(name)
                    .font(.headline)
                    .padding()
            }

            if let route = route {
                Text("推定所要時間: \(travelTime(from: route.expectedTravelTime))")
                    .font(.subheadline)
                    .padding()
            }
            
            // 避難者数とプラスボタンを表示
            HStack {
                Text("避難者数: \(evacuees)")
                    .font(.subheadline)
                    .padding([.top, .bottom, .leading])
                
                Button(action: {
                    self.evacuees += 1
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                }
                .padding([.top, .bottom, .trailing])
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cornerRadius(10)
        .shadow(radius: 5)
    }

    private func travelTime(from expectedTravelTime: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: expectedTravelTime) ?? ""
    }
}

