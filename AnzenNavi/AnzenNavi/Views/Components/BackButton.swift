//
//  BackButton.swift
//  AnzenNavi
//
//  Created by 田中大夢 on 2024/10/14.
//

import SwiftUI

struct BackButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10) 
    }
}

struct BackButton_Previews: PreviewProvider {
    static var previews: some View {
        BackButton()
            .previewLayout(.sizeThatFits)
    }
}

