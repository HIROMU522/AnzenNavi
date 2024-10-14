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
    @State private var otpText: String = ""
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var isLoading = false
    @AppStorage("log_Status") private var logStatus: Bool = false
    @FocusState private var isFocused: Bool

    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss 

    var body: some View {
        VStack {
            BackButton()
            headerText
            instructionText
            otpInputBoxes
            resendButton
            Spacer()
            verifyButton
        }
        .overlay {
            if isLoading {
                LoadingScreen()
            }
        }
        .onAppear { isFocused = true }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
        .navigationBarBackButtonHidden(true)
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

    private var otpInputBoxes: some View {
        HStack(spacing: 10) {
            ForEach(0..<6, id: \.self) { index in
                OTPTextBox(index)
            }
        }
        .background(content: {
            // Hidden TextField for the entire OTP input
            TextField("", text: $otpText.limit(6))
                .keyboardType(.numberPad)
                .frame(width: 1, height: 1)
                .opacity(0.001)
                .blendMode(.screen)
                .focused($isFocused)
        })
        .contentShape(Rectangle())
        .padding(.vertical, 30)
        .onTapGesture {
            isFocused = true
        }
    }

    // MARK: OTP Text Box with Animation
    private func OTPTextBox(_ index: Int) -> some View {
        ZStack {
            if otpText.count > index {
                let startIndex = otpText.startIndex
                let charIndex = otpText.index(startIndex, offsetBy: index)
                let charToString = String(otpText[charIndex])
                Text(charToString)
                    .font(.title2)
                    .bold()
            } else {
                Text(" ")
            }
        }
        .frame(width: 45, height: 45)
        .background {
            let isFocusedBox = (otpText.count == index)
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(isFocusedBox ? .black : .gray, lineWidth: isFocusedBox ? 1 : 0.5)
                .animation(.easeInOut(duration: 0.2), value: isFocusedBox)
        }
        .background {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(.gray, lineWidth: 0.5)
        }
        .cornerRadius(6)
    }

    private var resendButton: some View {
        Button(action: {
            isFocused = false
            resendCode()
        }) {
            Text("Resend a new code.")
                .foregroundColor(.red)
        }
        .padding(.bottom, 20)
    }

    private var verifyButton: some View {
        Button(action: {
            isFocused = false
            verifyCode()
        }) {
            Text("Verify")
                .font(.system(.body, design: .rounded))
                .fontWeight(.heavy)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .background(Color.green)
        .disabled(otpText.count < 6)
        .opacity(otpText.count < 6 ? 0.6 : 1)
        .edgesIgnoringSafeArea(.horizontal)
    }

    // MARK: - Helper Views

    @ViewBuilder
    private func LoadingScreen() -> some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
    
            ProgressView()
                .frame(width: 45, height: 45)
                .background(.background, in: RoundedRectangle(cornerRadius: 5))
        }
    }

    // MARK: - Helper Methods

    private func verifyCode() {
        isLoading = true
        let code = otpText
        guard code.count == 6 else {
            errorMessage = "Please enter the complete 6-digit code."
            showAlert = true
            isLoading = false
            return
        }

        guard !verificationID.isEmpty else {
            errorMessage = "Verification ID not found."
            showAlert = true
            isLoading = false
            return
        }

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)
        Auth.auth().signIn(with: credential) { authResult, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
                return
            }
            logStatus = true
        }
    }

    private func resendCode() {
        isLoading = true
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
                return
            }

            if let verificationID = verificationID {
                self.verificationID = verificationID
                errorMessage = "A new code has been sent."
                showAlert = true
                otpText = ""
                isFocused = true
            }
        }
    }
}

// MARK: - View Extensions
extension View {
    func disableWithOpacity(_ condition: Bool) -> some View {
        self
            .disabled(condition)
            .opacity(condition ? 0.6 : 1)
    }
}

// MARK: - Binding<String> Extension
extension Binding where Value == String {
    func limit(_ length: Int) -> Self {
        if self.wrappedValue.count > length {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.prefix(length))
            }
        }
        return self
    }
}

struct VerificationCodeView_Previews: PreviewProvider {
    static var previews: some View {
        VerificationCodeView(verificationID: "dummyID", phoneNumber: "+1 2345678910")
    }
}

