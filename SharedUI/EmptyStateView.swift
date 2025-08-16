//
//  EmptyStateView.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import SwiftUI

struct EmptyStateView: View {
    let message: String
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 10) {
                Image(systemName: "movieclapper").font(.system(size: 40)).foregroundStyle(Theme.textSecondary)
                Text(message).foregroundStyle(Theme.textSecondary)
            }
            .padding(.bottom, UIScreen.main.bounds.height * 0.2)
        }
        .ignoresSafeArea(.keyboard)
        .onTapGesture {
            dismissKeyboard()
        }
    }
}

#Preview {
    EmptyStateView(message: "Nothing to show here")
}
