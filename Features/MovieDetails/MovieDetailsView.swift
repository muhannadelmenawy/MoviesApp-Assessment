//
//  MovieDetailsView.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import SwiftUI
import Kingfisher

struct MovieDetailsView: View {
    @StateObject private var vm: MovieDetailsViewModel
    @Environment(\.dismiss) var dismiss

    init(movieID: Int) {
        _vm = StateObject(wrappedValue: MovieDetailsViewModel(movieID: movieID))
    }

    var body: some View {
        ZStack(alignment: .top) {
            Theme.primaryBackground.ignoresSafeArea()

            Group {
                if vm.isLoading && vm.details == nil {
                    LoadingStateView()
                } else if let error = vm.errorMessage, vm.details == nil {
                    ErrorStateView(error: error, retryAction: vm.load)
                } else if let details = vm.details {
                    MovieContentScrollView(details: details)
                }
            }

            NavigationOverlay()
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Subviews
private extension MovieDetailsView {

    @ViewBuilder
    func LoadingStateView() -> some View {
        VStack {
            Spacer()
            LoadingView().padding()
            Spacer()
        }
    }

    @ViewBuilder
    func ErrorStateView(error: String, retryAction: @escaping () -> Void) -> some View {
        VStack {
            Spacer()
            ErrorView(message: error, retry: retryAction)
            Spacer()
        }
    }

    @ViewBuilder
    func MovieContentScrollView(details: MovieDetails) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                MoviePosterImage(posterPath: details.posterPath)

                Spacer()

                MovieTitleAndGenres(details: details)

                if let overview = details.overview, !overview.isEmpty {
                    MovieOverview(overview: overview)
                }

                if let homepage = details.homepage, let url = URL(string: homepage), !homepage.isEmpty {
                    MovieHomepage(homepage: homepage, url: url)
                }

                MovieInfoSection(details: details)
            }
        }
    }

    @ViewBuilder
    func MoviePosterImage(posterPath: String?) -> some View {
        KFImage(AppConfig.posterURL(path: posterPath, size: "w780"))
            .placeholder {
                ZStack {
                    Theme.card
                    ProgressView()
                        .tint(Theme.accent)
                        .padding(.top, 40)
                }
            }
            .resizable()
            .scaledToFill()
            .frame(height: UIScreen.main.bounds.height * 0.4)
            .clipped()
            .overlay(
                Group {
                    if posterPath == nil {
                        ZStack {
                            Theme.card
                            Image(systemName: "movieclapper")
                                .font(.largeTitle)
                        }
                    }
                }
            )
    }

    @ViewBuilder
    func MovieTitleAndGenres(details: MovieDetails) -> some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("\(details.title) (\(Formatters.year.string(from: Formatters.parseDate(details.releaseDate) ?? Date())))")
                        .font(.title)
                        .bold()
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width * 0.6)

                if let genres = details.genres, !genres.isEmpty {
                    MovieGenresList(genres: genres)
                }

                Spacer()
            }

            Spacer()

            MoviePosterThumbnail(posterPath: details.posterPath)
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    func MovieGenresList(genres: [Genre]) -> some View {
        let maxGenresPerLine = 3
        let chunkedGenres = genres.chunked(into: maxGenresPerLine)

        VStack(alignment: .leading, spacing: 5) {
            ForEach(chunkedGenres.indices, id: \.self) { index in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(chunkedGenres[index]) { genre in
                            Text(genre.name)
                                .font(.caption).bold()
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(Theme.accent)
                                .foregroundStyle(Theme.textSelection)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    func MoviePosterThumbnail(posterPath: String?) -> some View {
        if let url = AppConfig.posterURL(path: posterPath, size: "w780") {
            KFImage(url)
                .resizable()
                .placeholder {
                    ZStack {
                        Theme.card
                        ProgressView().tint(Theme.accent)
                    }
                }
                .scaledToFill()
                .frame(width: 100, height: 140)
                .cornerRadius(8)
                .clipped()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white, lineWidth: 2)
                )
        } else {
            ZStack {
                Theme.card
                Image(systemName: "movieclapper")
                    .font(.largeTitle)
            }
            .frame(width: 100, height: 140)
            .cornerRadius(8)
            .clipped()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: 2)
            )
        }
    }

    @ViewBuilder
    func MovieOverview(overview: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Overview")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)
            Text(overview)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    func MovieHomepage(homepage: String, url: URL) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Divider()
                .foregroundColor(Theme.textSecondary)

            Text("Homepage:")
                .font(.subheadline)
                .foregroundStyle(Theme.textPrimary)

            Text(homepage)
                .font(.subheadline)
                .foregroundStyle(Theme.accent)
                .multilineTextAlignment(.leading)
                .padding(.top, 2)
                .onTapGesture {
                    UIApplication.shared.open(url)
                }

            Divider()
                .foregroundColor(Theme.textSecondary)
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    func MovieInfoSection(details: MovieDetails) -> some View {
        VStack(spacing: 8) {
            InfoRow(label: "Status", value: details.status ?? "—")
            InfoRow(label: "Languages",
                   value: (details.spokenLanguages ?? [])
                .compactMap { $0.englishName ?? $0.name }
                .joined(separator: ", ").isEmpty ? "—" :
                (details.spokenLanguages ?? [])
                .compactMap { $0.englishName ?? $0.name }
                .joined(separator: ", "))
            InfoRow(label: "Runtime", value: Formatters.runtime(details.runtime))
            InfoRow(label: "Budget", value: Formatters.currencyUSD(details.budget))
            InfoRow(label: "Revenue", value: Formatters.currencyUSD(details.revenue))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }

    @ViewBuilder
    func NavigationOverlay() -> some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .frame(width: UIScreen.main.bounds.width, height: 120)
                .foregroundColor(.black.opacity(0.5))

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.backward")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                }

                Spacer()

                Image(systemName: "paperplane")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
                    .opacity(vm.isLoading || vm.details == nil ? 0 : 1)
            }
            .padding([.horizontal, .bottom], 25)
        }
        .ignoresSafeArea()
    }

    private struct InfoRow: View {
        let label: String; let value: String
        var body: some View {
            HStack { Text(label).foregroundStyle(Theme.textSecondary); Spacer(); Text(value).foregroundStyle(Theme.textPrimary) }
                .font(.subheadline).padding(.vertical, 4)
        }
    }
}

#Preview {
    MovieDetailsView(movieID: 1)
}
