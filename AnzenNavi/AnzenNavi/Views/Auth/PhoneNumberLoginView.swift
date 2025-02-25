//
//  PhoneNumberLoginView.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/10/09.
//

import SwiftUI
import FirebaseAuth
import Combine


struct PhoneNumberLoginView: View {
    @Binding var navigationPath: NavigationPath
    @State private var presentSheet = false
    @State private var countryCode = "+1"
    @State private var countryFlag = "🇺🇸"
    @State private var countryPattern = "### ### ####"
    @State private var mobPhoneNumber = ""
    @State private var searchCountry = ""
    @State private var verificationID: String?
    @State private var errorMessage = ""
    @State private var showAlert = false
    @State private var isLoading = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme
    @FocusState private var isFocused: Bool
    
    let countries: [CPData] = Bundle.main.decode("CountryNumbers.json")
    
    var body: some View {
        VStack {
            BackButton()
            headerText
            phoneNumberInputSection
            otherSignInMethodsLink
            Spacer()
            sendButton
        }
        .overlay {
            if isLoading {
                LoadingScreen()
            }
        }
        .onAppear { isFocused = true }
        .sheet(isPresented: $presentSheet) { countrySelectionSheet }
        .alert(isPresented: $showAlert) { errorAlert }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - View Components
    
    private var headerText: some View {
        Text("Confirm country code and enter phone number")
            .multilineTextAlignment(.center)
            .font(.title).bold()
            .padding(.top, 20)
    }
    
    private var phoneNumberInputSection: some View {
        HStack{
            countryButton
            phoneNumberTextField
        }
        .padding(.vertical, 20)
        .padding(.horizontal)
    }
    
    private var countryButton: some View {
        Button {
            presentSheet = true
            isFocused = false
        } label: {
            Text("\(countryFlag) \(countryCode)")
                .padding(10)
                .frame(minWidth: 80, minHeight: 47)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .foregroundColor(foregroundColor)
        }
    }
    
    private var phoneNumberTextField: some View {
        TextField("", text: $mobPhoneNumber)
            .placeholder(when: mobPhoneNumber.isEmpty) {
                Text("Phone number")
                    .foregroundColor(.secondary)
            }
            .focused($isFocused)
            .keyboardType(.phonePad)
            .onReceive(Just(mobPhoneNumber)) { _ in
                applyPatternOnNumbers(&mobPhoneNumber, pattern: countryPattern, replacementCharacter: "#")
            }
            .padding(10)
            .frame(minWidth: 80, minHeight: 47)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
    
    private var sendButton: some View {
        Button(action: {
            sendVerificationCode()
            isFocused = false
        }) {
            Text("Next")
                .font(.system(.body, design: .rounded))
                .fontWeight(.heavy)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .background(Color.green)
        .disabled(mobPhoneNumber.count < 1)
        .opacity(mobPhoneNumber.count < 1 ? 0.6 : 1)
        .edgesIgnoringSafeArea(.horizontal)
    }
    
    private var otherSignInMethodsLink: some View {
        HStack {
            Text("Sign in with other ")
                .foregroundColor(.gray)
            Text("methods")
                .foregroundColor(.green)
                .onTapGesture { dismiss() }
        }
        .padding(.top, 10)
    }
    
    private var countrySelectionSheet: some View {
        NavigationView {
            List(filteredCountries) { country in
                HStack {
                    Text(country.flag)
                    Text(country.name)
                        .font(.headline)
                    Spacer()
                    Text(country.dial_code)
                        .foregroundColor(.secondary)
                }
                .onTapGesture {
                    selectCountry(country)
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchCountry, prompt: "Your country")
        }
        .presentationDetents([.medium, .large])
    }
    
    private var errorAlert: Alert {
        Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
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
    
    private var filteredCountries: [CPData] {
        searchCountry.isEmpty ? countries : countries.filter { $0.name.localizedCaseInsensitiveContains(searchCountry) }
    }
    
    private var foregroundColor: Color {
        scheme == .dark ? .white : .black
    }
    
    private var backgroundColor: Color {
        scheme == .dark ? Color(.systemGray5) : Color(.systemGray6)
    }
    
    private func sendVerificationCode() {
        isLoading = true
        let fullPhoneNumber = "\(countryCode) \(mobPhoneNumber)"
        PhoneAuthProvider.provider().verifyPhoneNumber(fullPhoneNumber, uiDelegate: nil) { verificationID, error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
            } else {
                let info = VerificationInfo(verificationID: verificationID ?? "", phoneNumber: fullPhoneNumber)
                navigationPath.append(SignInDestination.verification(info))
            }
        }
    }
    
    private func selectCountry(_ country: CPData) {
        countryFlag = country.flag
        countryCode = country.dial_code
        countryPattern = country.pattern
        presentSheet = false
        searchCountry = ""
    }
    
    private func applyPatternOnNumbers(_ stringvar: inout String, pattern: String, replacementCharacter: Character) {
        var pureNumber = stringvar.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0..<pattern.count {
            guard index < pureNumber.count else {
                stringvar = pureNumber
                return
            }
            let stringIndex = String.Index(utf16Offset: index, in: pattern)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacementCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        stringvar = pureNumber
    }
}

struct PhoneNumberLoginView_Previews: PreviewProvider {
    @State static var navigationPath = NavigationPath()
    
    static var previews: some View {
        PhoneNumberLoginView(navigationPath: $navigationPath)
    }
}

