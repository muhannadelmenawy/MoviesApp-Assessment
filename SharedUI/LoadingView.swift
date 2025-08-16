//
//  LoadingView.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 10) {
            ProgressView().tint(Theme.accent)
            Text("Loading...").foregroundStyle(Theme.textSecondary)
        }
    }
}

#Preview {
    LoadingView()
}
