//
//  TabBarView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2025/02/26.
//

import SwiftUI

struct TabBarView: View {
    @Binding var selectedTab: Int

    var body: some View {
        TabView(selection: $selectedTab) {
            Color.clear
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
                .tag(0)

            Color.clear
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("安否確認")
                }
                .tag(1)

            Color.clear
                .tabItem {
                    Image(systemName: "bag.fill")
                    Text("防災バッグ")
                }
                .tag(2)

            Color.clear
                .tabItem {
                    Image(systemName: "note.text")
                    Text("緊急メモ")
                }
                .tag(3)

            Color.clear
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("メニュー")
                }
                .tag(4)
        }
    }
}
#Preview {
    TabBarView(selectedTab: .constant(0))
}
