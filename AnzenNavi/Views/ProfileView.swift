//
//  ProfileView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/03/10.
//

import SwiftUI

struct ProfileView: View {
    @Binding var isPresented: Bool
    @State private var dragOffset = CGFloat.zero // ドラッグによるオフセットを保持するための変数

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .padding()
                Spacer()
                Button(action: {
                    withAnimation {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20)) // フォントサイズの変更でボタンのサイズを調整
                        .padding(10) // パディングを減らしてサイズを小さく
                        .foregroundColor(.gray) // アイコンの色をグレーにして自然な見た目に
                }
            }            // プロフィール情報をここに配置
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .offset(y: max(0, dragOffset)) // ドラッグによるオフセット適用
        .animation(.spring(), value: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    dragOffset = gesture.translation.height
                }
                .onEnded { gesture in
                    if gesture.translation.height > 100 { // ドラッグの閾値を超えたら閉じる
                        withAnimation {
                            isPresented = false
                        }
                    }
                    dragOffset = .zero // ドラッグが終了したらオフセットをリセット
                }
        )
    }
}


