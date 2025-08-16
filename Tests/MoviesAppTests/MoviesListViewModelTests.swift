//
//  MoviesListViewModelTests.swift
//  MoviesAppTests
//
//  Created by Muhannad El Menawy on 16/08/2025.
//

import XCTest
import Combine
@testable import MoviesApp

final class MoviesListViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func makeVM(movies: [Movie] = [], genres: [Genre] = []) -> MoviesListViewModel {
        let repo = FakeRepo(movies: movies, genres: genres)
        // network monitor is not used directly in filtering; defaults fine
        return MoviesListViewModel(repo: repo)
    }

    func testSearchTextFiltersLocally() {
        let movies = [
            Movie(id: 1, title: "Ratatouille", posterPath: nil, releaseDate: "2007-01-01", genreIDs: [16]),
            Movie(id: 2, title: "Toy Story", posterPath: nil, releaseDate: "1995-01-01", genreIDs: [16]),
            Movie(id: 3, title: "Tangled", posterPath: nil, releaseDate: "2010-01-01", genreIDs: [16])
        ]

        let vm = makeVM(movies: movies)
        let exp = expectation(description: "filtered updates")

        vm.$filtered.dropFirst().sink { filtered in
            XCTAssertEqual(filtered.map(\.title), ["Toy Story"])
            exp.fulfill()
        }.store(in: &cancellables)

        vm.searchText = "toy"
        wait(for: [exp], timeout: 1.0)
    }

    func testGenreChipsFilter() {
        let movies = [
            Movie(id: 1, title: "Movie A", posterPath: nil, releaseDate: "2020-01-01", genreIDs: [1]),
            Movie(id: 2, title: "Movie B", posterPath: nil, releaseDate: "2020-01-01", genreIDs: [2]),
            Movie(id: 3, title: "Movie C", posterPath: nil, releaseDate: "2020-01-01", genreIDs: [1,2]),
        ]
        let vm = makeVM(movies: movies, genres: [Genre(id: 1, name: "Action"), Genre(id: 2, name: "Comedy")])

        let exp = expectation(description: "genre filter")
        vm.$filtered.dropFirst().sink { filtered in
            XCTAssertTrue(filtered.allSatisfy { ($0.genreIDs ?? []).contains(1) })
            XCTAssertEqual(filtered.count, 2) // A and C
            exp.fulfill()
        }.store(in: &cancellables)

        vm.selectedGenreIDs = [1]
        wait(for: [exp], timeout: 1.0)
    }

    func testPaginationStopsWhenNoMorePages() {
        // repo returns totalPages = 1
        let movies = (1...6).map { Movie(id: $0, title: "M\($0)", posterPath: nil, releaseDate: "2020-01-01", genreIDs: [1]) }
        let repo = FakeRepo(movies: movies, totalPages: 1)
        let vm = MoviesListViewModel(repo: repo)

        // first load happened in init, try to load again
        vm.loadNextPage()
        // should not append because currentPage > totalPages
        XCTAssertFalse(vm.canLoadMore)
    }
}

// MARK: - Fake repo used by VM tests

private final class FakeRepo: MoviesRepositoryType {
    let movies: [Movie]
    let genres: [Genre]
    let totalPages: Int

    init(movies: [Movie], genres: [Genre] = [], totalPages: Int = 1) {
        self.movies = movies
        self.genres = genres
        self.totalPages = totalPages
    }

    func fetchGenres(forceRemote: Bool) -> AnyPublisher<[Genre], Never> {
        Just(genres).eraseToAnyPublisher()
    }

    func fetchTrending(page: Int, forceRemote: Bool) -> AnyPublisher<PagedResponse<Movie>?, Never> {
        let resp = PagedResponse(page: page, results: movies, totalPages: totalPages, totalResults: movies.count)
        return Just(resp as PagedResponse<Movie>?).eraseToAnyPublisher()
    }

    func fetchDetails(id: Int, forceRemote: Bool) -> AnyPublisher<MovieDetails?, Never> {
        Just(nil).eraseToAnyPublisher()
    }
}
