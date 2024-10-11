//
//  MenuBarView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/09/22.
//

import SwiftUI

struct MenuBarView: View {
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
                    Image(systemName: "list.bullet")
                    Text("メニュー")
                }
                .tag(1)

            Color.clear
                .tabItem {
                    Image(systemName: "checklist")
                    Text("チェックリスト")
                }
                .tag(2)

            Color.clear
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("買い物")
                }
                .tag(3)
        }
    }
}

