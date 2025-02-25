//
//  MenuContentView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/09/22.
//

import SwiftUI
import FirebaseAuth

struct MenuContentView: View {
    @AppStorage("log_Status") private var logStatus: Bool = true
    
    var body: some View {
        VStack {
            Text("メニュー画面のコンテンツ")
            Button(action: {
                logOut()
            }) {
                Text("Log Out")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    private func logOut() {
        do {
            try Auth.auth().signOut()
            logStatus = false 
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

struct MenuContentView_Previews: PreviewProvider {
    static var previews: some View {
        MenuContentView()
    }
}
