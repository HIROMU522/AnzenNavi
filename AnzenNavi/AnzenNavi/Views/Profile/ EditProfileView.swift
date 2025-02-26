//
//  EditProfileView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2025/02/26.
//

import SwiftUI
import FirebaseAuth

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var userName: String
    @Binding var phoneNumber: String
    
    @State private var editedName: String = ""
    @State private var editedPhoneNumber: String = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var onSave: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section(header: Text("ユーザー情報")) {
                        TextField("名前", text: $editedName)
                        
                        TextField("電話番号", text: $editedPhoneNumber)
                            .keyboardType(.phonePad)
                    }
                    
                    Section {
                        Button(action: saveProfile) {
                            Text("保存")
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
                
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .background(Color(.systemBackground).opacity(0.8))
                        .cornerRadius(10)
                        .padding(50)
                }
            }
            .navigationTitle("プロフィール編集")
            .navigationBarItems(leading: Button("キャンセル") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                // 既存の値を編集フィールドに設定
                editedName = userName
                editedPhoneNumber = phoneNumber
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("メッセージ"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func saveProfile() {
        // 名前が空でないことを確認
        if editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "名前を入力してください"
            showAlert = true
            return
        }
        
        isLoading = true
        
        // 親ビューの値を更新
        userName = editedName
        phoneNumber = editedPhoneNumber
        
        // 保存処理を実行（親ビューから渡されたコールバック）
        onSave()
        
        // 少し遅延してからフォームを閉じる
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(
            userName: .constant("UserName"),
            phoneNumber: .constant("090-1234-5678"),
            onSave: {}
        )
    }
}
