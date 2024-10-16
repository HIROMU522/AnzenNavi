//
//  HomeContentView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/09/22.
//

import SwiftUI

struct HomeContentView: View {
    var shelter: Shelter

    var body: some View {
        VStack(alignment: .leading) {
            Text(shelter.name)
                .font(.title)
                .padding(.bottom, 2)
            Text("住所: \(shelter.address)")
                .padding(.bottom, 2)
            Text("災害種別: \(shelter.disasters.joined(separator: ", "))")
                .padding(.bottom, 2)
            Text("指定避難所: \(shelter.designated_shelter ? "はい" : "いいえ")")
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(10)
        .padding()
    }
}

struct HomeContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeContentView(shelter: Shelter(name: "テスト避難所", address: "テスト住所", latitude: 0.0, longitude: 0.0, disasters: ["地震", "津波"], designated_shelter: true))
    }
}


