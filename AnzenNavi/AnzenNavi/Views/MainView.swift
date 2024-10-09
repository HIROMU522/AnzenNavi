import SwiftUI
import UIKit
import FloatingPanel

// Updated MainView.swift to integrate floatingPanel modifier
struct MainView: View {
    @State private var selectedTab = 0
    var body: some View {
        ZStack {
            // 背景にMapViewを表示し、floatingPanel modifierを適用
            MapView()
                .edgesIgnoringSafeArea(.all)
                .floatingPanel(selectedTab: $selectedTab) // タブの選択状態を渡す
            VStack {
                Spacer()
                MenuBarView(selectedTab: $selectedTab)
                    .frame(height: 50)
            }
        }
    }
}


