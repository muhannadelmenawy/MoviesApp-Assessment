//
//  MovieDetailsViewModel.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import Foundation
import Combine

final class MovieDetailsViewModel: ObservableObject {
    @Published var details: MovieDetails?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repo: MoviesRepositoryType
    private let movieID: Int
    private var cancellables = Set<AnyCancellable>()

    init(movieID: Int, repo: MoviesRepositoryType = MoviesRepository()) {
        self.movieID = movieID
        self.repo = repo
        load()
    }

    func load() {
        isLoading = true; errorMessage = nil
        repo.fetchDetails(id: movieID, forceRemote: true)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] d in
                guard let self else { return }
                self.isLoading = false
                if let d { self.details = d } else { self.errorMessage = "Please check your internet connection and try again" }
            }
            .store(in: &cancellables)
    }
}
