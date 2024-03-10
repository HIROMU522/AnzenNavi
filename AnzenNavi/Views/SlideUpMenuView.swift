//
//  SlideUpMenuView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/03/10.
//

import SwiftUI
import MapKit

struct SlideUpMenuView: View {
    @Binding var menuState: ContentView.MenuState
    @Binding var isProfilePresented: Bool
    @Binding var selectedResult: MKMapItem?
    @Binding var route: MKRoute?
    @Binding var searchResults: [MKMapItem]
    @Binding var position: MapCameraPosition
    var visibleRegion: MKCoordinateRegion?
    

    var body: some View {
        GeometryReader { geometry in // GeometryReaderを使用して親ビューのサイズを取得
            ZStack(alignment: .topTrailing) { // ZStackで要素を重ね、右上にアイコンを配置
                VStack {
                    Capsule()
                        .frame(width: 40, height: 5)
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(10)
                    if let selectedResult {
                        ItemInfoView(selectedResult: selectedResult, route: route)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding([.top, .horizontal])
                    }
                    Buttons(searchResults: $searchResults, position: $position, visibleRegion: visibleRegion)
                        .padding(.top)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                
                // アイコンを配置
                Button(action: {
                    isProfilePresented = true
                }) {
                    Image(systemName: "person.crop.circle.fill") // ユーザーアイコン
                        .resizable()
                        .frame(width: 32, height: 32) // アイコンのサイズ指定
                        .padding(.trailing, 20) // 右側の余白
                        .padding(.top, 20) // 上側の余白
                }
            }
            .frame(height: geometry.size.height) // GeometryReaderから取得した高さを使用
        }
    }
    
}

