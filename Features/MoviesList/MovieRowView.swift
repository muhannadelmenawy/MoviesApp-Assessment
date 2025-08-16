//
//  MovieRowView.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import SwiftUI

struct MovieRowView: View {
    let movie: Movie

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: AppConfig.posterURL(path: movie.posterPath)) { phase in
                switch phase {
                case .empty: ZStack { Color.gray.opacity(0.2); ProgressView() }
                case .success(let image): image.resizable().scaledToFill()
                case .failure: ZStack { Color.gray.opacity(0.2); Image(systemName: "movieclapper") }
                @unknown default: EmptyView()
                }
            }
            .frame(width: 80, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(movie.yearString)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    MovieRowView(movie: MockData.previewMovie)
}
