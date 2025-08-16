//
//  ShimmeringView.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 15/08/2025.
//

import SwiftUI

///  Used to be shown until the movie poster loads
struct ShimmeringView: View {
    @State private var gradientStart: UnitPoint = UnitPoint(x: -1.5, y: 0.5)
    @State private var gradientEnd: UnitPoint = UnitPoint(x: -0.5, y: 0.5)

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [.clear, .white.opacity(0.2), .clear]),
            startPoint: gradientStart,
            endPoint: gradientEnd
        )
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                self.gradientStart = UnitPoint(x: 1.5, y: 0.5)
                self.gradientEnd = UnitPoint(x: 2.5, y: 0.5)
            }
        }
        .mask(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    ShimmeringView()
}
