//
//  ProfileView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2025/02/26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @AppStorage("log_Status") private var logStatus: Bool = true
    @State private var userName: String = "UserName"
    @State private var phoneNumber: String = ""
    @State private var showEditProfile = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // プロフィールヘッダー
                        ProfileHeaderView(userName: $userName, showEditProfileAction: {
                            showEditProfile = true
                        })
                        
                        // 設定セクション
                        SettingsSectionView(logoutAction: logOut)
                    }
                    .padding()
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
            .navigationTitle("Profile")
            .onAppear {
                loadUserProfile()
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(userName: $userName, phoneNumber: $phoneNumber, onSave: saveUserProfile)
            }
        }
    }
    
    private func loadUserProfile() {
        guard let user = Auth.auth().currentUser else { return }
        
        isLoading = true
        
        // Firebaseの認証情報からデータを取得
        if let displayName = user.displayName, !displayName.isEmpty {
            self.userName = displayName
        }
        
        if let phone = user.phoneNumber, !phone.isEmpty {
            self.phoneNumber = phone
        }
        
        // Firestoreからユーザー情報を取得
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { document, error in
            isLoading = false
            
            if let error = error {
                print("Error loading profile: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists, let data = document.data() {
                // Firestoreにデータが存在する場合は、それを使用
                if let name = data["name"] as? String, !name.isEmpty {
                    self.userName = name
                }
                
                if let phone = data["phoneNumber"] as? String, !phone.isEmpty {
                    self.phoneNumber = phone
                }
            } else {
                // ユーザードキュメントがまだ存在しない場合、初期データを作成
                saveUserProfile()
            }
        }
    }
    
    private func saveUserProfile() {
        guard let user = Auth.auth().currentUser else { return }
        
        // 保存するユーザーデータ
        let userData: [String: Any] = [
            "name": userName,
            "phoneNumber": phoneNumber,
            "email": user.email ?? "",
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).setData(userData, merge: true) { error in
            if let error = error {
                print("Error saving profile: \(error.localizedDescription)")
            } else {
                print("Profile successfully saved!")
            }
        }
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

// プロフィールヘッダー
struct ProfileHeaderView: View {
    @Binding var userName: String
    var showEditProfileAction: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // プロフィール画像
            ZStack {
                Circle()
                    .fill(Color(.darkGray))
                    .frame(width: 80, height: 80)
                
                Text(String(userName.prefix(1).uppercased()))
                    .font(.system(size: 32))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(userName)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Button("Show profile") {
                    showEditProfileAction()
                }
                .font(.subheadline)
                .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .onTapGesture {
                    showEditProfileAction()
                }
        }
        .padding(.vertical)
        .contentShape(Rectangle())
        .onTapGesture {
            showEditProfileAction()
        }
    }
}

// 設定セクション
struct SettingsSectionView: View {
    var logoutAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.vertical)
            
            settingsLinkRow(icon: "person.fill", title: "Personal information")
            Divider()
            settingsLinkRow(icon: "phone.fill", title: "Emergency contacts")
            Divider()
            settingsLinkRow(icon: "mappin.and.ellipse", title: "Default location")
            Divider()
            settingsLinkRow(icon: "lock.fill", title: "Login & security")
            Divider()
            settingsLinkRow(icon: "accessibility", title: "Accessibility")
            
            Button(action: logoutAction) {
                Text("Log out")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
            .padding(.top, 20)
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
    
    private func settingsLinkRow(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 25, height: 25)
                .foregroundColor(.black)
            
            Text(title)
                .padding(.leading, 10)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 15)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
