//
//  MenuBarView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/09/22.
//

import SwiftUI

struct MenuBarView: View {
    @Binding var selectedTab: Int  // 親ビューからタブの選択状態を受け取る

    var body: some View {
        TabView(selection: $selectedTab) {
            // ホームタブ
            Color.clear  // 色を変えるだけにするので中身は透明
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
                .tag(0)

            // メニュータブ
            Color.clear  // 色を変えるだけにするので中身は透明
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("メニュー")
                }
                .tag(1)

            // チェックリストタブ
            Color.clear  // 色を変えるだけにするので中身は透明
                .tabItem {
                    Image(systemName: "checklist")
                    Text("チェックリスト")
                }
                .tag(2)

            // 買い物タブ
            Color.clear  // 色を変えるだけにするので中身は透明
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("買い物")
                }
                .tag(3)
        }
    }
}

