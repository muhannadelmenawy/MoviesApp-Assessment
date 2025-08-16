//
//  ErrorView.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let retry: () -> Void
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 40)).foregroundStyle(Theme.accent)
                Text(message).multilineTextAlignment(.center).foregroundStyle(Theme.textPrimary)
            }
            .frame(width: UIScreen.main.bounds.width * 0.8)
            Spacer()
            HStack {
                Image(systemName: "arrow.trianglehead.2.counterclockwise")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(Theme.textSecondary)
                Button {
                    triggerHapticFeedback()
                    retry()
                }label: {
                    Text("Retry").foregroundColor(.white)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ErrorView(message: "Something went wrong", retry: {})
}
