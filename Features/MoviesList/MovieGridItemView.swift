//
//  MovieGridItemView.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import SwiftUI
import Kingfisher

struct MovieGridItemView: View {
    let movie: Movie
    @State private var isLoading = true

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                ShimmeringView()
                    .frame(width: UIScreen.main.bounds.width * 0.45, height: 260)
                    .background(Theme.card)

                KFImage(AppConfig.posterURL(path: movie.posterPath))
                    .onSuccess { _ in
                        isLoading = false
                    }
                    .onFailure { _ in
                        isLoading = true
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .frame(width: UIScreen.main.bounds.width * 0.45)
            }

            Text(movie.title)
                .font(.subheadline).bold()
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .padding(.top)

            Text(movie.yearString)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)

            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width * 0.45)
        .padding(8)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(height: 350)
    }
}

#Preview {
    MovieGridItemView(movie: MockData.previewMovie)
}
