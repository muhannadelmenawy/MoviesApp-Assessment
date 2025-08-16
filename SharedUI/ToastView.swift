//
//  ToastView.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 15/08/2025.
//

import SwiftUI

struct ToastView: View {
    let message: String
    let backgroundColor: Color
    let textColor: Color

    var body: some View {
        Text(message)
            .font(.body)
            .fontWeight(.medium)
            .padding()
            .foregroundColor(textColor)
            .background(backgroundColor.opacity(0.5))
            .cornerRadius(8)
            .shadow(radius: 10)
            .multilineTextAlignment(.center)
            .frame(width: UIScreen.main.bounds.width * 0.8)
    }
}

#Preview {
    ToastView(message: "Connection Restored", backgroundColor: .green, textColor: .white)
}
