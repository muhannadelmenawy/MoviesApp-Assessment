//
//  MoviesListViewModel.swift
//  MoviesApp
//
//  Created by Muhannad El Menawy on 14/08/2025.
//

import Foundation
import Combine

final class MoviesListViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedGenreIDs: Set<Int> = []

    @Published private(set) var genres: [Genre] = []
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var filtered: [Movie] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var isOffline: Bool = false
    @Published private(set) var canLoadMore: Bool = true

    private let repo: MoviesRepositoryType
    private let network: NetworkMonitor
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    private var totalPages = 1

    init(repo: MoviesRepositoryType = MoviesRepository(),
         network: NetworkMonitor = NetworkMonitor()) {
        self.repo = repo
        self.network = network
        bind()
        initialLoad()
    }

    private func bind() {
        network.$isOnline
            .map { !$0 }
            .receive(on: DispatchQueue.main)
            .assign(to: \.isOffline, on: self)
            .store(in: &cancellables)

        Publishers.CombineLatest($searchText.removeDuplicates(),
                                 $selectedGenreIDs.removeDuplicates())
        .map { [weak self] (text, genres) -> [Movie] in
            guard let self else { return [] }
            return self.applyFilters(text: text, genres: genres)
        }
        .receive(on: DispatchQueue.main)
        .assign(to: &$filtered)
    }

    private func initialLoad() {
        loadGenres(forceRemote: true)
        resetAndLoad()
    }

    private func loadGenres(forceRemote: Bool) {
        repo.fetchGenres(forceRemote: forceRemote)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.genres = $0 }
            .store(in: &cancellables)
    }

    func resetAndLoad() {
        currentPage = 1; totalPages = 1
        movies.removeAll(); canLoadMore = true
        loadNextPage()
    }

    func loadNextPage() {
        guard !isLoading, canLoadMore else { return }
        isLoading = true; errorMessage = nil

        let forceRemote = network.isOnline
        repo.fetchTrending(page: currentPage, forceRemote: forceRemote)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                guard let self else { return }
                self.isLoading = false
                guard let response = response else {
                    self.errorMessage = "Failed to load movies."
                    self.canLoadMore = false
                    return
                }
                self.totalPages = response.totalPages
                self.movies.append(contentsOf: response.results)
                self.filtered = self.applyFilters(text: self.searchText, genres: self.selectedGenreIDs)
                self.currentPage += 1
                self.canLoadMore = self.currentPage <= self.totalPages
            }
            .store(in: &cancellables)
    }

    func retry() { loadNextPage() }

    private func applyFilters(text: String, genres: Set<Int>) -> [Movie] {
        movies.filter { m in
            let matchesText = text.isEmpty || m.title.range(of: text, options: [.caseInsensitive, .diacriticInsensitive]) != nil
            let matchesGenre = genres.isEmpty || !(Set(m.genreIDs ?? []).isDisjoint(with: genres))
            return matchesText && matchesGenre
        }
    }
}
