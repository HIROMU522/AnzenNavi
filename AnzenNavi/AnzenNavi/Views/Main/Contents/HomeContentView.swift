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
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            scrollableContent
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        HStack {
            Text(shelter.name)
                .font(.system(size: 25, weight: .bold))
                .padding([.top, .leading], 30)
            Spacer()
        }
        .background(Color.white)
        .zIndex(1)
    }

    private var scrollableContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                detailsSection
                Spacer() 
            }
            .padding(.bottom)
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            addressAndDesignation
            disastersCapsuleView
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }

    private var addressAndDesignation: some View {
        HStack {
            Text(shelter.address)
                .font(.system(size: 15))
            Spacer()
            if shelter.designated_shelter {
                Text("指定避難所")
                    .font(.system(size: 15))
            }
        }
    }

    private var disastersCapsuleView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(shelter.disasters, id: \.self) { disaster in
                    Text(disaster)
                        .font(.system(size: 12))
                        .foregroundColor(.black)
                        .frame(width: 60, height: 30)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .overlay(
                            Capsule().stroke(Color.black, lineWidth: 1)
                        )
                }
            }
            .padding([.top, .bottom], 10)
        }
    }
}

struct HomeContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeContentView(shelter: Shelter(
                name: "指定避難所あり",
                address: "東京都新宿区",
                latitude: 0.0,
                longitude: 0.0,
                disasters: ["地震", "津波"],
                designated_shelter: true
            ))
            .previewDisplayName("指定避難所: はい")

            HomeContentView(shelter: Shelter(
                name: "指定避難所なし",
                address: "大阪府大阪市",
                latitude: 0.0,
                longitude: 0.0,
                disasters: ["洪水", "土砂崩れ"],
                designated_shelter: false
            ))
            .previewDisplayName("指定避難所: いいえ")
        }
    }
}

