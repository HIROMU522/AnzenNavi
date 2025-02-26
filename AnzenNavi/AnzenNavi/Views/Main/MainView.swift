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
                TabBarView(selectedTab: $selectedTab)
                    .frame(height: 50)
            }
        }
        .onAppear {
            restoreSelectedShelter()
        }
        .onDisappear {
            saveSelectedShelter()
        }
    }
    
    // 避難所選択状態を保存
    private func saveSelectedShelter() {

    }
    
    // 避難所選択状態を復元
    private func restoreSelectedShelter() {

    }
}

#Preview {
    MainView()
}
