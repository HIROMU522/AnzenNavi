//
//  MainView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/09/21.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            Text("Main Screen")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            // ここにメイン画面のコンテンツを追加できます
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
