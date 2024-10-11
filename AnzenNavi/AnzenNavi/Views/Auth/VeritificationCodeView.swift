//
//  VerificationCodeView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/10/10.
//

import SwiftUI
import FirebaseAuth
import Combine

struct VerificationCodeView: View {
    @State var verificationID: String
    @State var phoneNumber: String
    @State private var verificationCode: [String] = Array(repeating: "", count: 6)
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @AppStorage("log_Status") private var logStatus: Bool = false
    @FocusState private var focusedField: Int?
    
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack {
            headerText
            instructionText
            verificationCodeInput
            resendButton
            Spacer()
            verifyButton
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            focusedField = 0
        }
    }
    
    // MARK: - View Components
    
    private var headerText: some View {
        Text("Phone Verification")
            .font(.title)
            .bold()
            .padding(.top, 50)
    }
    
    private var instructionText: some View {
        Text("Enter your OTP code here")
            .foregroundColor(.secondary)
            .padding(.top, 5)
    }
    
    private var verificationCodeInput: some View {
        HStack(spacing: 10) {
            ForEach(0..<6, id: \.self) { index in
                singleCodeField(at: index)
            }
        }
        .padding(.vertical, 30)
    }
    
    private func singleCodeField(at index: Int) -> some View {
        TextField("", text: $verificationCode[index])
            .frame(width: 40, height: 50)
            .background(backgroundColor)
            .cornerRadius(10)
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .focused($focusedField, equals: index)
            .onChange(of: verificationCode[index]) { newValue, oldValue in
                handleInputChange(newValue, at: index)
            }
    }
    
    private var resendButton: some View {
        Button(action: resendCode) {
            Text("Resend a new code.")
                .foregroundColor(.red)
        }
        .padding(.bottom, 20)
    }
    
    private var verifyButton: some View {
        Button(action: verifyCode) {
            Text("Verify")
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .background(Color.blue)
        .edgesIgnoringSafeArea(.horizontal)
    }
    
    // MARK: - Helper Views
    
    private var backgroundColor: Color {
        scheme == .dark ? Color(.systemGray5) : Color(.systemGray6)
    }
    
    // MARK: - Helper Methods
    
    private func handleInputChange(_ newValue: String, at index: Int) {
        if newValue.count == 1 {
            if index < 5 {
                focusedField = index + 1
            } else {
                focusedField = nil
            }
        } else if newValue.isEmpty {
            if index > 0 {
                focusedField = index - 1
                verificationCode[index - 1] = ""
            }
        } else if newValue.count > 1 {
            verificationCode[index] = String(newValue.prefix(1))
        }
    }
    
    private func verifyCode() {
        let code = verificationCode.joined()
        guard code.count == 6 else {
            errorMessage = "Please enter the complete 6-digit code."
            showAlert = true
            return
        }
        
        guard !verificationID.isEmpty else {
            errorMessage = "Verification ID not found."
            showAlert = true
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
                return
            }
            logStatus = true
        }
    }
    
    private func resendCode() {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
                return
            }
            
            if let verificationID = verificationID {
                self.verificationID = verificationID
                errorMessage = "A new code has been sent."
                showAlert = true
                verificationCode = Array(repeating: "", count: 6)
                focusedField = 0
            }
        }
    }
}

struct VerificationCodeView_Previews: PreviewProvider {
    static var previews: some View {
        VerificationCodeView(verificationID: "dummyID", phoneNumber: "+1 2345678910")
    }
}

