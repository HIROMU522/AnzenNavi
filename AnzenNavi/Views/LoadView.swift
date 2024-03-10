//
//  LoadView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/03/10.
//

import SwiftUI

// メインビュー
struct LoadView: View {
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.86, blue: 0.52)
                .edgesIgnoringSafeArea(.all)
            
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 300, height: 300)
            
        }
    }
}

#Preview {
    LoadView()
}
