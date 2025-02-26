//
//  MainView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/10/15.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0
    @State private var selectedShelter: Shelter?
    
    var body: some View {
        ZStack {
            MapView(selectedShelter: $selectedShelter)
                .floatingPanel(selectedTab: $selectedTab, selectedShelter: $selectedShelter)
            VStack {
                Spacer()
                MenuBarView(selectedTab: $selectedTab)
                    .frame(height: 50)
            }
        }
        .onAppear {
            // 前回の選択状態を復元（必要な場合）
            restoreSelectedShelter()
        }
        .onDisappear {
            // 現在の選択状態を保存（必要な場合）
            saveSelectedShelter()
        }
    }
    
    // 避難所選択状態を保存
    private func saveSelectedShelter() {
        // 実際の実装ではUserDefaults等に保存
        // ここでは例示のため省略
    }
    
    // 避難所選択状態を復元
    private func restoreSelectedShelter() {
        // 実際の実装ではUserDefaults等から復元
        // ここでは例示のため省略
    }
}

#Preview {
    MainView()
}
